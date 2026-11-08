const row = document.getElementById("row");
const toggle = document.getElementById("toggle");

async function disabledHosts() {
  const { disabledHosts = [] } = await browser.storage.local.get("disabledHosts");
  return disabledHosts;
}

async function setBlocked(host, blocked) {
  const hosts = new Set(await disabledHosts());
  blocked ? hosts.delete(host) : hosts.add(host);
  await browser.storage.local.set({ disabledHosts: [...hosts] });
}

try {
  const [tab] = await browser.tabs.query({ active: true, currentWindow: true });
  // Answered by the content script, so this fails where the extension can't run.
  const { host } = await browser.tabs.sendMessage(tab.id, { type: "status" });
  document.getElementById("host").textContent = `On ${host}`;
  toggle.checked = !(await disabledHosts()).includes(host);
  toggle.addEventListener("change", () => setBlocked(host, toggle.checked));
  row.hidden = false;
} catch {
  document.getElementById("unavailable").hidden = false;
}
