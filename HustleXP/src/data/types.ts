/**
 * Shared data types — single source of truth from BACKEND_CONTRACT.md.
 * No optional fields unless explicitly optional in contract.
 */

export type TaskStatus =
  | 'open'
  | 'assigned'
  | 'in_progress'
  | 'completed'
  | 'disputed'
  | 'cancelled'
  | 'expired';

export interface Task {
  id: string;
  title: string;
  description: string;
  status: TaskStatus;
  priceAmount: number;
  priceCurrency: 'USD';
  estimatedDuration: number;
  requiredTrustTier: number;
  location: {
    address: string;
    lat: number;
    lng: number;
    distance?: number;
  };
  category: string;
  createdAt: string;
  expiresAt: string | null;
}

export interface XPEntry {
  id: string;
  amount: number;
  source: string;
  earnedAt: string;
  taskTitle?: string;
}

export type SystemStatusTone = 'info' | 'warning' | 'danger' | 'success';

export interface SystemStatus {
  tone: SystemStatusTone;
  message: string;
}

/** Screen prop default when API does not return filters (per BACKEND_CONTRACT B1). */
export interface FilterState {
  category?: string;
  maxDistance?: number;
}

/** Poster summary for TaskDetailScreen (per B1). */
export interface PosterSummary {
  name: string;
  rating: number;
  taskCount: number;
}

/** Eligibility for task detail (per B2 GET /api/tasks/:id). */
export type EligibilityStatus = 'eligible' | 'ineligible' | 'checking';

export interface Eligibility {
  status: EligibilityStatus;
  reason: string | null;
  missingRequirements: string[];
}

/** Task progress state (per B2 GET /api/tasks/:id/progress). */
export type TaskProgressState = 'EN_ROUTE' | 'WORKING';

/** Submission status (per B2 GET /api/tasks/:id/completion). */
export type SubmissionStatus = 'pending' | 'submitted' | 'approved' | 'rejected';

/** Adapter result: state + UI-ready props. */
export type AdapterState = 'success' | 'loading' | 'empty' | 'error' | 'blocked';

export interface AdapterResult<T> {
  state: AdapterState;
  props: T;
}
