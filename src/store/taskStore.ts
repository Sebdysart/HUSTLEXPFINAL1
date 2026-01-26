/**
 * Task Store - Global task state management
 */

import { create } from 'zustand';

export type TaskStatus = 
  | 'open' 
  | 'claimed' 
  | 'in_progress' 
  | 'en_route'
  | 'arrived'
  | 'completed' 
  | 'cancelled'
  | 'disputed';

export type TaskCategory = 
  | 'delivery' 
  | 'moving' 
  | 'cleaning' 
  | 'handyman'
  | 'yard_work'
  | 'assembly'
  | 'pet_care'
  | 'errands'
  | 'tech_help'
  | 'other';

export interface Task {
  id: string;
  title: string;
  description: string;
  category: TaskCategory;
  status: TaskStatus;
  posterId: string;
  posterName: string;
  hustlerId?: string;
  hustlerName?: string;
  
  // Location
  address: string;
  latitude: number;
  longitude: number;
  distance?: number; // miles from hustler
  
  // Pricing
  minPay: number;
  maxPay: number;
  finalPay?: number;
  tipAmount?: number;
  
  // XP
  baseXP: number;
  bonusXP?: number;
  
  // Timing
  estimatedMinutes: number;
  actualMinutes?: number;
  scheduledFor?: string; // ISO date
  claimedAt?: string;
  startedAt?: string;
  completedAt?: string;
  
  // Requirements
  requiredTrustTier: 1 | 2 | 3 | 4 | 5;
  requiresVehicle: boolean;
  requiresTools: string[];
  requiresBackground: boolean;
  
  // Media
  photos?: string[];
  
  // Ratings (after completion)
  hustlerRating?: number;
  posterRating?: number;
  feedback?: string;
}

interface TaskState {
  tasks: Task[];
  activeTask: Task | null;
  isLoading: boolean;
  
  // Actions
  setTasks: (tasks: Task[]) => void;
  addTask: (task: Task) => void;
  updateTask: (id: string, updates: Partial<Task>) => void;
  setActiveTask: (task: Task | null) => void;
  claimTask: (taskId: string, hustlerId: string, hustlerName: string) => void;
  startTask: (taskId: string) => void;
  completeTask: (taskId: string, finalPay: number) => void;
  cancelTask: (taskId: string) => void;
  setLoading: (loading: boolean) => void;
}

// Mock initial tasks for development
const mockTasks: Task[] = [
  {
    id: '1',
    title: 'Help move furniture',
    description: 'Need help moving a couch and two chairs to my new apartment on the 3rd floor.',
    category: 'moving',
    status: 'open',
    posterId: 'poster1',
    posterName: 'Sarah M.',
    address: '123 Main St, Seattle, WA',
    latitude: 47.6062,
    longitude: -122.3321,
    distance: 2.3,
    minPay: 50,
    maxPay: 80,
    baseXP: 150,
    estimatedMinutes: 60,
    requiredTrustTier: 2,
    requiresVehicle: true,
    requiresTools: [],
    requiresBackground: false,
  },
  {
    id: '2',
    title: 'Grocery delivery',
    description: 'Pick up groceries from Trader Joe\'s and deliver to my home.',
    category: 'delivery',
    status: 'open',
    posterId: 'poster2',
    posterName: 'Mike T.',
    address: '456 Oak Ave, Seattle, WA',
    latitude: 47.6205,
    longitude: -122.3493,
    distance: 1.1,
    minPay: 15,
    maxPay: 25,
    baseXP: 50,
    estimatedMinutes: 30,
    requiredTrustTier: 1,
    requiresVehicle: false,
    requiresTools: [],
    requiresBackground: false,
  },
  {
    id: '3',
    title: 'Fix leaky faucet',
    description: 'Bathroom sink faucet is dripping constantly. Need someone with plumbing experience.',
    category: 'handyman',
    status: 'open',
    posterId: 'poster3',
    posterName: 'Emily R.',
    address: '789 Pine St, Bellevue, WA',
    latitude: 47.6101,
    longitude: -122.2015,
    distance: 8.5,
    minPay: 40,
    maxPay: 70,
    baseXP: 200,
    estimatedMinutes: 45,
    requiredTrustTier: 3,
    requiresVehicle: true,
    requiresTools: ['basic_plumbing'],
    requiresBackground: false,
  },
];

export const useTaskStore = create<TaskState>((set, get) => ({
  tasks: mockTasks,
  activeTask: null,
  isLoading: false,

  setTasks: (tasks) => set({ tasks }),

  addTask: (task) => set(state => ({ 
    tasks: [...state.tasks, task] 
  })),

  updateTask: (id, updates) => set(state => ({
    tasks: state.tasks.map(t => 
      t.id === id ? { ...t, ...updates } : t
    ),
    activeTask: state.activeTask?.id === id 
      ? { ...state.activeTask, ...updates }
      : state.activeTask,
  })),

  setActiveTask: (task) => set({ activeTask: task }),

  claimTask: (taskId, hustlerId, hustlerName) => {
    const now = new Date().toISOString();
    get().updateTask(taskId, { 
      status: 'claimed',
      hustlerId,
      hustlerName,
      claimedAt: now,
    });
  },

  startTask: (taskId) => {
    const now = new Date().toISOString();
    get().updateTask(taskId, { 
      status: 'in_progress',
      startedAt: now,
    });
  },

  completeTask: (taskId, finalPay) => {
    const now = new Date().toISOString();
    const task = get().tasks.find(t => t.id === taskId);
    const startedAt = task?.startedAt ? new Date(task.startedAt) : new Date();
    const actualMinutes = Math.round((new Date().getTime() - startedAt.getTime()) / 60000);
    
    get().updateTask(taskId, { 
      status: 'completed',
      completedAt: now,
      finalPay,
      actualMinutes,
    });
  },

  cancelTask: (taskId) => {
    get().updateTask(taskId, { status: 'cancelled' });
  },

  setLoading: (isLoading) => set({ isLoading }),
}));
