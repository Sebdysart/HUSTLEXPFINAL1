/**
 * Mock Proof Data
 * SPEC: MOCK_DATA_SPEC.md §5
 * SCHEMA: schema.sql proofs table
 */

export const ProofState = {
  PENDING: 'PENDING',
  SUBMITTED: 'SUBMITTED',
  ACCEPTED: 'ACCEPTED',
  REJECTED: 'REJECTED',
  EXPIRED: 'EXPIRED',
};

export const MOCK_PROOFS = {
  'proof-accepted-in-progress': {
    id: 'proof-accepted-in-progress',
    task_id: 'task-accepted',
    submitter_id: 'user-hustler-active',
    state: ProofState.PENDING,
    description: null,
    submitted_at: null,
    reviewed_by: null,
    reviewed_at: null,
    rejection_reason: null,
    created_at: '2025-01-15T12:00:00Z',
    updated_at: '2025-01-15T12:00:00Z',
  },

  'proof-submitted': {
    id: 'proof-submitted',
    task_id: 'task-proof-submitted',
    submitter_id: 'user-hustler-elite',
    state: ProofState.SUBMITTED,
    description: 'Bookshelf fully assembled and secured to wall. Took about 2 hours.',
    submitted_at: '2025-01-14T12:30:00Z',
    reviewed_by: null,
    reviewed_at: null,
    rejection_reason: null,
    created_at: '2025-01-14T10:00:00Z',
    updated_at: '2025-01-14T12:30:00Z',
    photos: [
      {
        id: 'photo-1',
        storage_key: 'proofs/task-proof-submitted/photo-1.jpg',
        content_type: 'image/jpeg',
        file_size_bytes: 1024000,
        sequence_number: 1,
      },
      {
        id: 'photo-2',
        storage_key: 'proofs/task-proof-submitted/photo-2.jpg',
        content_type: 'image/jpeg',
        file_size_bytes: 980000,
        sequence_number: 2,
      },
    ],
  },

  'proof-accepted': {
    id: 'proof-accepted',
    task_id: 'task-completed',
    submitter_id: 'user-hustler-active',
    state: ProofState.ACCEPTED,
    description: 'Package delivered to front desk. Receptionist signed for it.',
    submitted_at: '2025-01-14T10:00:00Z',
    reviewed_by: 'user-poster-active',
    reviewed_at: '2025-01-14T10:15:00Z',
    rejection_reason: null,
    created_at: '2025-01-14T09:00:00Z',
    updated_at: '2025-01-14T10:15:00Z',
    photos: [
      {
        id: 'photo-3',
        storage_key: 'proofs/task-completed/photo-1.jpg',
        content_type: 'image/jpeg',
        file_size_bytes: 850000,
        sequence_number: 1,
      },
    ],
  },

  'proof-disputed': {
    id: 'proof-disputed',
    task_id: 'task-disputed',
    submitter_id: 'user-hustler-active',
    state: ProofState.REJECTED,
    description: 'Walked Max for 1 hour around the neighborhood park.',
    submitted_at: '2025-01-13T15:30:00Z',
    reviewed_by: 'user-poster-new',
    reviewed_at: '2025-01-13T16:00:00Z',
    rejection_reason: 'Photo does not show you actually walked for an hour. My GPS collar shows only 20 minutes of activity.',
    created_at: '2025-01-13T14:00:00Z',
    updated_at: '2025-01-13T16:00:00Z',
    photos: [
      {
        id: 'photo-4',
        storage_key: 'proofs/task-disputed/photo-1.jpg',
        content_type: 'image/jpeg',
        file_size_bytes: 920000,
        sequence_number: 1,
      },
    ],
  },
};

/**
 * Get a proof by ID
 * @param {string} proofId
 * @returns {Object|null}
 */
export const getProof = (proofId) => MOCK_PROOFS[proofId] || null;

/**
 * Get proof for a task
 * @param {string} taskId
 * @returns {Object|null}
 */
export const getProofForTask = (taskId) => {
  return Object.values(MOCK_PROOFS).find(p => p.task_id === taskId) || null;
};

/**
 * Get all proofs
 * @returns {Object[]}
 */
export const getAllProofs = () => Object.values(MOCK_PROOFS);

/**
 * Get proofs by state
 * @param {string} state
 * @returns {Object[]}
 */
export const getProofsByState = (state) => {
  return Object.values(MOCK_PROOFS).filter(p => p.state === state);
};

/**
 * Get proofs submitted by a user
 * @param {string} userId
 * @returns {Object[]}
 */
export const getProofsForUser = (userId) => {
  return Object.values(MOCK_PROOFS).filter(p => p.submitter_id === userId);
};

export default MOCK_PROOFS;
