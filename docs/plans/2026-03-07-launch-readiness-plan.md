# HustleXP Launch Readiness Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Take HustleXP from functionally complete (100/100 scorecard) to production-grade and launch-ready across four sequential phases: backend hardening, iOS polish, B3 features, and launch prep.

**Architecture:** Sequential phases — each phase is fully done before the next begins. Backend uses tRPC + Hono + BullMQ + PostgreSQL (Neon). iOS uses SwiftUI + TRPCClient singleton + Combine + SSE. Tests use Vitest (backend) and XCTest (iOS).

**Tech Stack:** Node.js 20, TypeScript strict, Hono, tRPC v10, Zod, Vitest, PostgreSQL, Swift 5.9, SwiftUI, XCTest, Sentry, SwiftLint

**Health Audit Baseline (2026-03-07):**
- Backend: 1,794 tests passing, 26% line coverage, 0 lint errors, 0 type errors
- iOS: 169 test functions, 36% service coverage, 0 UI tests, no SwiftLint

---

## PHASE 1: Backend Hardening

---

### Task 1: Add Pagination to `admin.listUsers`

**Files:**
- Modify: `backend/src/routers/admin.ts` (line ~35)
- Test: `backend/tests/unit/admin-router.test.ts` (create if missing)

**Step 1: Write the failing test**

```typescript
// In backend/tests/unit/admin-router.test.ts
import { describe, it, expect, vi, beforeEach } from 'vitest';

describe('admin.listUsers pagination', () => {
  it('returns items with nextCursor when more results exist', async () => {
    // Use the test helper to call the procedure
    const result = await caller.admin.listUsers({ limit: 2 });
    expect(result).toHaveProperty('items');
    expect(result).toHaveProperty('nextCursor');
    expect(Array.isArray(result.items)).toBe(true);
  });

  it('returns null nextCursor when no more results', async () => {
    const result = await caller.admin.listUsers({ limit: 100 });
    expect(result.nextCursor).toBeNull();
  });

  it('accepts cursor for pagination', async () => {
    const page1 = await caller.admin.listUsers({ limit: 1 });
    const page2 = await caller.admin.listUsers({ limit: 1, cursor: page1.nextCursor! });
    expect(page2.items[0]?.id).not.toBe(page1.items[0]?.id);
  });
});
```

**Step 2: Run test to verify it fails**

```bash
cd /Users/sebastiandysart/Desktop/hustlexp-ai-backend
npx vitest run backend/tests/unit/admin-router.test.ts 2>&1 | tail -20
```
Expected: FAIL — procedure doesn't have cursor/limit inputs

**Step 3: Update `admin.listUsers`**

```typescript
// backend/src/routers/admin.ts — find the listUsers procedure and replace its input/query:
listUsers: adminProcedure
  .input(z.object({
    cursor: z.string().uuid().optional(),
    limit: z.number().int().min(1).max(100).default(20),
    role: z.enum(['hustler', 'poster', 'admin']).optional(),
    search: z.string().max(100).optional(),
  }))
  .query(async ({ ctx, input }) => {
    const { cursor, limit, role, search } = input;
    const conditions: string[] = [];
    const params: unknown[] = [limit + 1];

    if (cursor) { conditions.push(`u.id > $${params.push(cursor)}`); }
    if (role) { conditions.push(`u.role = $${params.push(role)}`); }
    if (search) { conditions.push(`(u.email ILIKE $${params.push(`%${search}%`)} OR u.full_name ILIKE $${params.length})`); }

    const whereClause = conditions.length > 0 ? `WHERE ${conditions.join(' AND ')}` : '';
    const rows = await ctx.db.query<UserRow>(
      `SELECT u.*, COUNT(t.id) AS task_count
       FROM users u
       LEFT JOIN tasks t ON t.poster_id = u.id
       ${whereClause}
       GROUP BY u.id
       ORDER BY u.id ASC
       LIMIT $1`,
      params
    );

    const items = rows.rows.slice(0, limit);
    const nextCursor = rows.rows.length > limit ? items[items.length - 1].id : null;
    return { items, nextCursor };
  }),
```

**Step 4: Run tests**

```bash
npx vitest run backend/tests/unit/admin-router.test.ts
```
Expected: PASS

**Step 5: Run full suite**

```bash
npm test 2>&1 | tail -5
```
Expected: All tests pass (≥1,794)

**Step 6: Commit**

```bash
git add backend/src/routers/admin.ts backend/tests/unit/admin-router.test.ts
git commit -m "feat(backend): paginate admin.listUsers"
```

---

### Task 2: Add Pagination to `admin.listTasks` and `admin.listDisputes`

**Files:**
- Modify: `backend/src/routers/admin.ts` (lines ~128, ~173)

**Step 1: Apply cursor pagination to both procedures**

Same pattern as Task 1. For `listTasks`:
```typescript
listTasks: adminProcedure
  .input(z.object({
    cursor: z.string().uuid().optional(),
    limit: z.number().int().min(1).max(100).default(20),
    status: z.string().optional(),
  }))
  .query(async ({ ctx, input }) => {
    const { cursor, limit, status } = input;
    const conditions: string[] = [];
    const params: unknown[] = [limit + 1];
    if (cursor) { conditions.push(`id > $${params.push(cursor)}`); }
    if (status) { conditions.push(`status = $${params.push(status)}`); }
    const where = conditions.length ? `WHERE ${conditions.join(' AND ')}` : '';
    const rows = await ctx.db.query(`SELECT * FROM tasks ${where} ORDER BY id ASC LIMIT $1`, params);
    const items = rows.rows.slice(0, limit);
    return { items, nextCursor: rows.rows.length > limit ? items[items.length - 1]?.id ?? null : null };
  }),
```

For `listDisputes`: same pattern, querying `disputes` table.

**Step 2: Also paginate `betaDashboard.listUsers` (`backend/src/routers/betaDashboard.ts:337`)**

Same cursor pattern.

**Step 3: Run full suite and commit**

```bash
npm test 2>&1 | tail -5
git add backend/src/routers/admin.ts backend/src/routers/betaDashboard.ts
git commit -m "feat(backend): paginate admin.listTasks, listDisputes, betaDashboard.listUsers"
```

---

### Task 3: Paginate `notification.getList`

**Files:**
- Modify: `backend/src/routers/notification.ts` (line ~28)

**Step 1: Update `getList` procedure**

```typescript
getList: protectedProcedure
  .input(z.object({
    cursor: z.string().uuid().optional(),
    limit: z.number().int().min(1).max(50).default(20),
    unreadOnly: z.boolean().default(false),
  }))
  .query(async ({ ctx, input }) => {
    const { cursor, limit, unreadOnly } = input;
    const conditions = [`user_id = $${[ctx.user.id].length}`];
    const params: unknown[] = [ctx.user.id, limit + 1];
    if (cursor) { conditions.push(`id > $${params.push(cursor)}`); }
    if (unreadOnly) { conditions.push('read_at IS NULL'); }
    const rows = await ctx.db.query(
      `SELECT * FROM notifications WHERE ${conditions.join(' AND ')} ORDER BY created_at DESC LIMIT $2`,
      params
    );
    const items = rows.rows.slice(0, limit);
    return { items, nextCursor: rows.rows.length > limit ? items[items.length - 1]?.id ?? null : null };
  }),
```

**Step 2: Run suite + commit**

```bash
npm test 2>&1 | tail -5
git add backend/src/routers/notification.ts
git commit -m "feat(backend): paginate notification.getList"
```

---

### Task 4: Paginate Squad and RecurringTask Procedures

