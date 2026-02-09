/**
 * Mock Task Data
 * SPEC: MOCK_DATA_SPEC.md §3
 * SCHEMA: schema.sql tasks table
 */

export const TaskState = {
  OPEN: 'OPEN',
  ACCEPTED: 'ACCEPTED',
  PROOF_SUBMITTED: 'PROOF_SUBMITTED',
  DISPUTED: 'DISPUTED',
  COMPLETED: 'COMPLETED',
  CANCELLED: 'CANCELLED',
  EXPIRED: 'EXPIRED',
};

export const TaskMode = {
  STANDARD: 'STANDARD',
  LIVE: 'LIVE',
};

export const TASK_CATEGORIES = [
  'moving',
  'cleaning',
  'errands',
  'delivery',
  'assembly',
  'pet-care',
  'yard-work',
  'automotive',
  'handyman',
  'tech-support',
];

export const MOCK_TASKS = {
  'task-open-1': {
    id: 'task-open-1',
    poster_id: 'user-poster-active',
    worker_id: null,
    title: 'Help move couch to second floor',
    description: 'Need help moving a large sectional couch from ground floor to second floor apartment. Two people needed. Elevator available.',
    requirements: 'Must be able to lift 50+ lbs',
    location: '123 Main St, Apt 2B, Austin, TX 78701',
    location_lat: 30.2672,
    location_lng: -97.7431,
    category: 'moving',
    price: 4500,
    state: TaskState.OPEN,
    mode: TaskMode.STANDARD,
    deadline: '2025-01-20T18:00:00Z',
    requires_proof: true,
    proof_instructions: 'Photo of couch in final location',
    created_at: '2025-01-15T10:00:00Z',
    updated_at: '2025-01-15T10:00:00Z',
  },

  'task-open-2': {
    id: 'task-open-2',
    poster_id: 'user-poster-new',
    worker_id: null,
    title: 'Grocery pickup from H-E-B',
    description: 'Need someone to pick up groceries from H-E-B on Lamar. List will be provided. About 10-15 items.',
    requirements: 'Must have car',
    location: '4001 N Lamar Blvd, Austin, TX 78756',
    location_lat: 30.3074,
    location_lng: -97.7397,
    category: 'errands',
    price: 2000,
    state: TaskState.OPEN,
    mode: TaskMode.STANDARD,
    deadline: '2025-01-16T14:00:00Z',
    requires_proof: true,
    proof_instructions: 'Photo of receipt and bags',
    created_at: '2025-01-15T11:00:00Z',
    updated_at: '2025-01-15T11:00:00Z',
  },

  'task-open-3': {
    id: 'task-open-3',
    poster_id: 'user-poster-active',
    worker_id: null,
    title: 'Assemble standing desk',
    description: 'New standing desk from Fully needs assembly. All parts included.',
    requirements: 'Basic tools knowledge',
    location: '500 Cesar Chavez St, Austin, TX 78701',
    location_lat: 30.2614,
    location_lng: -97.7477,
    category: 'assembly',
    price: 5500,
    state: TaskState.OPEN,
    mode: TaskMode.STANDARD,
    deadline: '2025-01-18T20:00:00Z',
    requires_proof: true,
    proof_instructions: 'Photo of assembled desk',
    created_at: '2025-01-15T09:00:00Z',
    updated_at: '2025-01-15T09:00:00Z',
  },

  'task-open-live': {
    id: 'task-open-live',
    poster_id: 'user-poster-active',
    worker_id: null,
    title: 'Urgent: Flat tire help needed',
    description: 'Car has flat tire in parking lot. Need help changing to spare.',
    requirements: 'Know how to change a tire',
    location: '500 E 7th St, Austin, TX 78701',
    location_lat: 30.2684,
    location_lng: -97.7354,
    category: 'automotive',
    price: 3500,
    state: TaskState.OPEN,
    mode: TaskMode.LIVE,
    live_broadcast_started_at: '2025-01-15T14:30:00Z',
    live_broadcast_radius_miles: 2.5,
    deadline: '2025-01-15T16:00:00Z',
    requires_proof: true,
    proof_instructions: 'Photo of spare tire installed',
    created_at: '2025-01-15T14:30:00Z',
    updated_at: '2025-01-15T14:30:00Z',
  },

  'task-accepted': {
    id: 'task-accepted',
    poster_id: 'user-poster-active',
    worker_id: 'user-hustler-active',
    title: 'Deep clean kitchen',
    description: 'Full kitchen deep clean including oven, fridge interior, and cabinets.',
    requirements: 'Cleaning supplies provided',
    location: '789 Oak Lane, Austin, TX 78704',
    location_lat: 30.2481,
    location_lng: -97.7513,
    category: 'cleaning',
    price: 7500,
    state: TaskState.ACCEPTED,
    mode: TaskMode.STANDARD,
    deadline: '2025-01-16T20:00:00Z',
    accepted_at: '2025-01-15T12:00:00Z',
    requires_proof: true,
    proof_instructions: 'Before/after photos of kitchen',
    created_at: '2025-01-14T16:00:00Z',
    updated_at: '2025-01-15T12:00:00Z',
  },

  'task-proof-submitted': {
    id: 'task-proof-submitted',
    poster_id: 'user-poster-active',
    worker_id: 'user-hustler-elite',
    title: 'Assemble IKEA bookshelf',
    description: 'Need help assembling a BILLY bookshelf. All parts and tools provided.',
    requirements: null,
    location: '456 Pine Ave, Austin, TX 78702',
    location_lat: 30.2614,
    location_lng: -97.7231,
    category: 'assembly',
    price: 4000,
    state: TaskState.PROOF_SUBMITTED,
    mode: TaskMode.STANDARD,
    deadline: '2025-01-15T20:00:00Z',
    accepted_at: '2025-01-14T10:00:00Z',
    proof_submitted_at: '2025-01-14T12:30:00Z',
    requires_proof: true,
    proof_instructions: 'Photo of assembled bookshelf',
    created_at: '2025-01-13T18:00:00Z',
    updated_at: '2025-01-14T12:30:00Z',
  },

  'task-disputed': {
    id: 'task-disputed',
    poster_id: 'user-poster-new',
    worker_id: 'user-hustler-active',
    title: 'Dog walking (1 hour)',
    description: 'Walk my golden retriever Max for 1 hour in the neighborhood.',
    requirements: 'Experience with dogs',
    location: '321 Elm St, Austin, TX 78703',
    location_lat: 30.2853,
    location_lng: -97.7545,
    category: 'pet-care',
    price: 2500,
    state: TaskState.DISPUTED,
    mode: TaskMode.STANDARD,
    deadline: '2025-01-13T18:00:00Z',
    accepted_at: '2025-01-13T14:00:00Z',
    proof_submitted_at: '2025-01-13T15:30:00Z',
    requires_proof: true,
    proof_instructions: 'Photo with dog during walk',
    created_at: '2025-01-13T10:00:00Z',
    updated_at: '2025-01-13T16:00:00Z',
  },

  'task-completed': {
    id: 'task-completed',
    poster_id: 'user-poster-active',
    worker_id: 'user-hustler-active',
    title: 'Package delivery to downtown',
    description: 'Deliver a small package to downtown office building.',
    requirements: null,
    location: '100 Congress Ave, Austin, TX 78701',
    location_lat: 30.2639,
    location_lng: -97.7455,
    category: 'delivery',
    price: 1500,
    state: TaskState.COMPLETED,
    mode: TaskMode.STANDARD,
    deadline: '2025-01-14T18:00:00Z',
    accepted_at: '2025-01-14T09:00:00Z',
    proof_submitted_at: '2025-01-14T10:00:00Z',
    completed_at: '2025-01-14T10:15:00Z',
    requires_proof: true,
    proof_instructions: 'Photo of package at delivery location',
    created_at: '2025-01-14T08:00:00Z',
    updated_at: '2025-01-14T10:15:00Z',
  },

  'task-cancelled': {
    id: 'task-cancelled',
    poster_id: 'user-poster-new',
    worker_id: null,
    title: 'Yard work - mowing',
    description: 'Mow front and back yard.',
    requirements: 'Must have own mower',
    location: '555 Cedar Dr, Austin, TX 78745',
    location_lat: 30.2181,
    location_lng: -97.7694,
    category: 'yard-work',
    price: 5000,
    state: TaskState.CANCELLED,
    mode: TaskMode.STANDARD,
    deadline: '2025-01-15T18:00:00Z',
    cancelled_at: '2025-01-14T08:00:00Z',
    requires_proof: true,
    proof_instructions: 'Photo of completed yard',
    created_at: '2025-01-13T12:00:00Z',
    updated_at: '2025-01-14T08:00:00Z',
  },

  'task-expired': {
    id: 'task-expired',
    poster_id: 'user-poster-active',
    worker_id: null,
    title: 'Help with moving boxes',
    description: 'Need help loading boxes into truck.',
    requirements: 'Must be able to lift 30+ lbs',
    location: '999 First St, Austin, TX 78701',
    location_lat: 30.2700,
    location_lng: -97.7400,
    category: 'moving',
    price: 3000,
    state: TaskState.EXPIRED,
    mode: TaskMode.STANDARD,
    deadline: '2025-01-10T18:00:00Z',
    expired_at: '2025-01-10T18:00:00Z',
    requires_proof: true,
    proof_instructions: 'Photo of loaded truck',
    created_at: '2025-01-09T12:00:00Z',
    updated_at: '2025-01-10T18:00:00Z',
  },
};

