# INTEGRATION STRATEGY — HustleXP v1.0

**STATUS: LOCKED**
**Authority:** source.ts, network/client.ts, adapter contracts

---

## PART A — Data Source Architecture

### A1. Source Configuration

```
src/data/source.ts
├── DATA_SOURCE: 'MOCK' | 'LIVE'     (global default)
├── ENDPOINT_OVERRIDES: Record<string, DataSource>  (per-endpoint)
└── isLive(endpoint): boolean        (runtime check)
```

**Rules:**
- Default is always `MOCK` (safe for development)
- `LIVE` requires explicit opt-in
- Per-endpoint overrides enable incremental migration

### A2. Migration Sequence

| Phase | Configuration | Risk |
|-------|---------------|------|
| 1. Mock only | `DATA_SOURCE: 'MOCK'` | None |
| 2. Single endpoint live | `ENDPOINT_OVERRIDES['/api/hustler/home']: 'LIVE'` | Contained |
| 3. Multiple endpoints live | Add more overrides | Contained per-endpoint |
| 4. Global live | `DATA_SOURCE: 'LIVE'` | Full backend dependency |

---

## PART B — Network Client Design

### B1. Result Type (Never Throws)

```typescript
type NetworkResult<T> =
  | { ok: true; data: T }
  | { ok: false; error: NetworkError }
```

**Guarantees:**
- No exceptions escape the network layer
- All failures normalized to `NetworkError`
- Adapters always receive a result to handle

### B2. Error Code Mapping

| Network Error | HTTP Status | Observability Code |
|---------------|-------------|-------------------|
| `NETWORK_ERROR` | (no response) | `NETWORK_ERROR` |
| `TIMEOUT` | (aborted) | `NETWORK_ERROR` |
| `SERVER_ERROR` | 500-599 | `SERVER_ERROR` |
| `INVALID_JSON` | 200 + bad body | `INVALID_RESPONSE` |
| `UNAUTHORIZED` | 401 | `UNAUTHORIZED` |
| `FORBIDDEN` | 403 | `FORBIDDEN` |
| `NOT_FOUND` | 404 | `NOT_FOUND` |

### B3. Timeout Configuration

```typescript
const DEFAULT_TIMEOUT = 10000; // 10 seconds
```

- All requests have default timeout
- Per-request override available via `config.timeout`
- Timeout triggers `TIMEOUT` error, not exception

---

## PART C — Adapter Integration Pattern

### C1. Dual-Source Adapter Structure

```typescript
export async function getXxxData(): Promise<AdapterResult<XxxProps>> {
  let data: any;

  if (isLive(ENDPOINTS.XXX)) {
    const result = await get<unknown>(buildUrl(ENDPOINTS.XXX));

    if (!result.ok) {
      logError('network', toObservabilityErrorCode(result.error.code), ...);
      return { state: 'error', props: stubProps };
    }

    data = result.data;
  } else {
    data = xxxMock;
  }

  // Existing guard logic (unchanged)
  // ...
}
```

### C2. Invariants Preserved

| Invariant | Mock Mode | Live Mode |
|-----------|-----------|-----------|
| Guards run on data | ✅ | ✅ |
| StubProps on error | ✅ | ✅ |
| Error logging | ✅ | ✅ |
| Never throws | ✅ | ✅ |

### C3. Network Error → Adapter Error

When network fails:
1. Network client returns `{ ok: false, error: NetworkError }`
2. Adapter logs error with observability
3. Adapter returns `{ state: 'error', props: stubProps }`
4. Screen renders error UI (StatusBanner danger)
5. User sees "Something went wrong. Pull to retry."

---

## PART D — Test Coverage

### D1. Network Client Tests (12 tests)

- Successful responses (200 OK, POST body)
- Server errors (500, 502, 503)
- Invalid JSON response
- Timeout handling
- Network errors (fetch failure, offline)
- HTTP status codes (401, 403, 404)

### D2. Live Mode Adapter Tests (10 tests)

- Server error → error state + stubProps
- Invalid JSON → error state + stubProps
- Missing required field → error state + stubProps
- Timeout → error state + stubProps
- Network error → error state + stubProps + logging
- Valid response → success state

### D3. Mock Mode Adapter Tests (81 tests)

- Valid response → success
- Missing required field → error
- Wrong primitive type → error
- Invalid enum value → error
- Null where forbidden → error
- Stub props shape assertion

---

## PART E — Failure Scenarios (Proven)

### E1. Backend Unreachable

**Trace:**
1. `fetch()` throws `TypeError: Failed to fetch`
2. Network client returns `{ ok: false, error: { code: 'NETWORK_ERROR' } }`
3. Adapter logs `logError('network', 'NETWORK_ERROR', ...)`
4. Adapter returns `{ state: 'error', props: stubProps }`
5. Screen renders error UI

**Result:** App continues functioning, user sees retry option.

### E2. Backend Returns 500

**Trace:**
1. `fetch()` returns `{ ok: false, status: 500 }`
2. Network client returns `{ ok: false, error: { code: 'SERVER_ERROR' } }`
3. Adapter logs and returns error state
4. Screen renders error UI

**Result:** App continues functioning, user sees retry option.

### E3. Backend Returns Invalid JSON

**Trace:**
1. `fetch()` returns `{ ok: true, status: 200 }`
2. `response.json()` throws `SyntaxError`
3. Network client returns `{ ok: false, error: { code: 'INVALID_JSON' } }`
4. Adapter returns error state

**Result:** App continues functioning.

### E4. Backend Returns Valid JSON with Missing Field

**Trace:**
1. Network client returns `{ ok: true, data: { ... } }` (missing `user`)
2. Adapter guard: `!data.user` → true
3. Adapter returns `{ state: 'error', props: stubProps }`

**Result:** Existing guard logic catches it. App continues.

### E5. Request Timeout

**Trace:**
1. `AbortController` fires after 10 seconds
2. `fetch()` throws `AbortError`
3. Network client returns `{ ok: false, error: { code: 'TIMEOUT' } }`
4. Adapter returns error state

**Result:** App continues functioning, user sees retry option.

---

## PART F — Migration Checklist

### F1. Before Enabling LIVE for an Endpoint

- [ ] Backend endpoint deployed and tested
- [ ] Adapter has complete guard coverage
- [ ] Network tests pass for failure scenarios
- [ ] Live mode tests pass for adapter
- [ ] Manual testing with backend

### F2. Enabling LIVE

```typescript
// In src/data/source.ts
export const ENDPOINT_OVERRIDES: Partial<Record<string, DataSource>> = {
  '/api/hustler/home': 'LIVE',  // Enable live for this endpoint
};
```

### F3. Rollback

```typescript
// Remove the override to revert to mock
export const ENDPOINT_OVERRIDES: Partial<Record<string, DataSource>> = {
  // '/api/hustler/home': 'LIVE',  // Disabled
};
```

---

## PART G — Proven Guarantees

### G1. System Resilience

✅ Network layer never throws
✅ All network errors normalized to result type
✅ Adapters handle network errors gracefully
✅ StubProps always provided on error
✅ UI never crashes from network failures

### G2. Observability

✅ Network errors logged with context
✅ Endpoint and status code captured
✅ Error codes map to observability layer
✅ Production sink ready (Sentry/Datadog stub)

### G3. Test Coverage

✅ 12 network client tests
✅ 10 live mode adapter tests
✅ 81 mock mode adapter tests
✅ 103 total tests passing

---

**END OF DOCUMENT**