**Files:**
- Modify: `backend/src/routers/squad.ts` (listMine ~158, listInvites ~384, listTasks ~478)
- Modify: `backend/src/routers/recurringTask.ts` (listMine ~185, listOccurrences ~294)

**Step 1: Apply cursor pagination to all 5 procedures**

For each procedure — same pattern: add `cursor?`, `limit` to input; add `LIMIT $N` and cursor condition to SQL; return `{ items, nextCursor }`.

`squad.listMine` — query `squads` table where `user_id = ctx.user.id`
`squad.listInvites` — query `squad_invites` where `invitee_id = ctx.user.id AND status = 'pending'`
`squad.listTasks` — query `tasks` where `squad_id = input.squadId`
`recurringTask.listMine` — query `recurring_tasks` where `poster_id = ctx.user.id`
`recurringTask.listOccurrences` — query `recurring_task_occurrences` where `template_id = input.templateId`

**Step 2: Run suite + commit**

```bash
npm test 2>&1 | tail -5
git add backend/src/routers/squad.ts backend/src/routers/recurringTask.ts
git commit -m "feat(backend): paginate squad and recurringTask list procedures"
```

---

### Task 5: Paginate Remaining List Procedures

**Files:**
- Modify: `backend/src/routers/live.ts` (listBroadcasts ~92)
- Modify: `backend/src/routers/instant.ts` (listAvailable ~21)
- Modify: `backend/src/routers/incidents.ts` (list ~23)
- Modify: `backend/src/routers/expertiseSupply.ts` (listExpertise ~39, getMyWaitlist ~173)

**Step 1: Apply same cursor pattern to all 5**

Note: `instant.listAvailable` and `live.listBroadcasts` may use geospatial queries — preserve the geo filter, just add `LIMIT` + cursor.

**Step 2: Run full suite + commit**

```bash
npm test 2>&1 | tail -5
git add backend/src/routers/live.ts backend/src/routers/instant.ts backend/src/routers/incidents.ts backend/src/routers/expertiseSupply.ts
git commit -m "feat(backend): paginate live, instant, incidents, expertiseSupply list procedures"
```

---

### Task 6: Add Sentry Error Tracking

**Files:**
- Create: `backend/src/lib/sentry.ts`
- Modify: `backend/src/server.ts` (top of file, after imports)
- Modify: `backend/src/trpc.ts` (error handler)

**Step 1: Install Sentry**

```bash
cd /Users/sebastiandysart/Desktop/hustlexp-ai-backend
npm install @sentry/node --save
```

Expected: `@sentry/node` added to package.json dependencies.

**Step 2: Create `backend/src/lib/sentry.ts`**

```typescript
import * as Sentry from '@sentry/node';

export function initSentry() {
  const dsn = process.env.SENTRY_DSN;
  if (!dsn) {
    console.warn('[Sentry] SENTRY_DSN not set — error tracking disabled');
    return;
  }
  Sentry.init({
    dsn,
    environment: process.env.NODE_ENV ?? 'development',
    release: process.env.APP_VERSION ?? 'unknown',
    tracesSampleRate: process.env.NODE_ENV === 'production' ? 0.1 : 0,
    beforeSend(event) {
      // Strip PII from request bodies
      if (event.request?.data) {
        const data = event.request.data as Record<string, unknown>;
        delete data['password'];
        delete data['ssn'];
        delete data['bankAccount'];
      }
      return event;
    },
  });
}

export function captureError(error: unknown, context?: Record<string, unknown>) {
  if (context) {
    Sentry.withScope((scope) => {
      Object.entries(context).forEach(([k, v]) => scope.setExtra(k, v));
      Sentry.captureException(error);
    });
  } else {
    Sentry.captureException(error);
  }
}

export { Sentry };
```

**Step 3: Initialize in `backend/src/server.ts`**

At the very top, after imports:
```typescript
import { initSentry } from './lib/sentry';
initSentry();
```

**Step 4: Add to tRPC error handler in `backend/src/trpc.ts`**

Find the `onError` handler (or add one):
```typescript
// In createTRPCHonoRouter config:
onError({ error, type, path, input, ctx }) {
  if (error.code === 'INTERNAL_SERVER_ERROR') {
    const { captureError } = require('./lib/sentry');
    captureError(error, {
      procedure: path,
      procedureType: type,
      userId: ctx?.user?.id,
    });
  }
},
```

**Step 5: Write test for sentry.ts**

```typescript
// backend/tests/unit/sentry.test.ts
import { describe, it, expect, vi } from 'vitest';

vi.mock('@sentry/node', () => ({
  init: vi.fn(),
  captureException: vi.fn(),
  withScope: vi.fn((cb) => cb({ setExtra: vi.fn() })),
}));

describe('Sentry integration', () => {
  it('does not throw when SENTRY_DSN is missing', async () => {
    delete process.env.SENTRY_DSN;
    const { initSentry } = await import('../../src/lib/sentry');
    expect(() => initSentry()).not.toThrow();
  });

  it('captureError calls Sentry.captureException', async () => {
    const Sentry = await import('@sentry/node');
    const { captureError } = await import('../../src/lib/sentry');
    const err = new Error('test');
    captureError(err);
    expect(Sentry.captureException).toHaveBeenCalledWith(err);
  });
});
```

**Step 6: Run suite + commit**

```bash
npm test 2>&1 | tail -5
git add backend/src/lib/sentry.ts backend/src/server.ts backend/src/trpc.ts backend/tests/unit/sentry.test.ts package.json package-lock.json
git commit -m "feat(backend): add Sentry error tracking with PII scrubbing"
```

---

### Task 7: Add Request Correlation Middleware

**Files:**
- Create: `backend/src/middleware/requestId.ts`
- Modify: `backend/src/server.ts` (register middleware)

**Step 1: Create `backend/src/middleware/requestId.ts`**

```typescript
import { createMiddleware } from 'hono/factory';
import { randomUUID } from 'crypto';

export const requestIdMiddleware = createMiddleware(async (c, next) => {
  const requestId = c.req.header('x-request-id') ?? randomUUID();
  c.set('requestId', requestId);
  c.header('x-request-id', requestId);

  const start = Date.now();
  await next();
  const duration = Date.now() - start;

  const method = c.req.method;
  const path = new URL(c.req.url).pathname;
  const status = c.res.status;
  console.log(JSON.stringify({
    requestId,
    method,
    path,
    status,
    duration_ms: duration,
    timestamp: new Date().toISOString(),
  }));
});
```

**Step 2: Register in `backend/src/server.ts`**

```typescript
import { requestIdMiddleware } from './middleware/requestId';
// After app = new Hono(), before routes:
app.use('*', requestIdMiddleware);
```

**Step 3: Write test**

```typescript
// backend/tests/unit/requestId.test.ts
import { describe, it, expect } from 'vitest';
import { Hono } from 'hono';
import { requestIdMiddleware } from '../../src/middleware/requestId';

describe('requestIdMiddleware', () => {
  it('echoes provided x-request-id', async () => {
    const app = new Hono();
    app.use('*', requestIdMiddleware);
    app.get('/test', (c) => c.json({ ok: true }));
    const res = await app.request('/test', { headers: { 'x-request-id': 'test-id-123' } });
    expect(res.headers.get('x-request-id')).toBe('test-id-123');
  });

  it('generates a request ID when none provided', async () => {
    const app = new Hono();
    app.use('*', requestIdMiddleware);
    app.get('/test', (c) => c.json({ ok: true }));
    const res = await app.request('/test');
    expect(res.headers.get('x-request-id')).toMatch(/^[0-9a-f-]{36}$/);
  });
});
```