/**
 * Get a task by ID
 * @param {string} taskId
 * @returns {Object|null}
 */
export const getTask = (taskId) => MOCK_TASKS[taskId] || null;

/**
 * Get all tasks
 * @returns {Object[]}
 */
export const getAllTasks = () => Object.values(MOCK_TASKS);

/**
 * Get tasks for feed (OPEN state only)
 * @param {Object} filters - Optional filters
 * @returns {Object[]}
 */
export const getTasksForFeed = (filters = {}) => {
  return Object.values(MOCK_TASKS)
    .filter(task => task.state === TaskState.OPEN)
    .filter(task => !filters.category || task.category === filters.category)
    .filter(task => !filters.maxPrice || task.price <= filters.maxPrice)
    .filter(task => !filters.minPrice || task.price >= filters.minPrice)
    .filter(task => !filters.mode || task.mode === filters.mode)
    .sort((a, b) => new Date(b.created_at) - new Date(a.created_at));
};

/**
 * Get tasks for a user
 * @param {string} userId
 * @param {string} role - 'poster' or 'worker'
 * @returns {Object[]}
 */
export const getTasksForUser = (userId, role) => {
  return Object.values(MOCK_TASKS)
    .filter(task => role === 'poster'
      ? task.poster_id === userId
      : task.worker_id === userId
    )
    .sort((a, b) => new Date(b.updated_at) - new Date(a.updated_at));
};

/**
 * Get active tasks for a worker
 * @param {string} workerId
 * @returns {Object[]}
 */
export const getActiveTasksForWorker = (workerId) => {
  return Object.values(MOCK_TASKS)
    .filter(task => task.worker_id === workerId)
    .filter(task => [TaskState.ACCEPTED, TaskState.PROOF_SUBMITTED].includes(task.state));
};

/**
 * Get tasks by state
 * @param {string} state
 * @returns {Object[]}
 */
export const getTasksByState = (state) => {
  return Object.values(MOCK_TASKS).filter(task => task.state === state);
};

/**
 * Format price from cents to display string
 * @param {number} priceInCents
 * @returns {string}
 */
export const formatPrice = (priceInCents) => {
  return `$${(priceInCents / 100).toFixed(2)}`;
};

export default MOCK_TASKS;
