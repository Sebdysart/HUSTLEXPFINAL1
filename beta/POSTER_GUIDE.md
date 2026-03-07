# Poster Beta Guide

This guide walks you through the complete Poster experience in HustleXP. A Poster is someone who creates tasks, hires Hustlers to complete them, and manages the payment through escrow.

Read through this before you start — and run the test scenarios at the bottom to cover the flows we most need validated.

---

## 1. Create Your Account

1. Open HustleXP and tap **Sign Up**.
2. Enter your email and create a password, or continue with Apple Sign-In.
3. Select **Poster** as your role when prompted (you can enable both Poster and Hustler from Settings later).
4. Complete your basic profile — name, photo, and a brief description of what kind of tasks you typically post.
5. Connect your payment method under **Profile > Payment**. In beta, use Stripe test card `4242 4242 4242 4242` with any future expiry and any 3-digit CVC.

---

## 2. Posting Your First Task

1. Tap the **+** button on the main tab bar (or the **Post a Task** button on the home screen).
2. Fill in the task details:
   - **Title**: Short and specific. "Help me move a couch" beats "Moving help needed."
   - **Description**: What exactly needs to be done, how long it should take, any requirements (strength, vehicle, tools, etc.).
   - **Category**: Choose from the category list (cleaning, moving, delivery, errands, tech, general labor, etc.).
   - **Location**: Enter the address or pin the map. Hustlers nearby will see this task.
   - **Pay**: Set the amount you're willing to pay. This gets held in escrow — it's not charged until a Hustler is accepted.
   - **Skill requirements**: If the task needs a specific badge level or verified skill, toggle it on.
   - **Task type**: One-time or recurring (see Section 9 for recurring setup).
3. Tap **Preview** to review your listing before publishing.
4. Tap **Post Task**. You'll be prompted to fund the escrow at this step.

**Beta note**: Payment is in Stripe test mode. Use test card details — no real charges occur.

---

## 3. Reviewing Applicants

1. Once your task is live, Hustlers can apply. You'll receive in-app notifications as applications come in.
2. Go to **My Tasks** and tap your task to open it.
3. Tap the **Applicants** tab to see everyone who applied.
4. Each applicant card shows: profile photo, bio, skill badges, Hustler level, XP total, and their application pitch.
5. Tap an applicant's name to view their full profile — past tasks, ratings, and reviews.
6. Shortlist applicants by tapping the bookmark icon, or go straight to accepting.

---

## 4. Accepting a Hustler

1. On the applicant's profile or card, tap **Accept**.
2. Confirm the selection in the dialog.
3. The Hustler is notified immediately. A task chat thread opens between you and the accepted Hustler.
4. All other applicants are automatically notified that the position has been filled.

You can message the Hustler through the task chat before they start — use this to clarify any instructions or answer questions.

---

## 5. Monitoring Task Progress (Real-Time Updates)

Once the Hustler starts the task, you can monitor progress in real-time:

1. Open the task from **My Tasks**.
2. The task status updates live via SSE (Server-Sent Events): **Accepted → Started → Proof Submitted → Complete**.
3. If the task requires location check-in, you'll see a map confirmation when the Hustler checks in on-site.
4. The task chat remains open throughout — message the Hustler at any time.

**Beta note**: The SSE real-time connection may occasionally lag or require a manual refresh in this build. If status seems stuck, pull down to refresh.

---

## 6. Reviewing Submitted Proof

When the Hustler submits their proof of completion:

1. You'll receive an in-app notification: **"[Hustler Name] submitted proof for [Task Name]."**
2. Open the task and tap the **Proof** tab.
3. Review the photos and any written notes the Hustler included.
4. You have two options:
   - **Approve**: Work looks good — proceeds to payment release.
   - **Dispute**: Work is unsatisfactory — opens the dispute flow (see Section 11).

You have **48 hours** to respond. If you don't act within 48 hours, the system automatically approves and releases payment.

---

## 7. Approving Work and Releasing Payment

1. Tap **Approve Work** on the proof review screen.
2. Confirm in the dialog.
3. Escrow releases payment to the Hustler's Stripe account immediately.
4. The task status updates to **Complete**.
5. You'll be prompted to rate the Hustler (see Section 8).

**Beta note**: Stripe payouts in test mode are simulated. The Hustler will see funds reflected in their test Stripe dashboard.

---

## 8. Rating the Hustler

Rating Hustlers is important — it builds the trust layer of the whole marketplace.

1. After approving work, the rating screen appears automatically.
2. Rate on three dimensions:
   - **Quality of work** (1–5 stars)
   - **Communication** (1–5 stars)
   - **Timeliness** (1–5 stars)