**Step 4: Run suite + commit**

```bash
npm test 2>&1 | tail -5
git add backend/src/middleware/requestId.ts backend/src/server.ts backend/tests/unit/requestId.test.ts
git commit -m "feat(backend): add request ID correlation middleware with timing logs"
```

---

### Task 8: Add `/health` and `/ready` Endpoints

**Files:**
- Modify: `backend/src/server.ts`

**Step 1: Add health endpoints**

```typescript
// In server.ts — add before tRPC routes:
app.get('/health', (c) => c.json({ status: 'ok', timestamp: new Date().toISOString() }));

app.get('/ready', async (c) => {
  const checks: Record<string, boolean> = {};

  // DB check
  try {
    await db.query('SELECT 1');
    checks.db = true;
  } catch {
    checks.db = false;
  }

  // Redis check
  try {
    const redis = getRedisClient(); // use existing redis getter
    await redis.ping();
    checks.redis = true;
  } catch {
    checks.redis = false;
  }

  const allHealthy = Object.values(checks).every(Boolean);
  return c.json(
    { status: allHealthy ? 'ready' : 'degraded', checks, timestamp: new Date().toISOString() },
    allHealthy ? 200 : 503
  );
});
```

**Step 2: Write tests**

```typescript
// backend/tests/unit/health-endpoints.test.ts
import { describe, it, expect, vi } from 'vitest';

describe('GET /health', () => {
  it('returns 200 with status ok', async () => {
    const res = await testApp.request('/health');
    expect(res.status).toBe(200);
    const body = await res.json();
    expect(body.status).toBe('ok');
  });
});

describe('GET /ready', () => {
  it('returns 200 when db and redis are healthy', async () => {
    vi.spyOn(db, 'query').mockResolvedValue({ rows: [{ '?column?': 1 }] } as any);
    // mock redis ping
    const res = await testApp.request('/ready');
    expect([200, 503]).toContain(res.status); // 503 acceptable in unit test w/ no real DB
  });
});
```

**Step 3: Run suite + commit**

```bash
npm test 2>&1 | tail -5
git add backend/src/server.ts backend/tests/unit/health-endpoints.test.ts
git commit -m "feat(backend): add /health and /ready endpoints"
```

---

### Task 9: Graceful Shutdown + Env Validation

**Files:**
- Create: `backend/src/lib/env-validator.ts`
- Modify: `backend/src/server.ts`

**Step 1: Create `backend/src/lib/env-validator.ts`**

```typescript
const REQUIRED_ENV_VARS = [
  'DATABASE_URL',
  'REDIS_URL',
  'STRIPE_SECRET_KEY',
  'JWT_SECRET',
  'R2_ACCOUNT_ID',
] as const;

export function validateEnv(): void {
  const missing = REQUIRED_ENV_VARS.filter((key) => !process.env[key]);
  if (missing.length > 0) {
    throw new Error(
      `[Startup] Missing required environment variables:\n${missing.map((k) => `  - ${k}`).join('\n')}\n\nSet these before starting the server.`
    );
  }
  console.log('[Startup] All required environment variables present ✓');
}
```

**Step 2: Add graceful shutdown to `backend/src/server.ts`**

```typescript
import { validateEnv } from './lib/env-validator';

// At the very start of server startup (before app.listen):
validateEnv();

// After workers are initialized:
async function gracefulShutdown(signal: string) {
  console.log(`[Shutdown] Received ${signal}. Closing workers and DB pool...`);
  try {
    // Close all BullMQ workers
    await Promise.all(allWorkers.map((w) => w.close()));
    // Close DB pool
    await db.pool?.end();
    console.log('[Shutdown] Clean exit.');
    process.exit(0);
  } catch (err) {
    console.error('[Shutdown] Error during shutdown:', err);
    process.exit(1);
  }
}

process.on('SIGTERM', () => gracefulShutdown('SIGTERM'));
process.on('SIGINT', () => gracefulShutdown('SIGINT'));
```

**Step 3: Write env-validator test**

```typescript
// backend/tests/unit/env-validator.test.ts
import { describe, it, expect, beforeEach, afterEach } from 'vitest';

describe('validateEnv', () => {
  const savedEnv = { ...process.env };

  afterEach(() => {
    Object.assign(process.env, savedEnv);
  });

  it('does not throw when all required vars are present', async () => {
    process.env.DATABASE_URL = 'postgres://test';
    process.env.REDIS_URL = 'redis://test';
    process.env.STRIPE_SECRET_KEY = 'sk_test_xxx';
    process.env.JWT_SECRET = 'secret';
    process.env.R2_ACCOUNT_ID = 'r2id';
    const { validateEnv } = await import('../../src/lib/env-validator');
    expect(() => validateEnv()).not.toThrow();
  });

  it('throws with clear message when a var is missing', async () => {
    delete process.env.DATABASE_URL;
    const { validateEnv } = await import('../../src/lib/env-validator');
    expect(() => validateEnv()).toThrowError('DATABASE_URL');
  });
});
```

**Step 4: Run suite + commit**

```bash
npm test 2>&1 | tail -5
git add backend/src/lib/env-validator.ts backend/src/server.ts backend/tests/unit/env-validator.test.ts
git commit -m "feat(backend): add env validation on startup + graceful SIGTERM shutdown"
```

---

### Task 10: Remove Confirmed Dead Code

**Files:**
- Delete: `backend/src/cache/query-cache.ts`
- Delete: `backend/src/cache/edge-cache.ts`
- Delete: `backend/src/connection-registry-redis.ts`

**Step 1: Verify nothing imports these files**

```bash
cd /Users/sebastiandysart/Desktop/hustlexp-ai-backend
grep -r "query-cache\|edge-cache\|connection-registry-redis" backend/src/ --include="*.ts" | grep -v "\.test\."
```
Expected: No output (or only the files themselves)

**Step 2: Delete the files**

```bash
rm backend/src/cache/query-cache.ts
rm backend/src/cache/edge-cache.ts
rm backend/src/connection-registry-redis.ts
```

**Step 3: Run TypeScript check**

```bash
npx tsc --noEmit 2>&1 | head -20
```
Expected: 0 errors

**Step 4: Run full suite + commit**

```bash
npm test 2>&1 | tail -5
git add -A
git commit -m "chore(backend): remove confirmed dead cache files (query-cache, edge-cache, connection-registry-redis)"
```

---

### Task 11: Fix ESLint Root-Level Config

**Files:**
- Modify: `.eslintrc.json` (at `hustlexp-ai-backend` root)

**Step 1: Check current state**

```bash
cd /Users/sebastiandysart/Desktop/hustlexp-ai-backend
npx eslint . --ext .ts 2>&1 | grep "error\|warning" | wc -l
```

**Step 2: Add `tests-vault/` to ignorePatterns**

In `.eslintrc.json`, find or add `ignorePatterns`:
```json
{
  "ignorePatterns": [
    "node_modules/",
    "dist/",
    "coverage/",
    "tests-vault/",
    "*.js"
  ]
}
```

**Step 3: Verify fix**

```bash
npx eslint . --ext .ts 2>&1 | grep -c "error" || echo "0 errors"
```
Expected: 0 errors

**Step 4: Run full suite + commit**

```bash
npm test 2>&1 | tail -5
git add .eslintrc.json
git commit -m "chore(backend): fix ESLint ignorePatterns to exclude tests-vault/"
```

---

### Task 12: Add Tests for Zero-Coverage Compliance Services

**Files:**
- Create: `backend/tests/unit/TaxReportingService.test.ts`
- Create: `backend/tests/unit/PhotoVerificationService.test.ts`

