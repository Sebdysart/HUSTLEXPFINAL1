# TestFlight Setup Checklist

## Project Info

| Field | Value |
|-------|-------|
| Bundle ID | `taskme.hustleXP-final1` |
| Team ID | `V85B8S6KA2` (confirm at developer.apple.com) |
| Xcode project | `hustleXP final1.xcodeproj` |
| Scheme | `hustleXP final1` |

## Prerequisites (Manual Steps Required)

### 1. Apple Developer Account
- [ ] Active Apple Developer Program membership ($99/year)
- [ ] App ID registered: `taskme.hustleXP-final1`
- [ ] Capabilities enabled on the App ID:
  - Push Notifications
  - Sign In with Apple
  - Associated Domains (if used for universal links)

### 2. App Store Connect
- [ ] App created in App Store Connect with bundle ID `taskme.hustleXP-final1`
- [ ] TestFlight > Internal Testing group created
- [ ] At least 1 internal tester added
- [ ] Age rating and privacy information filled in (required before TestFlight can distribute)

### 3. Update ExportOptions.plist
- [ ] Replace `TEAM_ID_PLACEHOLDER` with your real Apple Team ID in `ExportOptions.plist`

  Current Team ID detected from `project.pbxproj`: **V85B8S6KA2**

  Verify at: https://developer.apple.com/account → Membership → Team ID

  ```bash
  # Quick one-liner (run from repo root):
  sed -i '' 's/TEAM_ID_PLACEHOLDER/V85B8S6KA2/' ExportOptions.plist
  ```

### 4. GitHub Secrets (Settings → Secrets and variables → Actions)

Add these secrets to the **HUSTLEXPFINAL1** repository:

| Secret Name | How to Get It |
|-------------|---------------|
| `APPLE_TEAM_ID` | Apple Developer → Membership → Team ID (10-character string, e.g. `V85B8S6KA2`) |
| `APP_STORE_CONNECT_API_KEY_ID` | App Store Connect → Users & Access → Integrations → Keys → Key ID |
| `APP_STORE_CONNECT_API_ISSUER_ID` | App Store Connect → Users & Access → Integrations → Keys → Issuer ID (UUID format) |
| `APP_STORE_CONNECT_API_KEY_CONTENT` | Base64-encoded `.p8` file: `base64 -i AuthKey_KEYID.p8 \| pbcopy` |

To create an App Store Connect API key:
1. App Store Connect → Users & Access → Integrations → App Store Connect API
2. Generate a new key with "App Manager" role
3. Download the `.p8` file (one-time download — keep it safe)
4. Note the Key ID and Issuer ID shown on that page

### 5. Code Signing
The build script uses `signingStyle: automatic`. Ensure:
- [ ] The Xcode project target has "Automatically manage signing" enabled
- [ ] The `DEVELOPMENT_TEAM` in `project.pbxproj` matches `V85B8S6KA2`
- [ ] For CI: the `APP_STORE_CONNECT_API_KEY_*` secrets allow Xcode to handle provisioning automatically via `-allowProvisioningUpdates`

## Triggering a Build

### Automatic (on push to main)
Every push to `main` triggers a TestFlight build automatically via `.github/workflows/testflight.yml`.

### Automatic (on beta tag)
Push a tag matching `v*.*.*-beta*` to trigger a build:
```bash
git tag v1.0.0-beta1
git push origin v1.0.0-beta1
```

### Manual (GitHub Actions)
1. GitHub → Actions → TestFlight Upload → Run workflow
2. Optionally enter build notes describing what to test

### Local Build
```bash
# From repo root
./scripts/build-testflight.sh

# Custom scheme or configuration
./scripts/build-testflight.sh "hustleXP final1" Release
```

The script will error if `ExportOptions.plist` still has `TEAM_ID_PLACEHOLDER`.

## Stripe Keys Note

`AppConfig.swift` uses `pk_live_REPLACE_WITH_LIVE_PUBLISHABLE_KEY` as the production Stripe key.
Before submitting to TestFlight/App Store, replace this with the real live publishable key from
https://dashboard.stripe.com/apikeys

## Build Artifacts

Archives are retained for 14 days as GitHub Actions artifacts (`HustleXP-archive`).
Local builds write to `build/` which is covered by `.gitignore`.

## Troubleshooting

| Problem | Fix |
|---------|-----|
| `TEAM_ID_PLACEHOLDER` error | Update `ExportOptions.plist` per Step 3 above |
| `No profiles for 'taskme.hustleXP-final1'` | Ensure app exists in App Store Connect with correct bundle ID |
| `xcpretty: command not found` | `gem install xcpretty` |
| `Xcode not found` | `sudo xcode-select -s /Applications/Xcode.app` |
| Upload fails with 401 | Check `APP_STORE_CONNECT_API_KEY_CONTENT` is correctly base64-encoded |
| Bitcode errors | `uploadBitcode` and `compileBitcode` are both `false` in `ExportOptions.plist` — correct for modern Xcode |
