# Welcome to the HustleXP Private Beta

Hey there —

You made the list. We're incredibly excited to have you as one of our first beta testers for HustleXP, and we mean that genuinely — not in a boilerplate marketing way.

HustleXP is a gig economy marketplace built for real people doing real work. Posters list tasks — cleaning, moving help, errands, odd jobs, whatever needs doing — and Hustlers apply, complete the work, and get paid through a secure escrow system. Along the way, Hustlers earn XP, unlock badges, level up, and build a reputation that follows them across every gig they take.

We've poured a lot into making this feel like a community, not just a transaction. Squads, live broadcasts, skill verification, AI matching, recurring tasks — it's all in there. And you're the first people outside our team to use it.

---

## Why Your Feedback Matters

We are genuinely in the part of the journey where your experience shapes the final product. Not in a vague "we value your input" way — in a very literal "the things that frustrate you right now will be fixed before we launch publicly" way.

Every bug you find, every flow that feels clunky, every feature you wish existed: that's the roadmap. You're not testing a finished product. You're co-authoring one.

---

## How to Install via TestFlight

1. On your iPhone, open the **App Store** and download **TestFlight** (it's free, made by Apple).
2. Open the TestFlight invite link from this email. It will take you directly to the HustleXP beta install page.
3. Tap **Accept** on the beta invitation.
4. Tap **Install**. The app will appear on your home screen with an orange dot indicating it's a beta build.
5. Open HustleXP and create your account.

If you run into any issues installing, email us at **beta@hustlexp.app** and we'll sort it out.

---

## Quick Start Guide

You can use HustleXP as a **Hustler** (earning by completing tasks), a **Poster** (getting things done by hiring Hustlers), or both. Here's the fastest path to your first experience in each role.

### As a Hustler

1. Create your account and fill out your profile — add a photo, write a short bio, and list your skills.
2. Enable location permissions when prompted (required for task discovery near you).
3. Browse the task feed. Tap any task to see details: pay, location, requirements.
4. Hit **Apply** on a task you want. Write a short pitch about why you're the right person.
5. When a Poster accepts you, you'll get notified. Head to the task, complete the work, and submit photo proof when done.
6. Once the Poster approves, payment releases from escrow directly to your Stripe account.
7. Watch your XP climb and unlock your first badges.

### As a Poster

1. Create your account.
2. Tap the **+** button to post a task. Add a title, description, category, location, and how much you're willing to pay.
3. Fund the escrow — this holds your payment securely until the work is approved.
4. Review Hustler applications and accept the best fit.
5. Monitor progress in real-time as the Hustler checks in and submits proof.
6. Approve the work and release payment. Rate your Hustler to help build the community.

---

## How to Submit Feedback

We want to hear from you through whatever channel is easiest:

- **In-app**: Shake your device at any time to trigger the feedback reporter (screenshot auto-attaches).
- **Email**: Send bug reports, feature requests, or general thoughts to **beta@hustlexp.app**.
- **GitHub Issues**: If you're comfortable with GitHub, file issues at the project repo — we triage daily.

When reporting a bug, please use the feedback template in `FEEDBACK_TEMPLATE.md` (also linked in the app). The more detail you give us, the faster we can fix it.

---

## Known Beta Limitations

We want to be upfront about what isn't fully wired yet so you're not left wondering if you did something wrong.

- **Background checks**: Checkr integration is deferred for this beta build. The UI exists but checks will not complete.
- **Push notifications**: FCM delivery can be delayed or unreliable in the TestFlight sandbox environment. Check the app directly if you're expecting a notification.
- **Stripe is in TEST MODE**: No real money changes hands. Use test card `4242 4242 4242 4242` with any future expiry and any 3-digit CVC for all payments.
- **KYC / identity verification**: Also in Stripe test mode. Use Stripe's test document flow — instructions in `KNOWN_ISSUES.md`.
- **AI matching**: The model is still being fine-tuned. Suggestions may not always be a perfect fit.
- **Squads**: Limited to 5 beta testers per squad in this build.

Full details in `KNOWN_ISSUES.md`.

---

## Questions?

Reach us any time at **beta@hustlexp.app**. Response time target is 24 hours, usually faster.

Thank you for being here at the beginning. Let's build something great together.

— The HustleXP Team