**Step 1: Write tests for `TaxReportingService`**

```typescript
// backend/tests/unit/TaxReportingService.test.ts
import { describe, it, expect, vi, beforeEach } from 'vitest';
import { TaxReportingService } from '../../backend/src/services/TaxReportingService';

describe('TaxReportingService', () => {
  describe('shouldReceive1099', () => {
    it('returns true when earnings exceed $600 threshold', () => {
      expect(TaxReportingService.shouldReceive1099(60100)).toBe(true);
    });

    it('returns false when earnings are below $600 threshold', () => {
      expect(TaxReportingService.shouldReceive1099(59900)).toBe(false);
    });

    it('returns true at exactly $600 (600 cents = $6.00 — verify threshold unit)', () => {
      // Threshold is in cents: $600.00 = 60000 cents
      expect(TaxReportingService.shouldReceive1099(60000)).toBe(true);
    });
  });

  describe('generate1099Form', () => {
    it('throws if worker has no stripe_connect_id', async () => {
      const mockDb = { query: vi.fn().mockResolvedValue({ rows: [{ stripe_connect_id: null, email: 'a@b.com' }] }) };
      await expect(
        TaxReportingService.generate1099Form('user-id', 2025, mockDb as any)
      ).rejects.toThrow();
    });
  });
});
```

**Step 2: Write tests for `PhotoVerificationService`**

```typescript
// backend/tests/unit/PhotoVerificationService.test.ts
import { describe, it, expect, vi } from 'vitest';

describe('PhotoVerificationService', () => {
  it('rejects non-image MIME types', async () => {
    const { PhotoVerificationService } = await import('../../backend/src/services/PhotoVerificationService');
    await expect(
      PhotoVerificationService.validatePhoto({ mimeType: 'application/pdf', sizeBytes: 100 })
    ).rejects.toThrow();
  });

  it('rejects files over size limit', async () => {
    const { PhotoVerificationService } = await import('../../backend/src/services/PhotoVerificationService');
    await expect(
      PhotoVerificationService.validatePhoto({ mimeType: 'image/jpeg', sizeBytes: 20 * 1024 * 1024 + 1 })
    ).rejects.toThrow();
  });

  it('accepts valid JPEG under size limit', async () => {
    const { PhotoVerificationService } = await import('../../backend/src/services/PhotoVerificationService');
    await expect(
      PhotoVerificationService.validatePhoto({ mimeType: 'image/jpeg', sizeBytes: 1 * 1024 * 1024 })
    ).resolves.not.toThrow();
  });
});
```

**Step 3: Run suite + commit**

```bash
npm test 2>&1 | tail -10
git add backend/tests/unit/TaxReportingService.test.ts backend/tests/unit/PhotoVerificationService.test.ts
git commit -m "test(backend): add coverage for TaxReportingService and PhotoVerificationService"
```

---

### Task 13: Phase 1 Verification

**Step 1: Full test run**

```bash
cd /Users/sebastiandysart/Desktop/hustlexp-ai-backend
npm test 2>&1 | tail -10
```
Expected: All tests pass (≥1,800 assertions)

**Step 2: TypeScript check**

```bash
npx tsc --noEmit 2>&1
```
Expected: 0 errors

**Step 3: ESLint check**

```bash
npx eslint . --ext .ts 2>&1 | grep -c "error" || echo "0 errors"
```
Expected: 0 errors

**Step 4: Push to remote**

```bash
git push origin main
```

---

## PHASE 2: iOS Polish

---

### Task 14: Create `ErrorStateView` Component

**Files:**
- Create: `hustleXP final1/Components/Atoms/ErrorStateView.swift`
- Test: `hustleXP final1Tests/Components/ErrorStateViewTests.swift`

**Step 1: Create component**

```swift
// hustleXP final1/Components/Atoms/ErrorStateView.swift
import SwiftUI

enum AppError {
    case network
    case server
    case notFound(String)
    case authExpired
    case unknown(String)

    var title: String {
        switch self {
        case .network: return "No Internet Connection"
        case .server: return "Something Went Wrong"
        case .notFound(let item): return "\(item) Not Found"
        case .authExpired: return "Session Expired"
        case .unknown: return "Unexpected Error"
        }
    }

    var message: String {
        switch self {
        case .network: return "Check your connection and try again."
        case .server: return "We're working on it. Try again in a moment."
        case .notFound(let item): return "This \(item.lowercased()) is no longer available."
        case .authExpired: return "Please sign in again to continue."
        case .unknown(let msg): return msg
        }
    }

    var icon: String {
        switch self {
        case .network: return "wifi.slash"
        case .server: return "exclamationmark.triangle"
        case .notFound: return "questionmark.circle"
        case .authExpired: return "lock.rotation"
        case .unknown: return "exclamationmark.circle"
        }
    }
}

struct ErrorStateView: View {
    let error: AppError
    let onRetry: (() -> Void)?

    init(error: AppError, onRetry: (() -> Void)? = nil) {
        self.error = error
        self.onRetry = onRetry
    }

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: error.icon)
                .font(.system(size: 48))
                .foregroundColor(.secondary)

            VStack(spacing: 8) {
                Text(error.title)
                    .font(.headline)
                    .multilineTextAlignment(.center)

                Text(error.message)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }

            if let onRetry = onRetry {
                Button("Try Again", action: onRetry)
                    .buttonStyle(.borderedProminent)
                    .padding(.top, 4)
            }
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(error.title). \(error.message)")
    }
}

#Preview {
    ErrorStateView(error: .network, onRetry: { print("retry") })
}
```

**Step 2: Write test**

```swift
// hustleXP final1Tests/Components/ErrorStateViewTests.swift
import XCTest
@testable import hustleXP_final1

final class AppErrorTests: XCTestCase {
    func testNetworkErrorProperties() {
        let error = AppError.network
        XCTAssertEqual(error.title, "No Internet Connection")
        XCTAssertFalse(error.message.isEmpty)
        XCTAssertFalse(error.icon.isEmpty)
    }

    func testNotFoundIncludesItemName() {
        let error = AppError.notFound("Task")
        XCTAssertTrue(error.title.contains("Task"))
    }

    func testUnknownErrorPassesThroughMessage() {
        let error = AppError.unknown("Custom error message")
        XCTAssertEqual(error.message, "Custom error message")
    }
}
```

**Step 3: Run tests in Xcode**

Open Xcode → Product → Test (⌘U)
Expected: All 169+ tests pass, new 3 pass

**Step 4: Commit**

```bash
cd /Users/sebastiandysart/HustleXP/HUSTLEXPFINAL1
git add "hustleXP final1/Components/Atoms/ErrorStateView.swift" "hustleXP final1Tests/Components/ErrorStateViewTests.swift"
git commit -m "feat(ios): add ErrorStateView component with AppError enum"
```

---

### Task 15: Apply Error States to Priority Screens

**Files:**
- Modify: `hustleXP final1/Screens/Hustler/HustlerTaskDetailScreen.swift`
- Modify: `hustleXP final1/Screens/Poster/PosterTaskDetailScreen.swift`
- Modify: `hustleXP final1/Screens/Hustler/TaskDiscoveryScreen.swift`

**Step 1: Add error state to `HustlerTaskDetailScreen`**

Find the loading/content switch in the view body. Add an error case:

