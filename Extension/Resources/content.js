// Prevents Safari on iPhone from zooming in when a text field gets focus.
//
// Safari zooms into any focused field whose font size is below 16px, unless the
// page's viewport caps zooming with `maximum-scale`. Since iOS 10, Safari ignores
// that cap for pinch-zooming, so setting it only removes the automatic zoom: you
// can still pinch to zoom on every page.
(() => {
  "use strict";

  const VIEWPORT = 'meta[name="viewport" i]';
  const INSERTED = "data-no-auto-zoom";
  const host = location.hostname;

  // Each viewport meta tag we have changed, mapped to the page's own content.
  const originals = new Map();
  let enabled = false;

  function parse(content) {
    const entries = new Map();
    for (const part of content.split(/[,;]/)) {
      const [key, ...value] = part.split("=");
      const name = key.trim().toLowerCase();
      if (name) entries.set(name, value.join("=").trim());
    }
    return entries;
  }

  function serialize(entries) {
    return [...entries].map(([key, value]) => (value ? `${key}=${value}` : key)).join(", ");
  }

  // The page's viewport content with zooming capped at the scale the page
  // opens at, which leaves Safari no room to zoom into a field.
  function capped(content) {
    const entries = parse(content);
    const initial = parseFloat(entries.get("initial-scale"));
    const cap = Number.isFinite(initial) && initial > 1 ? initial : 1;
    const current = parseFloat(entries.get("maximum-scale"));
    if (Number.isFinite(current) && current <= cap) return content;
    entries.set("maximum-scale", String(cap));
    return serialize(entries);
  }

  function apply(meta) {
    const content = meta.getAttribute("content") ?? "";
    const known = originals.get(meta);
    // The page changed the tag after we did: treat that as its new content.
    if (known === undefined || content !== capped(known)) originals.set(meta, content);
    const wanted = capped(originals.get(meta));
    if (content !== wanted) meta.setAttribute("content", wanted);
  }

  function applyAll() {
    const metas = document.querySelectorAll(VIEWPORT);
    for (const meta of metas) {
      if (meta.hasAttribute(INSERTED) && metas.length > 1) meta.remove();
      else apply(meta);
    }
    for (const meta of originals.keys()) if (!meta.isConnected) originals.delete(meta);
  }

  // Pages without a viewport tag (desktop layouts) still auto-zoom, so give
  // them one that only caps the scale and leaves their layout width alone.
  function insertIfMissing() {
    if (!enabled || document.querySelector(VIEWPORT) || !document.head) return;
    const meta = document.createElement("meta");
    meta.name = "viewport";
    meta.content = "maximum-scale=1";
    meta.setAttribute(INSERTED, "");
    document.head.append(meta);
    apply(meta);
  }

  function restoreAll() {
    for (const [meta, content] of originals) {
      if (meta.hasAttribute(INSERTED)) meta.remove();
      else meta.setAttribute("content", content);
    }
    originals.clear();
  }

  // Frameworks add or rewrite the viewport tag after load, so keep watching:
  // the root until <head> exists, then everything inside <head>.
  let watched = null;
  const observer = new MutationObserver(() => {
    if (document.head && watched !== document.head) watch();
    applyAll();
  });

  function watch() {
    observer.disconnect();
    watched = document.head ?? document.documentElement;
    observer.observe(watched, watched === document.head
      ? { childList: true, subtree: true, attributes: true, attributeFilter: ["content", "name"] }
      : { childList: true });
  }

  function setEnabled(value) {
    if (value === enabled) return;
    enabled = value;
    if (enabled) {
      applyAll();
      insertIfMissing();
      watch();
    } else {
      observer.disconnect();
      watched = null;
      restoreAll();
    }
  }

  const isDisabledHere = (disabledHosts) => (disabledHosts ?? []).includes(host);

  browser.storage.local.get("disabledHosts").then(({ disabledHosts }) => {
    setEnabled(!isDisabledHere(disabledHosts));
  });

  browser.storage.onChanged.addListener((changes, area) => {
    if (area === "local" && changes.disabledHosts) {
      setEnabled(!isDisabledHere(changes.disabledHosts.newValue));
    }
  });

  document.addEventListener("DOMContentLoaded", insertIfMissing, { once: true });

  // Lets the popup show which site it is toggling.
  browser.runtime.onMessage.addListener((message) => {
    if (message?.type === "status") return Promise.resolve({ host, enabled });
  });
})();
