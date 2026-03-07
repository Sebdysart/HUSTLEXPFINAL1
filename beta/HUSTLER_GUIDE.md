# Hustler Beta Guide

This guide walks you through the complete Hustler experience in HustleXP. A Hustler is someone who earns money by applying for and completing tasks posted by Posters.

Read through this before you start so you know what to expect — and check the test scenarios at the bottom for specific flows we want you to exercise.

---

## 1. Create Your Account + Complete Your Profile

1. Open HustleXP and tap **Sign Up**.
2. Enter your email and create a password, or continue with Apple Sign-In.
3. Select **Hustler** as your role when prompted (you can also enable both Hustler and Poster roles later in Settings).
4. On the profile setup screen:
   - Upload a clear profile photo (tap the camera icon).
   - Write a short bio — 2-3 sentences about who you are and what you're good at.
   - Add your skills from the list (e.g., cleaning, heavy lifting, driving, tech help).
   - Set your service radius — how far you're willing to travel for tasks.
5. Complete the onboarding checklist. A complete profile gets surfaced higher in the AI matching system.

**Beta note**: KYC (identity verification) uses Stripe test mode. See `KNOWN_ISSUES.md` for the test document flow if you're prompted to verify identity.

---

## 2. Browse the Task Feed

1. Tap the **Feed** tab (the grid icon at the bottom).
2. Allow location permissions when prompted — this is required to see tasks near you.
3. Tasks are listed by relevance (AI matching) and distance. Swipe or scroll to browse.
4. Use the filter icon (top right) to filter by:
   - Category (cleaning, moving, errands, delivery, etc.)
   - Pay range
   - Distance
   - Task type (one-time vs recurring)
5. Tap any task card to open the full detail view — pay, description, location, Poster profile, and any skill requirements.

**Try this**: Toggle between list view and map view to see tasks geographically.

---

## 3. Apply for a Task

1. From the task detail screen, tap **Apply**.
2. Write a short pitch in the text field — tell the Poster why you're the right person. Be specific; generic applications get ignored.
3. Tap **Submit Application**.
4. Your application appears in the Poster's applicant list. You'll be notified when they respond.

You can track your pending applications under **Profile > My Applications**.

**Note**: You can withdraw an application before it's accepted by tapping **Withdraw** on the application detail screen.

---

## 4. Getting Accepted + Starting Work

1. When a Poster accepts your application, you'll receive an in-app notification (and a push notification if FCM is working in your sandbox — see `KNOWN_ISSUES.md`).
2. Open the task. Its status changes to **Accepted — Ready to Start**.
3. Read the Poster's any additional instructions (sometimes added post-acceptance in the task chat).
4. Tap **Start Task** when you arrive or begin work. This records your start time and notifies the Poster.

The task chat (messaging thread) opens automatically once you're accepted. Use it to coordinate with the Poster directly.

---

## 5. Checking In (Location-Required Tasks)

Some tasks require location check-in to confirm you're on-site.

1. When you tap **Start Task**, if the task is location-gated, you'll be prompted to confirm your location.
2. Allow the location check — the app verifies you're within the task's geofence.
3. If location verification fails (e.g., GPS drift), tap **Manual Check-In** and the Poster will be notified to confirm.

**Beta note**: Geolocation accuracy varies by device and environment. If check-in fails unexpectedly, note your device model and report it.

---

## 6. Submitting Proof of Completion

When you've finished the work:

1. Tap **Submit Proof** on the active task screen.
2. Take or upload photos showing the completed work. You can attach up to 6 photos.
3. Add an optional note describing what you did (helpful for disputes).
4. Tap **Submit for Review**.

The Poster is notified immediately and has 48 hours to approve or dispute the submission. If they don't respond within 48 hours, the system auto-approves and releases payment.

**Beta note**: R2 photo upload is wired but please verify photos actually attach before submitting. If upload hangs, try again and report the issue with your device model.

---

## 7. Getting Paid (Escrow Release)

1. Once the Poster approves your proof (or the 48-hour auto-approval triggers), payment is released from escrow.
2. Funds are sent to your connected Stripe account.
3. You'll see a **Payment Released** notification and the task status updates to **Complete**.

**Stripe test mode**: No real money moves in beta. Use the Stripe test payout flow. See `KNOWN_ISSUES.md` for test account setup.

**Payout timing**: In production, Stripe payouts take 2-7 business days. In test mode, this is simulated.

---

## 8. XP, Badges, and Leveling Up