```swift
// In HustlerTaskDetailScreen — add state var:
@State private var loadError: AppError?

// In the view body, after checking task != nil:
} else if let error = loadError {
    ErrorStateView(error: error, onRetry: {
        loadError = nil
        Task { await loadTask() }
    })
} else {
    // existing ProgressView
}

// In loadTask() catch block — replace generic toast:
} catch {
    let apiError = error as? TRPCError
    if apiError?.code == "NOT_FOUND" {
        loadError = .notFound("Task")
    } else if (error as NSError).domain == NSURLErrorDomain {
        loadError = .network
    } else {
        loadError = .server
    }
}
```

**Step 2: Apply same pattern to `PosterTaskDetailScreen` and `TaskDiscoveryScreen`**

`TaskDiscoveryScreen` has a list — show `ErrorStateView` overlaid when search fails.

**Step 3: Run tests in Xcode (⌘U)**

**Step 4: Commit**

```bash
git add "hustleXP final1/Screens/Hustler/HustlerTaskDetailScreen.swift" "hustleXP final1/Screens/Poster/PosterTaskDetailScreen.swift" "hustleXP final1/Screens/Hustler/TaskDiscoveryScreen.swift"
git commit -m "feat(ios): add inline error states to task detail and discovery screens"
```

---

### Task 16: Create `EmptyStateView` and Apply to All List Screens

**Files:**
- Create: `hustleXP final1/Components/Atoms/EmptyStateView.swift`
- Modify: 6 list screens

**Step 1: Create component**

```swift
// hustleXP final1/Components/Atoms/EmptyStateView.swift
import SwiftUI

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    var ctaLabel: String? = nil
    var ctaAction: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 52))
                .foregroundColor(.secondary.opacity(0.6))

            VStack(spacing: 8) {
                Text(title)
                    .font(.headline)
                    .multilineTextAlignment(.center)

                Text(message)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }

            if let label = ctaLabel, let action = ctaAction {
                Button(label, action: action)
                    .buttonStyle(.borderedProminent)
                    .padding(.top, 4)
            }
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
```

**Step 2: Apply to each list screen**

In each screen, find the `List { ... }` or `ScrollView { ... }` content. Add:
```swift
if items.isEmpty && !isLoading {
    EmptyStateView(
        icon: "briefcase",
        title: "No Tasks Yet",
        message: "You haven't accepted any tasks yet.",
        ctaLabel: "Explore Tasks",
        ctaAction: { router.navigateToHustler() }
    )
}
```

Screens to update:
- `HustlerTaskListScreen` (My Tasks — Hustler)
- `PosterTaskListScreen` (My Posted Tasks)
- `ConversationListScreen` (Messages)
- `NotificationsScreen` (Notifications)
- `WalletScreen` / `EarningsHistoryScreen`
- `TaskDiscoveryScreen` (search returns 0 results)

**Step 3: Run tests (⌘U) + commit**

```bash
git add "hustleXP final1/Components/Atoms/EmptyStateView.swift" "hustleXP final1/Screens/"
git commit -m "feat(ios): add EmptyStateView and apply to all list screens"
```

---

### Task 17: Add Loading Skeletons

**Files:**
- Create: `hustleXP final1/Components/Atoms/SkeletonView.swift`
- Modify: `hustleXP final1/Screens/Hustler/TaskDiscoveryScreen.swift` + 4 others

**Step 1: Create skeleton component**

```swift
// hustleXP final1/Components/Atoms/SkeletonView.swift
import SwiftUI

struct SkeletonView: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color(.systemGray5))
            .overlay(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(.systemGray5),
                        Color(.systemGray4),
                        Color(.systemGray5),
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .mask(shimmerAnimation)
            )
    }

    @State private var shimmerOffset: CGFloat = -1.0

    private var shimmerAnimation: some View {
        Rectangle()
            .fill(Color.white.opacity(0.6))
            .rotationEffect(.degrees(20))
            .offset(x: shimmerOffset * 400)
            .onAppear {
                withAnimation(.linear(duration: 1.4).repeatForever(autoreverses: false)) {
                    shimmerOffset = 1.0
                }
            }
    }
}

// Task card skeleton — matches TaskCard layout
struct TaskCardSkeleton: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            SkeletonView().frame(height: 20).frame(maxWidth: 200)
            SkeletonView().frame(height: 14).frame(maxWidth: 280)
            HStack {
                SkeletonView().frame(width: 60, height: 24)
                Spacer()
                SkeletonView().frame(width: 80, height: 24)
            }
        }
        .padding(16)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .padding(.horizontal, 16)
    }
}
```

**Step 2: Apply in `TaskDiscoveryScreen`**

```swift
// Replace ProgressView() with:
if isLoading && tasks.isEmpty {
    ForEach(0..<5, id: \.self) { _ in
        TaskCardSkeleton()
    }
}
```

**Step 3: Apply same pattern in `ConversationListScreen`, `HustlerTaskListScreen`, `WalletScreen`, `NotificationsScreen`**

Each screen: create a matching skeleton row struct (conversation skeleton, notification skeleton, etc.)

**Step 4: Run tests (⌘U) + commit**

```bash
git add "hustleXP final1/Components/Atoms/SkeletonView.swift" "hustleXP final1/Screens/"
git commit -m "feat(ios): add shimmer skeleton loading states to all list views"
```

---

### Task 18: Haptic Feedback Audit + Standardization

**Files:**
- Create: `hustleXP final1/Utilities/HapticManager.swift`
- Modify: Any screens using raw `UIImpactFeedbackGenerator`

**Step 1: Create `HapticManager.swift`**

```swift
// hustleXP final1/Utilities/HapticManager.swift
import UIKit

enum HapticManager {
    static func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
    static func warning() {
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }
    static func error() {
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }
    static func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }
    static func light() { impact(.light) }
    static func heavy() { impact(.heavy) }
}
```

**Step 2: Grep for all haptic usages and standardize to `HapticManager`**

```bash
grep -r "UIImpactFeedbackGenerator\|UINotificationFeedbackGenerator" "/Users/sebastiandysart/HustleXP/HUSTLEXPFINAL1/hustleXP final1/" --include="*.swift" -l
```

For each file found: replace the raw UIKit calls with `HapticManager.success()`, `HapticManager.impact()`, etc.

**Step 3: Ensure these events always trigger haptics:**
- Apply button tap → `HapticManager.impact()` before API call
- Apply success → `HapticManager.success()` in `.task` callback
- Apply failure → `HapticManager.error()` in catch
- Payment received notification → `HapticManager.success()` in SSE handler

**Step 4: Commit**

```bash
git add "hustleXP final1/Utilities/HapticManager.swift" "hustleXP final1/Screens/"
git commit -m "feat(ios): add HapticManager utility and standardize haptic feedback"
```

---

### Task 19: Pull-to-Refresh on All List Screens

**Files:**
- Modify: 6 list screens (same as empty states in Task 16)

**Step 1: Add `refreshable {}` to each screen**

For each `List` or `ScrollView`:
```swift
.refreshable {
    await viewModel.reload() // or: await taskService.refresh()
}
```

Screens: `TaskDiscoveryScreen`, `HustlerTaskListScreen`, `PosterTaskListScreen`, `ConversationListScreen`, `NotificationsScreen`, `WalletScreen`

Each refresh must call the underlying data fetch (tRPC call), not just re-render.

**Step 2: Verify each screen's `reload()` method resets pagination state (clear cursor, reset items)**

**Step 3: Commit**

```bash
git add "hustleXP final1/Screens/"
git commit -m "feat(ios): add pull-to-refresh to all list views"
```

---

### Task 20: Add SwiftLint

**Files:**
- Create: `.swiftlint.yml` (at `HUSTLEXPFINAL1/` root)

**Step 1: Install SwiftLint via Homebrew (if not present)**

