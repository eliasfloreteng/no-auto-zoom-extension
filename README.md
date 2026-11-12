# No Auto Zoom

A Safari extension for iPhone that stops Safari from zooming in when you tap a text field. Pinch-to-zoom keeps working.

Install it from [TestFlight](https://testflight.apple.com/join/NCXvte5G), or read more at https://noautozoom.eliasf.se.

## How it works

Safari zooms into a focused field whose font size is under 16px, unless the page's viewport caps zooming with `maximum-scale`. Since iOS 10 Safari ignores that cap for pinch-zooming, so the cap only switches off the automatic zoom.

The content script (`Extension/Resources/content.js`) runs at `document_start` on every page and:

- adds `maximum-scale=1` to the page's `<meta name="viewport">`, or caps the scale at the page's `initial-scale` if that is higher;
- adds a viewport tag with only `maximum-scale=1` to pages that have none, so their layout width stays the same;
- keeps watching `<head>`, because frameworks add or rewrite the viewport tag after the page loads;
- puts the page's own tag back when you turn the extension off for a site.

The popup turns it off for the current site. The list of sites is kept in `browser.storage.local`.

## Building

The Xcode project is generated with [XcodeGen](https://github.com/yonaskolb/XcodeGen):

```sh
xcodegen generate
open NoAutoZoom.xcodeproj
```

To redraw the icons, run `swift scripts/generate-icons.swift`.

## Turning it on

Settings › Apps › Safari › Extensions › No Auto Zoom: turn on **Allow Extension**, then set **All Websites** to **Allow**.

## Releases

Builds reach TestFlight through Xcode Cloud, whose workflow archives every new tag.
`ci_scripts/ci_post_clone.sh` generates the Xcode project there, since it is not checked in.

The **Release** GitHub Action bumps `CURRENT_PROJECT_VERSION` in `project.yml`, commits it and
tags the commit `v<MARKETING_VERSION>-<build>`. Xcode Cloud only builds a tag whose files
changed, so the bump is what starts the build. Run it from the Actions tab for a release; it
also runs daily and releases on its own once the latest release is 50 days old. That is before
the TestFlight build expires at 90 days, and before GitHub turns off the schedule, which it does
in a public repo after 60 days without activity.

## Website

`web/` is the landing page at https://noautozoom.eliasf.se, a static site that Bun serves
(`cd web && bun server.ts`). `compose.yaml` runs it on the pi, which redeploys on every push to `main`.

For search engines and AI agents the site has `robots.txt`, `sitemap.xml`, `llms.txt` (the page as
plain text) and structured data in `index.html`. Keep the questions in `index.html`, its structured
data and `llms.txt` saying the same thing. `web/og.html` is the source of the share image `site/og.png`.
The 32-character `.txt` file in `site/` is the IndexNow key that lets the site tell Bing about changes.

## License

[MIT](LICENSE)
