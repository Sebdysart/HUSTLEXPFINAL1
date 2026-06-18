# TestFlight via GitHub Actions

**Status:** ✅ Working end-to-end. Builds ship to TestFlight entirely from CI — no
local Xcode build required. First green build: **v1.2.6 (202606180001)**, uploaded
2026-06-18 from `.github/workflows/testflight.yml`.

| Field | Value |
|-------|-------|
| Workflow | `.github/workflows/testflight.yml` |
| Build script | `scripts/build-testflight.sh` |
| Export options | `ExportOptions.plist` |
| Bundle ID | `taskme.hustleXP-final1` (App ID `6765829857`) |
| Team ID | `V85B8S6KA2` |
| Xcode project | `hustleXP final1.xcodeproj`, scheme `hustleXP final1` (shared) |
| Runner / toolchain | `macos-26`, **Xcode 26.3** (iOS 26 SDK) |

## How to ship a build

1. Bump `MARKETING_VERSION` in `hustleXP final1.xcodeproj/project.pbxproj` if you
   want a new version train (build number is date-based `YYYYMMDDnnnn` and Apple
   also auto-manages it on upload, so it never collides).
2. Trigger the release:
   - **Actions** tab → **TestFlight Upload** → **Run workflow**, *or*
   - push a tag: `git tag v1.2.6-beta1 && git push origin v1.2.6-beta1`
3. ~7–8 min later the build is processed and (because export compliance is
   pre-declared, see below) lands in the **Internal** TestFlight group automatically.

It is intentionally **not** triggered on every push to `main` — shipping to testers
is a deliberate action.

## How signing works (hybrid)

Headless distribution signing is the part that bites everyone. This pipeline uses
the pattern that actually works:

1. **Archive with automatic signing** — `xcodebuild archive -allowProvisioningUpdates`
   authenticated by the App Store Connect API key. Xcode picks a development
   identity; the SPM frameworks (Firebase, Stripe, Google…) build correctly.
   *Do not* force `PROVISIONING_PROFILE_SPECIFIER` globally — it breaks every
   framework with "does not support provisioning profiles".
2. **Export with manual distribution signing** — `xcodebuild -exportArchive` using
   `ExportOptions.plist` (`signingStyle=manual`, `signingCertificate=Apple
   Distribution`, profile `HustleXP App Store CI`). The imported `.p12` + profile
   re-sign **only the app**, then `destination=upload` ships it to TestFlight,
   authenticated by the same API key.

### Signing assets
- **Apple Distribution cert** `BMY3CPSSC2` — "Apple Distribution: Sebastian Dysart (V85B8S6KA2)"
- **App Store profile** `HustleXP App Store CI` (UUID `dcdde02e-c402-4401-be94-344c80c782b2`)

Both were created via the App Store Connect API and stored as repo secrets. The CI
job imports the cert into a temporary keychain and installs the profile per run.

## Required GitHub secrets (8)

Repo → Settings → Secrets and variables → Actions:

| Secret | What it is |
|--------|-----------|
| `APPLE_TEAM_ID` | `V85B8S6KA2` |
| `APP_STORE_CONNECT_API_KEY_ID` | App Store Connect API **Admin** key ID |
| `APP_STORE_CONNECT_API_ISSUER_ID` | Issuer ID (one UUID per team) |
| `APP_STORE_CONNECT_API_KEY_CONTENT` | base64 of the `.p8` (`base64 -i AuthKey_XXXX.p8`) |
| `BUILD_CERTIFICATE_P12` | base64 of the Apple Distribution `.p12` |
| `P12_PASSWORD` | password for that `.p12` |
| `BUILD_PROVISION_PROFILE` | base64 of the App Store `.mobileprovision` |
| `KEYCHAIN_PASSWORD` | any random string (temp keychain in CI) |

> The API key **must be the Admin role.** App Manager cannot create/fetch signing
> assets and fails archive. The team's Apple Developer **Program License Agreement
> must stay accepted** — if it lapses, the certificate APIs return 403 and all
> signing breaks.

## Export compliance

Builds upload as `VALID` but are held at `MISSING_EXPORT_COMPLIANCE` (and never
reach testers) until the encryption question is answered. The app declares
`ITSAppUsesNonExemptEncryption = NO` in `hustleXP-final1-Info.plist` (standard
HTTPS/TLS only), so builds now clear compliance automatically.

To clear an already-uploaded build manually: App Store Connect → TestFlight → the
build → Provide Export Compliance, or `PATCH /v1/builds/{id}` with
`{ "usesNonExemptEncryption": false }`.

## Renewal & troubleshooting

- **Cert expiry:** distribution cert `BMY3CPSSC2` expires **~June 2027**. When it
  lapses, export fails — re-create an Apple Distribution cert + App Store profile
  via the ASC API and refresh `BUILD_CERTIFICATE_P12` / `BUILD_PROVISION_PROFILE`.
- **Debugging a failed run:** the workflow tees raw `xcodebuild` output to
  `build/*.log` and uploads them as the `testflight-build-output` artifact.
- **Common failures we already fixed:** App-Manager-key 403 → use Admin key;
  `Cloud signing permission error` at export → use the manual dist cert/profile
  (above); `does not support provisioning profiles` → don't set the profile
  globally on archive; wrong SDK / deployment-target warning → run on `macos-26`.