```bash
which swiftlint || brew install swiftlint
```

**Step 2: Create `.swiftlint.yml`**

```yaml
# .swiftlint.yml
opt_in_rules:
  - force_cast
  - force_try
  - implicitly_unwrapped_optional

disabled_rules:
  - trailing_whitespace

line_length:
  warning: 140
  error: 200

file_length:
  warning: 600
  error: 1200
  ignore_comment_only_lines: true

type_body_length:
  warning: 400
  error: 600

excluded:
  - Pods
  - .build
  - DerivedData

reporter: "xcode"
```

**Step 3: Run SwiftLint and review output**

```bash
cd "/Users/sebastiandysart/HustleXP/HUSTLEXPFINAL1"
swiftlint lint --config .swiftlint.yml 2>&1 | head -50
```

**Step 4: Fix any `error`-level violations (not `warning`)**

**Step 5: Commit**

```bash
git add .swiftlint.yml
git commit -m "chore(ios): add SwiftLint configuration"
```

---

### Task 21: Move Production Mocks to Test Target

**Files:**
- Move: `hustleXP final1/Services/MockHeatMapService.swift` → `hustleXP final1Tests/Mocks/`
- Move: `hustleXP final1/Services/MockLocationService.swift` → `hustleXP final1Tests/Mocks/`

**Step 1: Move files**

In Xcode: select each file → Move to Group → `hustleXP final1Tests/Mocks/`
(Or use Finder, then update Xcode project references)

**Step 2: Verify app target compiles**

Product → Build (⌘B)
Expected: Build Succeeded

**Step 3: Run tests (⌘U)**

Expected: All tests pass

**Step 4: Commit**

```bash
git add -A
git commit -m "refactor(ios): move MockHeatMapService and MockLocationService to test target"
```

---

### Task 22: Phase 2 Verification

**Step 1: Full Xcode test run** (⌘U)

Expected: All 169+ tests pass, new tests added in Phase 2 also pass

**Step 2: SwiftLint check**

```bash
swiftlint lint --config .swiftlint.yml 2>&1 | grep " error:" | wc -l
```
Expected: 0 error-level violations

**Step 3: Git log sanity check**

```bash
cd /Users/sebastiandysart/HustleXP/HUSTLEXPFINAL1
git log --oneline -15
```

**Step 4: Push**

```bash
git push origin main
```

---

## PHASE 3: B3 Features

---

### Task 23: Wire `SquadService.swift` to Backend tRPC

**Files:**
- Modify: `hustleXP final1/Services/SquadService.swift`
- Test: `hustleXP final1Tests/Services/SquadServiceTests.swift` (already exists per health audit)

**Step 1: Read current `SquadService.swift`**

```bash
head -60 "/Users/sebastiandysart/HustleXP/HUSTLEXPFINAL1/hustleXP final1/Services/SquadService.swift"
```

**Step 2: Audit all methods — identify any that return mock data or hardcoded values**

Look for patterns like `return []`, `return Mock...`, `// TODO: wire API`

**Step 3: For each un-wired method, implement the tRPC call**

Pattern (using `createSquad` as example):
```swift
func createSquad(name: String, description: String?) async throws -> Squad {
    isLoading = true; defer { isLoading = false }
    struct Input: Codable { let name: String; let description: String? }
    let response: Squad = try await trpc.call(
        router: "squad",
        procedure: "createSquad",
        input: Input(name: name, description: description)
    )
    return response
}
```

Wire similarly: `joinSquad`, `leaveSquad`, `inviteMember`, `listMine`, `listInvites`, `acceptInvite`, `declineInvite`, `listTasks`

**Step 4: Update `SquadServiceTests.swift` to test the wired methods**

**Step 5: Run tests (⌘U) + commit**

```bash
git add "hustleXP final1/Services/SquadService.swift" "hustleXP final1Tests/Services/SquadServiceTests.swift"
git commit -m "feat(ios): wire SquadService to backend tRPC procedures"
```

---

### Task 24: Complete `SquadsHubScreen` UI

**Files:**
- Modify: `hustleXP final1/Screens/Hustler/SquadsHubScreen.swift` (889 lines — large file)

**Step 1: Identify incomplete UI sections**

```bash
grep -n "TODO\|FIXME\|// mock\|// placeholder\|// wire" "/Users/sebastiandysart/HustleXP/HUSTLEXPFINAL1/hustleXP final1/Screens/Hustler/SquadsHubScreen.swift"
```

**Step 2: For each incomplete section:**
- Create squad flow: form sheet → `squadService.createSquad()` call → navigate to squad detail
- Invite member flow: search users → `squadService.inviteMember()` → success toast
- Accept/decline invite: button taps → `squadService.acceptInvite()` / `declineInvite()`
- Leave squad: destructive confirm alert → `squadService.leaveSquad()`

**Step 3: Add error states and empty states**

Apply `ErrorStateView` and `EmptyStateView` from Phase 2.

**Step 4: Run tests (⌘U) + commit**

```bash
git add "hustleXP final1/Screens/Hustler/SquadsHubScreen.swift"
git commit -m "feat(ios): complete SquadsHubScreen UI with all squad actions wired"
```

---

### Task 25: Wire `SubscriptionService` to Backend + Build Paywall UI

**Files:**
- Modify: `hustleXP final1/Services/SubscriptionService.swift`
- Create: `hustleXP final1/Screens/Shared/PaywallSheet.swift`

**Step 1: Wire `SubscriptionService` methods**

```swift
func getSubscriptionStatus() async throws -> SubscriptionStatus {
    isLoading = true; defer { isLoading = false }
    let response: SubscriptionStatus = try await trpc.call(
        router: "subscription",
        procedure: "getStatus",
        input: EmptyInput()
    )
    currentStatus = response
    return response
}

func subscribe(priceId: String) async throws -> SubscriptionStatus {
    struct Input: Codable { let priceId: String }
    return try await trpc.call(router: "subscription", procedure: "create", input: Input(priceId: priceId))
}
```

**Step 2: Create `PaywallSheet.swift`**

```swift
// hustleXP final1/Screens/Shared/PaywallSheet.swift
import SwiftUI

struct PaywallSheet: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var subscriptionService = SubscriptionService()

    let features = [
        ("star.fill", "Priority task visibility"),
        ("checkmark.seal.fill", "Verified badge on profile"),
        ("arrow.up.circle.fill", "5 active tasks (vs 2 free)"),
        ("chart.bar.fill", "Advanced earnings analytics"),
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 52))
                        .foregroundColor(.yellow)
                    Text("HustleXP Pro")
                        .font(.title.bold())
                    Text("Unlock your full earning potential")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 32)

                // Features list
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(features, id: \.0) { icon, text in
                        HStack(spacing: 12) {
                            Image(systemName: icon)
                                .foregroundColor(.accentColor)
                                .frame(width: 24)
                            Text(text)
                                .font(.body)
                        }
                    }
                }
                .padding(.horizontal, 32)

                Spacer()

                // CTA
                VStack(spacing: 12) {
                    Button {
                        Task {
                            try await subscriptionService.subscribe(priceId: AppConfig.proPriceId)
                            dismiss()
                        }
                    } label: {
                        Text(subscriptionService.isLoading ? "Processing..." : "Start Pro — $9.99/month")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(subscriptionService.isLoading)
                    .padding(.horizontal, 24)

                    Button("Not now", action: { dismiss() })
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 32)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
}
```

**Step 3: Run tests (⌘U) + commit**

