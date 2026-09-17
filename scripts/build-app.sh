#!/bin/zsh
set -euo pipefail

project_root="${0:A:h:h}"
app_path="$project_root/MacClean.app"
build_path="$project_root/.build/release/MacClean"
resource_bundle_path="$project_root/.build/release/MacClean_MacClean.bundle"

cd "$project_root"
swift build -c release

if [[ -d "$app_path" ]]; then
  rm -rf "$app_path"
fi

mkdir -p "$app_path/Contents/MacOS" "$app_path/Contents/Resources"
cp "$build_path" "$app_path/Contents/MacOS/MacClean"
cp "$project_root/Resources/Info.plist" "$app_path/Contents/Info.plist"
cp "$project_root/Resources/MacClean.icns" "$app_path/Contents/Resources/MacClean.icns"
cp -R "$resource_bundle_path" "$app_path/Contents/Resources/MacClean_MacClean.bundle"
codesign \
  --force \
  --deep \
  --sign - \
  --identifier com.yunussahin.macclean \
  --requirements '=designated => identifier "com.yunussahin.macclean"' \
  "$app_path" >/dev/null

echo "Hazır: $app_path"
