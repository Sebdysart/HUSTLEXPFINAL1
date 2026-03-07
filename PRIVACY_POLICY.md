# HustleXP Privacy Policy

> **DRAFT — This document was generated as a starting point and has NOT been reviewed by legal counsel. Before publishing, have a qualified attorney review and customize for your jurisdiction and specific business practices.**

**Effective Date:** [INSERT DATE BEFORE PUBLISHING]
**Last Updated:** [INSERT DATE BEFORE PUBLISHING]

---

## Introduction

HustleXP Inc. ("HustleXP," "we," "our," or "us") operates the HustleXP mobile application and related services (collectively, the "Platform"), a gig economy marketplace connecting individuals who post tasks ("Posters") with individuals who complete them ("Hustlers"). This Privacy Policy explains how we collect, use, disclose, and protect your personal information when you use our Platform.

By using HustleXP, you agree to the practices described in this Privacy Policy. If you do not agree, please discontinue use of the Platform.

---

## 1. Information We Collect

### 1.1 Information You Provide Directly

**Account Information**
When you create an account, we collect:
- Full name
- Email address
- Phone number
- Profile photo (optional, but recommended)
- Password (stored in hashed form via Firebase Authentication)

**Identity Verification (KYC)**
To receive payments as a Hustler, we are required to verify your identity. This process is handled entirely by **Stripe Identity**, our identity verification partner. In connection with KYC verification, the following information may be collected and processed by Stripe on our behalf:
- Government-issued photo ID (e.g., driver's license, passport)
- A selfie or live photo for biometric comparison
- Date of birth
- Last four digits of your Social Security Number (SSN) or full SSN (for US tax reporting purposes when earnings reach applicable thresholds)

We do not store your raw identity documents on our servers. Stripe processes and retains this data subject to [Stripe's Privacy Policy](https://stripe.com/privacy).

**Tax Information**
If you earn $600 or more as a Hustler in a calendar year, we are legally required to issue a Form 1099-NEC to you and report your earnings to the IRS. To fulfill this obligation, we collect and retain:
- Your legal name
- Taxpayer Identification Number (TIN) or Social Security Number (SSN)
- Mailing address
- Total earnings for the tax year

This data is processed through **Stripe Tax** and retained for a minimum of seven (7) years as required by applicable tax law.

**Task and Work Information**
- Task descriptions, categories, and requirements you post
- Bids, applications, and work submissions
- Proof-of-completion photos you upload
- Any other content you voluntarily submit through the Platform

**Communications**
- Messages exchanged with other users through the in-app messaging system
- Support requests and communications with our team

### 1.2 Information We Collect Automatically

**Location Data**
When you use the HustleXP app, we collect your precise GPS location **while the app is in use** (foreground only) to:
- Show you nearby tasks relevant to your location
- Allow Posters to set task location requirements
- Facilitate proximity-based matching

We do not collect location data when the app is closed or running in the background. Location data is used in real time for matching purposes and **is not stored persistently** on our servers.

**Usage and Activity Data**
We automatically collect:
- App features accessed and actions taken
- Task browsing and search history within the app
- Device type, operating system version, and app version
- Session timestamps and duration

**Crash and Diagnostic Data**
We use **Sentry**, a third-party crash reporting service, to collect crash reports and diagnostic information when the app encounters an error. Sentry data is anonymized and does not include your name, email, or other directly identifying information. It may include device identifiers and stack traces. This data is used solely to identify and fix software bugs.

**Payment Activity**
When you make or receive payments on the Platform, transaction data (amounts, timestamps, task identifiers) is logged by us. However, **we do not collect, process, or store your full payment card numbers, bank account numbers, or other sensitive financial credentials.** All payment processing is handled by **Stripe**, subject to [Stripe's Privacy Policy](https://stripe.com/privacy).

---

## 2. How We Use Your Information

We use the information we collect for the following purposes:

### 2.1 Providing the Platform
- Creating and managing your account
- Matching Hustlers with relevant tasks
- Facilitating communication between Posters and Hustlers
- Processing payments, escrow, and payouts through Stripe Connect

### 2.2 Identity Verification and Trust & Safety
- Verifying user identities before enabling payment capabilities (KYC)
- Detecting and preventing fraud, abuse, and prohibited activity
- Enforcing our Terms of Service
- Keeping users safe on the Platform

### 2.3 Payment Processing and Financial Compliance
- Processing task payments and holding funds in escrow
- Releasing payouts to Hustlers upon task completion
- Charging platform fees and subscription fees
- Issuing 1099-NEC tax forms and reporting earnings to the IRS for Hustlers earning $600 or more in a calendar year

### 2.4 AI-Powered Features
- Analyzing task descriptions (not personal data) to improve task-matching recommendations
- Generating suggested task categories and tags using AI
- We use **OpenAI** for certain AI features. Task content sent to OpenAI for analysis does not include your personal identifiable information (name, email, phone, etc.)

### 2.5 Push Notifications
- Sending you alerts about task activity (new applications, messages, completion confirmations, payment status)
- Sending marketing or promotional notifications (only with your explicit opt-in consent; you can opt out at any time through your device settings or account preferences)

Push notifications are delivered via **Firebase Cloud Messaging (FCM)**.

### 2.6 Improving the Service
- Analyzing aggregate, anonymized usage patterns to improve Platform features
- Using crash reports from Sentry to fix bugs and improve stability
- Conducting internal analytics on product performance

### 2.7 Legal and Compliance Obligations
- Fulfilling IRS tax reporting requirements (1099-NEC)
- Responding to lawful requests from government authorities
- Enforcing our legal rights and defending against claims

---

## 3. Information Sharing and Disclosure

We do not sell your personal information to third parties. We share your information only as described below.

### 3.1 Service Providers and Partners

| Third Party | Purpose | Data Shared |
|---|---|---|
| **Stripe** | Payment processing, escrow, payouts, KYC/identity verification, 1099 tax reporting | Name, email, bank/payout info, identity documents, earnings data |
| **Firebase (Google)** | User authentication, push notifications | Email, device push token, UID |
| **Cloudflare R2** | Storage of proof-of-work photos and other user-uploaded files | Uploaded photos and files |
| **OpenAI** | AI-powered task matching and categorization | Task descriptions (no PII) |
| **Sentry** | Crash reporting and error monitoring | Anonymized diagnostic data, device info |

Each of these providers is contractually bound to use your information only for the purposes described and to maintain appropriate security standards.

### 3.2 Other Users

Certain information is visible to other users as part of the Platform's core function:
- Your display name and profile photo are visible to users you interact with
- Your ratings and reviews are publicly visible on the Platform
- Task content posted by Posters is visible to Hustlers browsing the Platform
- Proof-of-completion photos are shared with the task Poster

We do not share your email address, phone number, government ID, or payment information with other users.

### 3.3 Legal Requirements and Safety

We may disclose your information if we believe in good faith that such disclosure is necessary to:
- Comply with a legal obligation, court order, or lawful government request
- Enforce our Terms of Service
- Protect the rights, safety, or property of HustleXP, our users, or the public
- Detect, prevent, or address fraud, security, or technical issues

### 3.4 Business Transfers

If HustleXP is involved in a merger, acquisition, asset sale, or similar transaction, your information may be transferred as part of that transaction. We will notify you via email or prominent in-app notice before your information is transferred and becomes subject to a different privacy policy.

---

## 4. Data Retention

| Data Category | Retention Period |
|---|---|
| Account information (name, email, phone) | While account is active + 7 years after closure (for legal and tax compliance) |
| Identity verification documents | Retained by Stripe per their policy; we retain verification status only |
| Tax information (for 1099-NEC) | Minimum 7 years as required by IRS regulations |
| Task and transaction records | 7 years (legal/financial compliance) |
| In-app messages and communications | 2 years from the date of the message |
| Proof-of-completion photos | 2 years from task completion |
| Location data | Not stored persistently; used in real time only |
| Crash and diagnostic data (Sentry) | 90 days |
| Push notification tokens | Until account deletion or token refresh |

When you delete your account, we will delete or anonymize your personal information within a commercially reasonable time, except where retention is required for legal, tax, or regulatory compliance.

---

## 5. Your Privacy Rights

### 5.1 All Users

Regardless of where you live, you have the right to:
- **Access**: Request a copy of the personal information we hold about you
- **Correction**: Request that we correct inaccurate or incomplete information
- **Deletion**: Request that we delete your account and personal information (subject to legal retention requirements)
- **Portability**: Request your data in a structured, machine-readable format

To exercise these rights, contact us at **privacy@hustlexp.app**.

### 5.2 California Residents (CCPA / CPRA)

If you are a California resident, you have additional rights under the California Consumer Privacy Act (CCPA) and the California Privacy Rights Act (CPRA):

- **Right to Know**: You may request the categories and specific pieces of personal information we collect about you, the purposes for which we use it, and the categories of third parties with whom we share it.
- **Right to Delete**: You may request deletion of your personal information, subject to certain exceptions.
- **Right to Correct**: You may request correction of inaccurate personal information.
- **Right to Opt-Out of Sale or Sharing**: We do not sell your personal information. We do not share your personal information for cross-context behavioral advertising.
- **Right to Non-Discrimination**: We will not discriminate against you for exercising your CCPA rights.
- **Sensitive Personal Information**: We collect sensitive personal information (government ID, SSN for tax purposes) only as necessary for identity verification and tax compliance. You may have the right to limit our use of such information to the purposes for which it was collected.

To submit a verifiable consumer request, email **privacy@hustlexp.app** or submit a request through the account settings in the app.

**Authorized Agents**: California residents may use an authorized agent to submit requests. We may require verification of the agent's authority and your identity before processing such requests.

We will respond to verifiable consumer requests within 45 days.

### 5.3 Users Outside the United States

HustleXP is primarily designed for use in the United States. If you use the Platform from outside the US, you consent to the transfer of your information to the United States for processing.

If you are located in the European Economic Area (EEA), United Kingdom, or Switzerland, you may have additional rights under the General Data Protection Regulation (GDPR) or equivalent laws. Please contact us at **privacy@hustlexp.app** for information about how we handle data subject requests from users in these regions.

---

## 6. Data Security

We implement commercially reasonable administrative, technical, and physical safeguards to protect your personal information, including:
- Encryption of data in transit (TLS/HTTPS)
- Encryption of data at rest
- Access controls limiting employee access to personal information
- Use of established, security-certified third-party providers (Stripe, Firebase, Cloudflare)

No method of transmission over the internet or electronic storage is 100% secure. While we strive to protect your information, we cannot guarantee absolute security. If we become aware of a data breach that affects your personal information, we will notify you as required by applicable law.

---

## 7. Children's Privacy

HustleXP is intended for users who are **18 years of age or older**. We do not knowingly collect personal information from anyone under 18. If you are under 18, please do not use the Platform or provide any information to us.

If we learn that we have collected personal information from a user under 18, we will promptly delete that information. If you believe we may have inadvertently collected information from a minor, please contact us at **privacy@hustlexp.app**.

---

## 8. Third-Party Links and Services

The Platform may contain links to third-party websites or services. This Privacy Policy does not apply to those third parties, and we are not responsible for their privacy practices. We encourage you to review the privacy policies of any third-party services you access.

---

## 9. Push Notifications

We send push notifications via Firebase Cloud Messaging. You can manage push notification preferences at any time through your iOS device settings (Settings > Notifications > HustleXP) or through the notification settings in the HustleXP app.

Disabling push notifications will not affect your ability to use the Platform, but you may miss time-sensitive alerts about task activity and payments.

---

## 10. Changes to This Privacy Policy

We may update this Privacy Policy from time to time to reflect changes in our practices, technology, legal requirements, or other factors. When we make material changes, we will:
- Update the "Last Updated" date at the top of this policy
- Notify you via in-app notification or email at least 30 days before the changes take effect (for material changes)
- For significant changes to how we use your personal information, we may request your renewed consent

Your continued use of the Platform after the effective date of any changes constitutes your acceptance of the updated policy. If you do not agree to the updated policy, you may close your account and discontinue use of the Platform.

---

## 11. Contact Us

If you have questions, concerns, or requests regarding this Privacy Policy or our data practices, please contact us:

**HustleXP Inc.**
Privacy Team
Email: **privacy@hustlexp.app**

For data subject access requests and privacy-related inquiries, please include your full name and the email address associated with your HustleXP account so that we can verify your identity and respond appropriately.

We will respond to all legitimate privacy inquiries within a commercially reasonable time, and within the timeframes required by applicable law.

---

*This Privacy Policy was last updated on [INSERT DATE BEFORE PUBLISHING].*