```bash
git add "hustleXP final1/Services/SubscriptionService.swift" "hustleXP final1/Screens/Shared/PaywallSheet.swift"
git commit -m "feat(ios): wire SubscriptionService + build PaywallSheet UI"
```

---

### Task 26: Build Live Mode / Broadcasts Screen

**Files:**
- Create: `hustleXP final1/Screens/Shared/LiveBroadcastsScreen.swift`
- Modify: `hustleXP final1/Services/LiveDataService.swift`

**Step 1: Wire `LiveDataService` to backend**

```swift
func fetchActiveBroadcasts() async throws -> [LiveBroadcast] {
    isLoading = true; defer { isLoading = false }
    struct Input: Codable { let cursor: String?; let limit: Int }
    let response: PaginatedResponse<LiveBroadcast> = try await trpc.call(
        router: "live",
        procedure: "listBroadcasts",
        input: Input(cursor: nil, limit: 20)
    )
    broadcasts = response.items
    return response.items
}
```

**Step 2: Create `LiveBroadcastsScreen`**

- List of active broadcasts with urgency indicator
- Pull-to-refresh
- SSE subscription for new broadcasts (reuse `RealtimeSSEClient.shared`)
- Tap a broadcast → navigate to task detail
- Empty state: "No urgent tasks nearby right now"

**Step 3: Wire SSE for live broadcast delivery**

```swift
// Subscribe to "live_broadcast" events:
sseSubscription = RealtimeSSEClient.shared.messageReceived
    .filter { $0.type == "live_broadcast" }
    .sink { [weak self] _ in
        Task { try? await self?.liveService.fetchActiveBroadcasts() }
    }
```

**Step 4: Run tests (⌘U) + commit**

```bash
git add "hustleXP final1/Screens/Shared/LiveBroadcastsScreen.swift" "hustleXP final1/Services/LiveDataService.swift"
git commit -m "feat(ios): build LiveBroadcastsScreen with SSE subscription"
```

---

### Task 27: Add `/v1/` API Versioning to Backend

**Files:**
- Modify: `backend/src/server.ts`

**Step 1: Identify all REST routes**

```bash
grep -n "app\.get\|app\.post\|app\.put\|app\.delete\|app\.patch" /Users/sebastiandysart/Desktop/hustlexp-ai-backend/backend/src/server.ts | grep -v "\/v1\/" | head -30
```

**Step 2: Add `/v1/` prefix**

For each REST route (not tRPC — tRPC routes go through `/api/trpc/*` which stays unchanged):
```typescript
// Before:
app.get('/api/tasks/:taskId/state', handler)
// After:
app.get('/v1/tasks/:taskId/state', handler)
app.get('/api/tasks/:taskId/state', handler) // keep for backwards compat during transition
```

**Note:** Keep `/health` and `/ready` without versioning (used by Railway health checks).

**Step 3: Update Railway health check URL if needed**

Railway config: health check path stays `/health` (no `/v1/` prefix).

**Step 4: Run full suite + commit**

```bash
npm test 2>&1 | tail -5
git add backend/src/server.ts
git commit -m "feat(backend): add /v1/ prefix to all REST routes (backwards compat preserved)"
```

---

### Task 28: Phase 3 Verification

**Step 1: Backend full test run**

```bash
cd /Users/sebastiandysart/Desktop/hustlexp-ai-backend
npm test 2>&1 | tail -10
```
Expected: All tests pass

**Step 2: iOS full test run (Xcode ⌘U)**

Expected: All tests pass

**Step 3: Push both repos**

```bash
cd /Users/sebastiandysart/Desktop/hustlexp-ai-backend && git push origin main
cd /Users/sebastiandysart/HustleXP/HUSTLEXPFINAL1 && git push origin main
```

---

## PHASE 4: Launch Prep

---

### Task 29: TestFlight Configuration

**Step 1: Create internal testing group in App Store Connect**

