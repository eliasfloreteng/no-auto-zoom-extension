# No Auto Zoom

A Safari extension for iPhone that stops Safari from zooming in when you tap a text field. Pinch-to-zoom keeps working.

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
