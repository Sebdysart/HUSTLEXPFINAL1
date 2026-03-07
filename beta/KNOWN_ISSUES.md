# Known Issues and Beta Limitations

This document lists everything we know is limited, missing, or behaving differently in this beta build compared to the production target. Read this before reporting issues — if something is already listed here, we know about it.

That said: if you experience something listed here in an unexpected way or in a new context, please still report it.

---

## Stripe Test Mode — All Payments Are Simulated

**The entire payment system runs in Stripe test mode. No real money changes hands.**

### Test Card Numbers

Use these card numbers for all payment flows (task funding, subscriptions, featured listings):

| Card Number | Network | Description |
|---|---|---|
| `4242 4242 4242 4242` | Visa | Standard success — use for most tests |
| `4000 0566 5566 5556` | Visa (debit) | Debit card success |
| `5555 5555 5555 4444` | Mastercard | Success |
| `3782 822463 10005` | American Express | Success |
| `4000 0000 0000 9995` | Visa | Simulates card decline |
| `4000 0000 0000 0002` | Visa | Simulates generic decline |
| `4000 0025 0000 3155` | Visa | Simulates 3D Secure authentication required |

**Expiry**: Any future date (e.g., `12/28`)
**CVC**: Any 3-digit number (e.g., `123`). For Amex use any 4-digit number.
**ZIP**: Any 5-digit number (e.g., `10001`)

### Test Payout / Stripe Connect

Hustlers connecting a bank account for payouts should use Stripe's test bank account details:

- **Routing number**: `110000000`
- **Account number**: `000123456789`

This simulates a valid bank connection. Test payouts are instant in test mode (no 2-7 day delay).

---

## KYC / Identity Verification (Stripe Identity — Test Mode)

Identity verification is also in Stripe test mode. Real documents are not processed.

### How to Complete Test KYC

1. When prompted to verify your identity, tap **Verify Now**.
2. On the Stripe Identity screen, tap **Upload Document**.
3. Select **Driver's License** (or any document type).
4. Use Stripe's test images:
   - Take a photo of **any plain white surface** (or a blank piece of paper).
   - Stripe's test environment accepts these as valid documents in test mode.
5. When prompted for a selfie, look directly at the camera and follow the on-screen prompts.
6. **Expected result**: Verification completes as "Verified" within a few seconds.

If verification fails in test mode, try again. Occasionally Stripe's test environment returns an error on the first attempt.

**Production behavior**: In production, users will submit real government ID and a selfie. Stripe processes these with their automated verification system.

---

## Background Checks (Checkr) — Deferred

Background check functionality is present in the UI but **checks will not complete** in this beta.

- The Checkr integration is deferred pending account authorization. Our account is under review.
- If you tap any flow that triggers a background check, you'll see the initiation screen but the check will not process.
- Tasks that require background checks in production will not gate on this requirement during beta.
- This feature is targeted for the first post-beta release.

**Do not report**: "Background check stuck / never completes." This is expected.

---

## Push Notifications (FCM) — Intermittent in Sandbox

FCM (Firebase Cloud Messaging) push notification delivery is unreliable in the TestFlight sandbox environment.

- Notifications may be delayed by minutes or not arrive at all.
- In-app notifications (visible in the notification bell when the app is open) are not affected — those are real-time via SSE.
- If you're waiting on a notification to drive a test flow, check the app directly rather than relying on a push.

**What to report**: If in-app notifications (within the app) are also delayed or missing — that's a real bug.

---

## Real-Time Task Updates (SSE) — Occasional Lag

Server-Sent Events drive real-time task status updates (Accepted → Started → Proof Submitted → Complete).

- In most cases these update within 1-2 seconds.
- Occasionally the SSE connection drops and status appears stale.
- **Workaround**: Pull down to refresh on the task detail screen to force a status sync.
- **Please report**: If SSE lag is consistent (every time, on every task) rather than occasional.

---

## Photo Messaging — Partially Wired

Text messaging between Posters and Hustlers is fully functional. Photo messaging in the chat thread is wired but has a known intermittent issue with upload confirmation.

- Photos may upload without showing a visible progress indicator.
- If a photo appears to hang, wait 10 seconds before retrying — the upload may have completed server-side without the UI reflecting it.
- **Please report**: Device model, iOS version, network type (WiFi/cellular), and whether the photo ultimately appeared or was lost.

---

## AI Task Matching — Model in Fine-Tuning

The AI matching system that surfaces relevant tasks to Hustlers (and recommends Hustlers to Posters) is still being fine-tuned.

- Match quality may be inconsistent — you may see tasks that are not relevant to your skills or location.
- The model improves with each completed task and rating in the system. Beta data directly feeds training.
- Featured tasks are promoted regardless of match score.

**Please note in feedback**: If you consistently see completely irrelevant task recommendations, include your profile's skills and location radius so we can investigate.

---

## Squad Size Cap — 5 Members Maximum

In this beta build, squads are capped at **5 members maximum**. This is a beta infrastructure limit, not the production design.

- Production squads will support up to 50 members.
- If you hit the squad cap, you'll see an error: "This squad is at capacity." This is expected.

---

## Task Detail Screen (iOS) — Limited Interaction States

The task detail screen is implemented but some edge-case UI states are still being polished:

- A task that has been deleted by the Poster after you've applied may show a generic error instead of "Task no longer available."
- Very long task descriptions (500+ characters) may clip on certain screen sizes. Scroll to see full content.
- Task category icons may not render correctly for custom categories — falls back to a generic icon.

---

## Geolocation — Accuracy Varies

Location-gated tasks use device GPS for check-in verification.

- GPS accuracy varies significantly by device model and environment (indoor vs outdoor, urban vs suburban).
- If location check-in fails due to GPS drift, use the **Manual Check-In** fallback.
- **Please report**: Device model, environment (indoor/outdoor/urban), and GPS accuracy shown in the check-in failure message.

---

## TestFlight Build Numbers

The current beta build is updated frequently. Always make sure you're on the latest TestFlight build before reporting issues.

- Open TestFlight to check for updates.
- Build number is visible in **Settings > About** within the app.
- Include the build number in all bug reports.

---

## Not Yet in Beta (Targeted Post-Launch)

These features are intentionally excluded from this beta and will ship in future releases:

- Background check gating on task acceptance (Checkr)
- 1099-NEC tax form delivery to Hustlers (targeted for tax season)
- Full FCM notification reliability in production (requires production Firebase project)
- Admin dispute dashboard (admin review happens manually in beta)

---

*Questions about anything on this list? Email beta@hustlexp.app.*
