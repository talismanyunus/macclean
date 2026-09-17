#!/bin/zsh
# Creates a signed .pkg for App Store Connect. It intentionally requires the
# real App Store certificate, team identifier, and provisioning profile; no
# development or ad-hoc signature can be uploaded to App Store Connect.
set -euo pipefail

: "${MACCLEAN_TEAM_ID:?Set your 10-character Apple Developer Team ID}"
: "${MAC_APP_STORE_APPLICATION_IDENTITY:?Set the Apple Distribution application certificate name}"
: "${MAC_APP_STORE_INSTALLER_IDENTITY:?Set the Apple Distribution installer certificate name}"
: "${MAC_APP_STORE_PROVISIONING_PROFILE:?Set the absolute path to the App Store provisioning profile}"

project_root="${0:A:h:h}"
staging_root="$project_root/build/AppStore"
app_path="$staging_root/MacClean.app"
package_path="$staging_root/MacClean.pkg"
build_path="$project_root/.build/release/MacClean"
resource_bundle_path="$project_root/.build/release/MacClean_MacClean.bundle"
entitlements_path="$staging_root/MacClean-AppStore.entitlements"
profile_plist_path="$staging_root/profile.plist"
version="${VERSION:-1.0.0}"
build_number="${BUILD_NUMBER:-1}"

cd "$project_root"
swift build -c release -Xswiftc -DAPP_STORE

rm -rf "$staging_root"
mkdir -p "$app_path/Contents/MacOS" "$app_path/Contents/Resources"
cp "$build_path" "$app_path/Contents/MacOS/MacClean"
cp "$project_root/Resources/Info.plist" "$app_path/Contents/Info.plist"
cp "$project_root/Resources/MacClean.icns" "$app_path/Contents/Resources/MacClean.icns"
# Privacy manifest — copied from the SPM resource bundle into Contents/Resources/
# so App Store Connect validation finds it at the expected path.
cp "$resource_bundle_path/PrivacyInfo.xcprivacy" "$app_path/Contents/Resources/PrivacyInfo.xcprivacy"
cp -R "$resource_bundle_path" "$app_path/Contents/Resources/MacClean_MacClean.bundle"
cp "$MAC_APP_STORE_PROVISIONING_PROFILE" "$app_path/Contents/embedded.provisionprofile"

security cms -D -i "$MAC_APP_STORE_PROVISIONING_PROFILE" > "$profile_plist_path"
expected_application_identifier="$MACCLEAN_TEAM_ID.com.yunussahin.macclean"
profile_application_identifier="$(/usr/libexec/PlistBuddy -c 'Print :Entitlements:application-identifier' "$profile_plist_path")"
if [[ "$profile_application_identifier" != "$expected_application_identifier" ]]; then
  echo "Profil uygulama kimliği uyuşmuyor: $profile_application_identifier" >&2
  echo "Beklenen: $expected_application_identifier" >&2
  exit 1
fi

cp "$project_root/Resources/MacClean.entitlements" "$entitlements_path"
/usr/libexec/PlistBuddy -c "Add :com.apple.application-identifier string $MACCLEAN_TEAM_ID.com.yunussahin.macclean" "$entitlements_path"
/usr/libexec/PlistBuddy -c "Add :com.apple.developer.team-identifier string $MACCLEAN_TEAM_ID" "$entitlements_path"
/usr/libexec/PlistBuddy -c "Add :get-task-allow bool false" "$entitlements_path"
/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $version" "$app_path/Contents/Info.plist"
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $build_number" "$app_path/Contents/Info.plist"

codesign --force --deep --options runtime --timestamp \
  --sign "$MAC_APP_STORE_APPLICATION_IDENTITY" \
  --entitlements "$entitlements_path" \
  "$app_path"
codesign --verify --deep --strict --verbose=2 "$app_path"

productbuild --component "$app_path" /Applications \
  --sign "$MAC_APP_STORE_INSTALLER_IDENTITY" \
  "$package_path"
pkgutil --check-signature "$package_path"

echo "App Store Connect paketi hazır: $package_path"