3. Write an optional review (public, shown on the Hustler's profile).
4. Tap **Submit Rating**.

You can also rate from **My Tasks > Completed** if you skip the prompt after approval.

**Please rate every task you complete in beta** — rating data is critical for tuning the AI matching system.

---

## 9. Recurring Tasks

Recurring tasks automatically re-post on a schedule after each completion.

1. When creating a task, toggle **Recurring Task** on.
2. Set the schedule: daily, weekly, bi-weekly, or monthly.
3. Set an end date or leave open-ended.
4. The same Hustler has the option to accept the recurring task directly — or you can re-open it to all applicants.

**Try this**: Post a weekly recurring task, accept a Hustler, approve the first completion, and verify the task auto-re-posts on the correct schedule.

---

## 10. Featured Listings (Paid Promotion)

Feature your task to get it surfaced higher in Hustler feeds and AI match recommendations.

1. From the task detail screen (before or after posting), tap **Feature This Task**.
2. Choose a duration: 24 hours, 3 days, or 7 days.
3. Review the cost and confirm (test mode — use Stripe test card).
4. Your task gets a **Featured** badge and priority placement in the feed.

Featured tasks tend to receive applications 3–5x faster based on internal testing.

---

## 11. Dispute Flow

If submitted proof doesn't meet your expectations:

1. On the proof review screen, tap **Open Dispute** instead of Approve.
2. Select a dispute reason:
   - Work not completed as described
   - Quality below acceptable standard
   - Hustler no-showed
   - Other (describe)
3. Upload any counter-evidence (photos, notes).
4. Submit the dispute.
5. The Hustler is notified and can respond with additional evidence within 24 hours.
6. An HustleXP admin reviews both sides and makes a binding decision, typically within 48 hours.
7. Payment is held in escrow throughout the dispute process.

**Please test the dispute flow** — it's one of the most important flows for beta validation. You and a Hustler tester can coordinate a controlled dispute to test both sides.

---

## 12. Test Scenarios to Specifically Try

Run through as many of these as you can. Verify expected outcomes match what actually happens and flag anything that doesn't.

### T-P1: Full Task Post-to-Payment Flow
1. Post a task with full details.
2. Fund escrow with test card.
3. Accept a Hustler applicant.
4. Wait for proof submission.
5. Approve the work.
6. **Expected**: Payment releases, task moves to Complete, rating prompt appears.

### T-P2: Applicant Review and Rejection
1. Post a task.
2. Wait for 2+ applicants.
3. View each profile in detail.
4. Accept one and verify others are notified.
5. **Expected**: Rejected applicants receive a polite "position filled" notification.

### T-P3: Real-Time Status Monitoring
1. Accept a Hustler.
2. Ask them to start the task.
3. Watch the task status update in real-time on your screen (do not manually refresh).
4. **Expected**: Status transitions from Accepted to Started without a manual refresh.

### T-P4: Auto-Approval (48-Hour Timeout)
1. Accept a Hustler and have them submit proof.
2. Do not approve or dispute within the 48-hour window (coordinate timing with your Hustler tester).
3. **Expected**: System auto-approves and releases payment. You receive a notification that auto-approval occurred.

### T-P5: Dispute Flow
1. Coordinate with a Hustler tester to submit intentionally incomplete proof.
2. Open a dispute with evidence.
3. Have the Hustler respond.
4. **Expected**: Both sides can submit evidence, dispute enters admin review state, payment remains held.

### T-P6: Recurring Task Verification
1. Post a weekly recurring task.
2. Complete one cycle (accept → approve).
3. **Expected**: Task automatically re-posts with the same details for the next weekly occurrence.

### T-P7: Featured Listing
1. Post a task.
2. Purchase featured placement (test card).
3. **Expected**: Task shows "Featured" badge in the feed and appears near the top of results.

### T-P8: Messaging with Hustler
1. After accepting a Hustler, open the task chat.
2. Send a text message with updated instructions.
3. **Expected**: Message delivers in real-time. Note any delay.

### T-P9: Rating Submission
1. Approve a completed task.
2. Submit a rating across all three dimensions with a written review.
3. Navigate to the Hustler's public profile.
4. **Expected**: Your review appears on their profile, star ratings reflect your submission.

### T-P10: Subscription Upgrade
1. On a free Poster account, check what features are gated.
2. Upgrade to Premium using test card `4242 4242 4242 4242`.
3. **Expected**: Gated features (e.g., advanced analytics, priority applicant sorting) unlock immediately.