After each completed task:

- You earn **XP** based on task pay, difficulty rating, and Poster rating.
- Completing tasks in specific categories unlocks **skill badges** (e.g., "Top Cleaner", "Heavy Lifter").
- Your **Hustler level** increases as XP accumulates — higher levels unlock better task recommendations and Premium features.
- Check your XP progress on your **Profile** tab. Tap any badge to see unlock criteria.

**Try this**: Complete 3 tasks and watch your level progress. Check the leaderboard under Community.

---

## 9. Squads — Joining and Earning with Your Team

Squads are groups of Hustlers who earn together and compete on team leaderboards.

1. Tap the **Squads** tab.
2. Browse available squads or tap **Create Squad** to start your own.
3. To join a squad, tap **Request to Join** or enter an invite code if the squad is private.
4. Once in a squad, your XP contributes to the squad total.
5. Squad leaderboards reset weekly. Top squads earn bonus XP multipliers.

**Beta limit**: Squads are capped at 5 members in this beta build.

---

## 10. Subscription Tiers

HustleXP has three tiers:

| Feature | Free | Premium | Pro |
|---|---|---|---|
| Task applications per week | 5 | Unlimited | Unlimited |
| AI match boost | — | Standard | Priority |
| Squad creation | — | Yes | Yes |
| Analytics dashboard | — | Basic | Full |
| Featured Hustler badge | — | — | Yes |
| Support priority | Standard | Standard | Priority |

To upgrade:

1. Go to **Profile > Subscription**.
2. Choose Premium or Pro.
3. Complete the in-app purchase (test mode — use Stripe test card).

Subscriptions can be cancelled any time from the same screen.

---

## 11. Reporting Issues

If something breaks or feels wrong:

- **Shake your device** to open the in-app feedback reporter (a screenshot is auto-attached).
- **Email**: beta@hustlexp.app
- **Use the template** in `FEEDBACK_TEMPLATE.md` to structure your report.

Please include your device model and iOS version with every bug report.

---

## 12. Test Scenarios to Specifically Try

Run through as many of these as you can. Where you see "expected outcome", verify that's what actually happens and flag if not.

### T-H1: Full Task Completion Flow
1. Browse the feed and find a task near you.
2. Apply with a personalized pitch.
3. Wait for acceptance (coordinate with a beta Poster tester if needed).
4. Start the task, complete work, submit photo proof.
5. **Expected**: Payment releases, XP is awarded, task moves to Complete status.

### T-H2: Application Withdrawal
1. Apply for a task.
2. Before it's accepted, navigate to My Applications and withdraw.
3. **Expected**: Application is removed, Poster no longer sees it in their applicant list.

### T-H3: Location Check-In
1. Accept a task that requires location check-in.
2. Travel to or simulate being near the task address.
3. Tap Start Task and go through location verification.
4. **Expected**: Check-in succeeds, Poster is notified you've started.

### T-H4: Photo Proof Upload
1. Tap Submit Proof on an active task.
2. Attach 3+ photos.
3. Submit.
4. **Expected**: Photos upload successfully, Poster receives the submission notification.

### T-H5: Badge Unlock
1. Complete a task in a specific category (e.g., cleaning).
2. Return to your profile.
3. **Expected**: Relevant skill badge unlocked or progress incremented visibly.

### T-H6: Squad Interaction
1. Create a squad.
2. Have another beta tester join using your invite code (or request to join an existing squad).
3. Both complete a task.
4. **Expected**: Combined XP appears on squad leaderboard.

### T-H7: Subscription Upgrade
1. Start on Free tier.
2. Hit the application limit (5 apps/week).
3. Upgrade to Premium using test card `4242 4242 4242 4242`.
4. **Expected**: Application limit lifts immediately, premium badge appears on profile.

### T-H8: Dispute Experience (as Hustler)
1. Submit proof for a task.
2. Have the Poster open a dispute.
3. Respond to the dispute with additional evidence.
4. **Expected**: Dispute flow opens, both sides can submit evidence, admin review is triggered.

### T-H9: Recurring Task
1. Find and apply for a task marked as **Recurring**.
2. Complete the first instance.
3. **Expected**: Task auto-re-lists for the next scheduled occurrence. XP is awarded per completion.

### T-H10: Messaging
1. After being accepted for a task, open the task chat.
2. Send a text message to the Poster.
3. Send a photo in the chat.
4. **Expected**: Messages deliver in real-time, photo displays in-thread. Note any delays.
