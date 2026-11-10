// Serves the static site: the landing page, the privacy page and their assets.
import { join, normalize, sep } from "node:path";

const SITE = join(import.meta.dir, "site");

/** Pages served without their `.html`. */
const PAGES: Record<string, string> = {
  "/": "index.html",
  "/privacy": "privacy.html",
};

function html(name: string, status: number): Response {
  return new Response(Bun.file(join(SITE, name)), {
    status,
    headers: { "Content-Type": "text/html; charset=utf-8", "Cache-Control": "public, max-age=300" },
  });
}

/** A file under the site directory, never outside it, and never an HTML page by its file name. */
function staticFile(pathname: string) {
  let decoded: string;
  try {
    decoded = decodeURIComponent(pathname);
  } catch {
    return null;
  }
  const path = normalize(join(SITE, decoded));
  if (!path.startsWith(SITE + sep) || path.endsWith(".html")) return null;
  return Bun.file(path);
}

const server = Bun.serve({
  port: Number(process.env.PORT ?? 3000),
  routes: {
    "/health": new Response("ok"),
  },
  async fetch(request) {
    if (request.method !== "GET" && request.method !== "HEAD") return new Response(null, { status: 405 });
    const { pathname } = new URL(request.url);
    const page = PAGES[pathname.replace(/\/+$/, "") || "/"];
    if (page) return html(page, 200);

    const file = staticFile(pathname);
    if (file && (await file.exists())) {
      return new Response(file, { headers: { "Cache-Control": "public, max-age=3600" } });
    }
    return html("404.html", 404);
  },
});

console.log(`Listening on ${server.url}`);
