#!/bin/sh
# Xcode Cloud runs this right after cloning. The Xcode project is generated from
# project.yml and not checked in, so it has to be made before Xcode Cloud looks
# for NoAutoZoom.xcodeproj and its shared scheme.
set -eu

brew install xcodegen
cd "$CI_PRIMARY_REPOSITORY_PATH"
xcodegen generate
