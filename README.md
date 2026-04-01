# HUSTLEXPFINAL1

> iOS and mobile client for **HustleXP** — a gamified hyperlocal task marketplace.
> Dual-architecture: React Native (Expo) + native Swift/SwiftUI.

[![Build](https://img.shields.io/badge/Build-CI_Passing-green)]()
[![E2E Tests](https://img.shields.io/badge/E2E_Tests-ZERO-red)]()
[![Security](https://img.shields.io/badge/Security-5_Open_Findings-red)]()
[![Architecture](https://img.shields.io/badge/Architecture-Dual_RN%2BSwift-yellow)]()

---

## Current Status (April 2026)

| Domain | Status | Detail |
|--------|--------|--------|
| Build | CI PASSING | ios-ci.yml + contract-validation.yml green |
| E2E Tests | ZERO | No end-to-end test coverage |
| Security | 5 OPEN FINDINGS | 2 Critical, 3 High — see below |
| Architecture | DUAL (RN + Swift) | Decision pending: single path or both? |
| Backend Integration | PARTIAL | Targeting hustlexp-ai-backend (23 frozen endpoints) |

**All known issues tracked in [HUSTLEXP-ERRORS-AND-TODOS](https://github.com/Sebdysart/HUSTLEXP-ERRORS-AND-TODOS)**

---

## Architecture

This repo contains **two parallel client implementations**:

### React Native / Expo (`HustleXP/` directory)
- React 19.2.0, React Native 0.83.1 (Hermes engine)
- Expo 52.0.0, TypeScript 5.8.3
- Firebase Auth + Google/Apple Sign-In
- Stripe payments (`@stripe/stripe-react-native`)
- tRPC backend client

### Native Swift / SwiftUI (`hustleXP final1/` directory)
- 54 Swift services
- 66 Swift screens (organized by 8 Xcode categories)
- 14 data models
- Cloudflare R2 storage integration

### Architecture Decision Pending

The dual approach doubles maintenance cost. A decision is needed: React Native only, Swift only, or both. This is tracked as DEC-002 in [HUSTLEXP-ERRORS-AND-TODOS](https://github.com/Sebdysart/HUSTLEXP-ERRORS-AND-TODOS).

---

## Security Findings (5 Open)

| ID | Finding | Severity | Status |
|----|---------|----------|--------|
| SEC-001 | SSL certificate pin hashes are **placeholders** — MITM vulnerability | **CRITICAL** | OPEN |
| SEC-002 | **Zero E2E tests** — no regression safety net for payment flow | **CRITICAL** | OPEN |
| SEC-003 | Firebase Crashlytics **commented out** — no crash reporting | HIGH | OPEN |
| SEC-004 | **No input validation** on user-facing forms — injection risk | HIGH | OPEN |
| SEC-005 | Production logging **100% disabled** — blind operations | HIGH | OPEN |

---

## CI/CD

Two GitHub Actions workflows (non-blocking):
- `ios-ci.yml` — Build and test on macOS with iPhone 16 simulator
- `contract-validation.yml` — tRPC coverage validation against backend contract

---

## Open PRs & Issues

| Type | # | Title | Status |
|------|---|-------|--------|
| PR | #5 | Principal Architect Diagnostic Report | DRAFT, CI passing, 10+ days old |
| Issue | #3 | Ghost Hunter — missing endpoints | Open |
| Issue | #2 | CLAWBOT Alert — autonomous monitoring | Open |
| Issue | #1 | CLAWBOT v3.0 Health Check | Open |

---

## Backend Connection

This client targets **[hustlexp-ai-backend](https://github.com/Sebdysart/hustlexp-ai-backend)** — the production backend built with Hono + tRPC, featuring 85 services, 50 routers, and 290+ procedures. Deployed on Railway with 103 tables on Neon PostgreSQL. Includes 5,448 tests and 4 CI/CD workflows. The API contract is defined in `UI_CONTRACT.md` in that repo.

---

## What's NOT Done Yet

- Replace placeholder SSL pin hashes with real certificate pins
- Enable Crashlytics and production logging
- Implement input validation
- Write E2E tests for the full payment path
- Decide single-architecture path (RN vs Swift)

See the full roadmap in [HUSTLEXP-ERRORS-AND-TODOS](https://github.com/Sebdysart/HUSTLEXP-ERRORS-AND-TODOS).

---

## Related Repos

| Repo | Role |
|------|------|
| [hustlexp-ai-backend](https://github.com/Sebdysart/hustlexp-ai-backend) | Production Backend |
| [omni-link-hustlexp](https://github.com/Sebdysart/omni-link-hustlexp) | Engineering Control Plane |
| [HUSTLEXP-DOCS](https://github.com/Sebdysart/HUSTLEXP-DOCS) | Documentation Authority |
| [HUSTLEXP-ERRORS-AND-TODOS](https://github.com/Sebdysart/HUSTLEXP-ERRORS-AND-TODOS) | Error & Todo Tracker |
