/**
 * Mock Escrow Data
 * SPEC: MOCK_DATA_SPEC.md §4
 * SCHEMA: schema.sql escrows table
 */

export const EscrowState = {
  PENDING: 'PENDING',
  FUNDED: 'FUNDED',
  LOCKED_DISPUTE: 'LOCKED_DISPUTE',
  RELEASED: 'RELEASED',
  REFUNDED: 'REFUNDED',
  REFUND_PARTIAL: 'REFUND_PARTIAL',
};

export const TERMINAL_ESCROW_STATES = [
  EscrowState.RELEASED,
  EscrowState.REFUNDED,
  EscrowState.REFUND_PARTIAL,
];

export const MOCK_ESCROWS = {
  'escrow-open-1': {
    id: 'escrow-open-1',
    task_id: 'task-open-1',
    amount: 4500,
    state: EscrowState.FUNDED,
    stripe_payment_intent_id: 'pi_mock_open_1',
    funded_at: '2025-01-15T10:05:00Z',
    created_at: '2025-01-15T10:00:00Z',
    updated_at: '2025-01-15T10:05:00Z',
  },

  'escrow-open-2': {
    id: 'escrow-open-2',
    task_id: 'task-open-2',
    amount: 2000,
    state: EscrowState.FUNDED,
    stripe_payment_intent_id: 'pi_mock_open_2',
    funded_at: '2025-01-15T11:05:00Z',
    created_at: '2025-01-15T11:00:00Z',
    updated_at: '2025-01-15T11:05:00Z',
  },

  'escrow-open-live': {
    id: 'escrow-open-live',
    task_id: 'task-open-live',
    amount: 3500,
    state: EscrowState.FUNDED,
    stripe_payment_intent_id: 'pi_mock_live',
    funded_at: '2025-01-15T14:32:00Z',
    created_at: '2025-01-15T14:30:00Z',
    updated_at: '2025-01-15T14:32:00Z',
  },

  'escrow-accepted': {
    id: 'escrow-accepted',
    task_id: 'task-accepted',
    amount: 7500,
    state: EscrowState.FUNDED,
    stripe_payment_intent_id: 'pi_mock_accepted',
    funded_at: '2025-01-14T16:05:00Z',
    created_at: '2025-01-14T16:00:00Z',
    updated_at: '2025-01-15T12:00:00Z',
  },

  'escrow-proof-submitted': {
    id: 'escrow-proof-submitted',
    task_id: 'task-proof-submitted',
    amount: 4000,
    state: EscrowState.FUNDED,
    stripe_payment_intent_id: 'pi_mock_proof',
    funded_at: '2025-01-13T18:05:00Z',
    created_at: '2025-01-13T18:00:00Z',
    updated_at: '2025-01-14T12:30:00Z',
  },

  'escrow-disputed': {
    id: 'escrow-disputed',
    task_id: 'task-disputed',
    amount: 2500,
    state: EscrowState.LOCKED_DISPUTE,
    stripe_payment_intent_id: 'pi_mock_disputed',
    funded_at: '2025-01-13T10:05:00Z',
    created_at: '2025-01-13T10:00:00Z',
    updated_at: '2025-01-13T16:00:00Z',
  },

  'escrow-completed': {
    id: 'escrow-completed',
    task_id: 'task-completed',
    amount: 1500,
    state: EscrowState.RELEASED,
    stripe_payment_intent_id: 'pi_mock_completed',
    stripe_transfer_id: 'tr_mock_completed',
    funded_at: '2025-01-14T08:05:00Z',
    released_at: '2025-01-14T10:15:00Z',
    created_at: '2025-01-14T08:00:00Z',
    updated_at: '2025-01-14T10:15:00Z',
  },

  'escrow-cancelled': {
    id: 'escrow-cancelled',
    task_id: 'task-cancelled',
    amount: 5000,
    state: EscrowState.REFUNDED,
    stripe_payment_intent_id: 'pi_mock_cancelled',
    stripe_refund_id: 're_mock_cancelled',
    funded_at: '2025-01-13T12:05:00Z',
    refunded_at: '2025-01-14T08:00:00Z',
    created_at: '2025-01-13T12:00:00Z',
    updated_at: '2025-01-14T08:00:00Z',
  },

  'escrow-expired': {
    id: 'escrow-expired',
    task_id: 'task-expired',
    amount: 3000,
    state: EscrowState.REFUNDED,
    stripe_payment_intent_id: 'pi_mock_expired',
    stripe_refund_id: 're_mock_expired',
    funded_at: '2025-01-09T12:05:00Z',
    refunded_at: '2025-01-10T18:00:00Z',
    created_at: '2025-01-09T12:00:00Z',
    updated_at: '2025-01-10T18:00:00Z',
  },
};

/**
 * Get an escrow by ID
 * @param {string} escrowId
 * @returns {Object|null}
 */
export const getEscrow = (escrowId) => MOCK_ESCROWS[escrowId] || null;

/**
 * Get escrow for a task
 * @param {string} taskId
 * @returns {Object|null}
 */
export const getEscrowForTask = (taskId) => {
  return Object.values(MOCK_ESCROWS).find(e => e.task_id === taskId) || null;
};

/**
 * Get all escrows
 * @returns {Object[]}
 */
export const getAllEscrows = () => Object.values(MOCK_ESCROWS);

/**
 * Get escrows by state
 * @param {string} state
 * @returns {Object[]}
 */
export const getEscrowsByState = (state) => {
  return Object.values(MOCK_ESCROWS).filter(e => e.state === state);
};

/**
 * Check if escrow is in terminal state
 * @param {string} state
 * @returns {boolean}
 */
export const isTerminalState = (state) => TERMINAL_ESCROW_STATES.includes(state);

/**
 * Format amount from cents to display string
 * @param {number} amountInCents
 * @returns {string}
 */
export const formatAmount = (amountInCents) => {
  return `$${(amountInCents / 100).toFixed(2)}`;
};

/**
 * Calculate platform fee (15%)
 * @param {number} amountInCents
 * @returns {number}
 */
export const calculatePlatformFee = (amountInCents) => {
  return Math.floor(amountInCents * 0.15);
};

/**
 * Calculate worker payout (85%)
 * @param {number} amountInCents
 * @returns {number}
 */
export const calculateWorkerPayout = (amountInCents) => {
  return amountInCents - calculatePlatformFee(amountInCents);
};

export default MOCK_ESCROWS;
