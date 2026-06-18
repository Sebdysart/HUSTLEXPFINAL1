# TestFlight via GitHub Actions — Setup

CI workflow: `.github/workflows/testflight.yml` → archives Release, signs with an
App Store Connect API key, and uploads to TestFlight. Nothing builds locally.

| Field | Value |
|-------|-------|
| Bundle ID | `taskme.hustleXP-final1` |
| Team ID | `V85B8S6KA2` |
| Xcode project | `hustleXP final1.xcodeproj` |
| Scheme | `hustleXP final1` (shared) |
| Runner | `macos-14`, Xcode 16 |

## One-time setup (only Sebastian can do these)

### 1. App Store Connect API key
App Store Connect → Users and Access → Integrations → App Store Connect API →
generate a key with the **App Manager** role. Download the `.p8` **once** and
note the **Key ID** and **Issuer ID**.

### 2. App must already exist
The app with bundle ID `taskme.hustleXP-final1` must exist in App Store Connect
with a TestFlight internal testing group + at least one tester, and age-rating /
privacy info filled in (TestFlight blocks distribution otherwise).

### 3. Add four GitHub repo secrets
Repo → Settings → Secrets and variables → Actions → New repository secret:

| Secret | Value |
|--------|-------|
| `APPLE_TEAM_ID` | `V85B8S6KA2` |
| `APP_STORE_CONNECT_API_KEY_ID` | the Key ID from step 1 |
| `APP_STORE_CONNECT_API_ISSUER_ID` | the Issuer ID from step 1 |
| `APP_STORE_CONNECT_API_KEY_CONTENT` | base64 of the `.p8`: `base64 -i AuthKey_XXXX.p8 \| pbcopy` |

## Shipping a build
- Actions tab → "TestFlight Upload" → **Run workflow**, **or**
- push a tag: `git tag v1.2.6-beta1 && git push origin v1.2.6-beta1`

Build number is auto-assigned by Apple on upload (`manageAppVersionAndBuildNumber`),
so it never collides. The marketing version comes from `MARKETING_VERSION` in the
project (currently **1.0** — bump it if you want a new version train; see note below).

## Known caveats
- **Marketing version is `1.0`** in `project.pbxproj`, but TestFlight already had
  `1.2.5`. Uploading as-is lands under the 1.0 train. Bump `MARKETING_VERSION`
  (e.g. to `1.2.6`) before triggering if you want it to read as a newer version.
- **Headless signing is the usual failure point.** This uses automatic
  (cloud-managed) signing via the API key. If the first run fails at the archive
  step complaining about no signing certificate, the team needs a cloud-managed
  Apple Distribution certificate (Xcode → Settings → Accounts → Manage
  Certificates → + Apple Distribution while signed in once), or switch the
  workflow to import an explicit distribution `.p12` + provisioning profile.
- The **first CI run is the real validation** — none of this can be verified
  until the four secrets above exist.