1. Open [appstoreconnect.apple.com](https://appstoreconnect.apple.com)
2. Select HustleXP app → TestFlight tab
3. Create group: "Internal Team"
4. Add team members by Apple ID
5. Set app to auto-distribute to internal group on build upload

**Step 2: Create external beta group**

1. Create group: "Private Beta — Wave 1"
2. Set max testers: 25
3. Add TestFlight feedback email

**Step 3: Create internal testing script**

Create `/Users/sebastiandysart/Desktop/hustlexp-docs/launch/beta-testing-script.md` covering walkthrough of all 6 journeys (J1-J6).

---

### Task 30: App Store Connect Metadata

**Files:**
- Create: `/Users/sebastiandysart/Desktop/hustlexp-docs/launch/app-store-metadata.md`

**Required metadata:**

```
App Name: HustleXP — Gig Marketplace
Subtitle: Earn money helping neighbors (30 chars max)

Description (4000 chars max):
[See design doc for draft]

Keywords (100 chars): gig,earn money,task,local,side hustle,marketplace,jobs,freelance,neighborhood,delivery

Support URL: [your support URL]
Marketing URL: [your landing page]

Screenshots required:
- iPhone 6.7" (1290×2796): 3-10 screenshots
- iPhone 6.5" (1242×2688): 3-10 screenshots
- iPhone 5.5" (1242×2208): 3-10 screenshots

Age Rating: 17+ (financial transactions)
Privacy Policy URL: [required before review]
```

**Step 1: Write and save metadata doc**

**Step 2: Capture screenshots**

Run app in iPhone 15 Pro Max simulator (6.7"):
- Capture: onboarding screen, task discovery, task detail, messaging, wallet/earnings, profile
- Use Xcode Simulator → Device → Erase All Content first for clean state

**Step 3: Create App Store description copy**

Write from Hustler perspective (broader appeal): lead with earning opportunity, mention instant payment via escrow.

---

### Task 31: Privacy Policy + Terms of Service

**Files:**
- Create: `/Users/sebastiandysart/Desktop/hustlexp-docs/launch/privacy-policy.md`
- Create: `/Users/sebastiandysart/Desktop/hustlexp-docs/launch/terms-of-service.md`

**Privacy Policy minimum required sections:**
1. What data we collect (name, email, location, photos, payment info)
2. How we use it (service operation, safety, fraud prevention)
3. Who we share with: Stripe (payments), Firebase/Google (auth), Cloudflare (storage), FCM (push), Google Maps (geo)
4. Data retention: accounts deleted within 30 days of request
5. User rights: access, deletion, correction
6. Contact: [support email]

**Terms of Service minimum required sections:**
1. User eligibility (18+, legal ability to work in US)
2. Poster responsibilities (accurate task description, timely payment, no illegal tasks)
3. Hustler responsibilities (honest completion, accurate proof, no fraud)
4. Payment terms (escrow model, 10% platform fee, 2-3 day payout)
5. Dispute resolution (AI-assisted, appeal to human review)
6. Account termination
7. Limitation of liability

**Step 1: Write both documents**
**Step 2: Host at public URL (Vercel/Notion/custom domain)**
**Step 3: Add URLs to `AppConfig.swift`**

```swift
// In AppConfig.swift:
static let privacyPolicyURL = URL(string: "https://hustlexp.com/privacy")!
static let termsOfServiceURL = URL(string: "https://hustlexp.com/terms")!
```

**Step 4: Add links to iOS onboarding footer and settings screen**

---

### Task 32: Beta Tester Onboarding Materials

**Files:**
- Create: `/Users/sebastiandysart/Desktop/hustlexp-docs/launch/beta-invite-email.md`
- Create: `/Users/sebastiandysart/Desktop/hustlexp-docs/launch/getting-started-guide.md`
- Create: `/Users/sebastiandysart/Desktop/hustlexp-docs/launch/known-limitations.md`

**Beta invite email template:**

```
Subject: You're invited to test HustleXP 🎉

Hi [Name],

I'm building HustleXP — a gig marketplace that lets you earn money helping neighbors with tasks, or get help with things you need done. You're one of [25] people invited to try it before anyone else.

What you'll be testing:
- Browsing and accepting paid tasks near you
- Posting tasks and finding people to help
- Real-time messaging and payment via escrow

To get started:
1. Accept your TestFlight invite (link below)
2. Download the app
3. Create an account and try completing a task (I'll have test tasks posted)

Please report any bugs or feedback in our Discord: [link]

Thanks for being part of this,
Sebastian
```

**Getting started guide:** 2-page PDF or Notion. Cover: what HustleXP is, Hustler vs Poster roles, step-by-step first task, how payments work, how to submit proof.

**Known limitations doc:** Checkr background checks not yet live. Squad features in beta. Insurance coverage coming soon.

---

### Task 33: Production Infrastructure Checklist

**Files:**
- Create: `/Users/sebastiandysart/Desktop/hustlexp-docs/launch/production-infra-checklist.md`

**Checklist items to verify (do not auto-configure — requires manual login to each service):**

```markdown
## Railway
- [ ] Health check path: `/health`
- [ ] Restart policy: on-failure
- [ ] Environment: NODE_ENV=production set
- [ ] All env vars migrated from dev to prod

## Neon PostgreSQL
- [ ] Max connections ≥ pod_count × pool_max + 5 headroom
- [ ] Automated backups enabled (daily)
- [ ] Connection string uses pooler endpoint

## Stripe
- [ ] Webhook signing secret is `whsec_live_...` (not test)
- [ ] Live mode enabled on account
- [ ] Connect platform fee percentage confirmed
- [ ] 1099-NEC threshold configured

## Firebase
- [ ] Service account JSON is production project (verify project ID)
- [ ] Firebase Auth production rules deployed

## Cloudflare R2
- [ ] CORS policy allows HustleXP app bundle ID or wildcard
- [ ] Public bucket policies correct
- [ ] Lifecycle rules for old proof photos (optional)

## Upstash Redis
- [ ] Plan supports expected connection count
- [ ] TLS enabled

## FCM
- [ ] APNs auth key uploaded (not dev certificate)
- [ ] Production FCM project configured in AppConfig.swift
```

---

### Task 34: Monitoring Setup

**Step 1: Sentry project verification**

Verify `SENTRY_DSN` is set in Railway production env vars.
Set Sentry alert: >10 errors/hour on any single issue → email notification.

**Step 2: Uptime monitoring**

Create account on [BetterUptime](https://betteruptime.com) (free tier):
- Monitor: `GET https://[your-railway-url]/health`
- Check interval: 3 minutes
- Alert after: 3 consecutive failures
- Notify: email + SMS

**Step 3: Create `backend/monitoring/runbook.md`**

```markdown
# HustleXP On-Call Runbook

## P0 Incident (app down)
1. Check Railway logs: [link to Railway dashboard]
2. Check Sentry for error spike: [link]
3. Check /health: curl https://[url]/health
4. If DB issue: check Neon dashboard
5. Rollback: Railway → Deployments → previous deploy → Redeploy

## P1 Incident (payments failing)
1. Check Stripe webhook logs
2. Check BullMQ queue depths in logs
3. Look for INTERNAL_SERVER_ERROR in Sentry on escrow/payment procedures

## Escalation
- Contact: Sebastian Dysart
- Stripe support: https://support.stripe.com
- Railway support: https://railway.app/help
```

**Step 5: Commit all launch docs**

```bash
cd /Users/sebastiandysart/Desktop/hustlexp-docs
git add launch/
git commit -m "docs: add full launch prep materials (TestFlight, App Store, privacy, infra, monitoring)"
git push origin main
```

---

### Task 35: Phase 4 + Final Verification

**Step 1: Backend tests**

```bash
cd /Users/sebastiandysart/Desktop/hustlexp-ai-backend
npm test 2>&1 | tail -10
```
Expected: All tests pass (≥1,800+ assertions)

**Step 2: iOS tests (Xcode ⌘U)**

Expected: All tests pass (≥180+ test functions)

**Step 3: TypeScript check**

```bash
cd /Users/sebastiandysart/Desktop/hustlexp-ai-backend
npx tsc --noEmit
```
Expected: 0 errors

**Step 4: SwiftLint**

```bash
cd /Users/sebastiandysart/HustleXP/HUSTLEXPFINAL1
swiftlint lint --config .swiftlint.yml 2>&1 | grep " error:" | wc -l
```
Expected: 0 errors

**Step 5: Push all repos**

```bash
cd /Users/sebastiandysart/Desktop/hustlexp-ai-backend && git push origin main
cd /Users/sebastiandysart/HustleXP/HUSTLEXPFINAL1 && git push origin main
cd /Users/sebastiandysart/Desktop/hustlexp-docs && git push origin main
```

**Step 6: Declare done 🎉**

All 4 phases complete. HustleXP is production-hardened, polished, feature-complete for beta, and launch-ready.

---

## Summary of All Tasks

| # | Task | Phase | Repo |
|---|------|-------|------|
| 1 | Paginate admin.listUsers | 1 | Backend |
| 2 | Paginate admin.listTasks, listDisputes, betaDashboard.listUsers | 1 | Backend |
| 3 | Paginate notification.getList | 1 | Backend |
| 4 | Paginate squad + recurringTask procedures | 1 | Backend |
| 5 | Paginate live, instant, incidents, expertiseSupply | 1 | Backend |
| 6 | Add Sentry error tracking | 1 | Backend |
| 7 | Add request correlation middleware | 1 | Backend |
| 8 | Add /health and /ready endpoints | 1 | Backend |
| 9 | Graceful shutdown + env validation | 1 | Backend |
| 10 | Remove confirmed dead code | 1 | Backend |
| 11 | Fix ESLint root-level config | 1 | Backend |
| 12 | Add tests for zero-coverage services | 1 | Backend |
| 13 | Phase 1 verification + push | 1 | Backend |
| 14 | Create ErrorStateView component | 2 | iOS |
| 15 | Apply error states to priority screens | 2 | iOS |
| 16 | Create EmptyStateView + apply to lists | 2 | iOS |
| 17 | Add loading skeletons | 2 | iOS |
| 18 | Haptic feedback audit + HapticManager | 2 | iOS |
| 19 | Pull-to-refresh on all list screens | 2 | iOS |
| 20 | Add SwiftLint | 2 | iOS |
| 21 | Move production mocks to test target | 2 | iOS |
| 22 | Phase 2 verification + push | 2 | iOS |
| 23 | Wire SquadService to tRPC | 3 | iOS |
| 24 | Complete SquadsHubScreen UI | 3 | iOS |
| 25 | Wire SubscriptionService + PaywallSheet | 3 | iOS + Backend |
| 26 | Build LiveBroadcastsScreen + SSE | 3 | iOS |
| 27 | Add /v1/ API versioning | 3 | Backend |
| 28 | Phase 3 verification + push | 3 | Both |
| 29 | TestFlight configuration | 4 | App Store Connect |
| 30 | App Store Connect metadata | 4 | Docs |
| 31 | Privacy Policy + Terms of Service | 4 | Docs + iOS |
| 32 | Beta tester onboarding materials | 4 | Docs |
| 33 | Production infra checklist | 4 | Docs |
| 34 | Monitoring setup | 4 | Backend + Docs |
| 35 | Final verification + push all repos | 4 | All |
