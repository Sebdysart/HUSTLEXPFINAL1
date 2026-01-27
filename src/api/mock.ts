/**
 * Mock API - Development mock server
 * 
 * This intercepts API calls when USE_MOCK_API is true
 * and returns fake data for testing.
 */

import type { Task, TaskCategory } from '../store/taskStore';
import type { User } from './auth';

// Toggle this to use real API
export const USE_MOCK_API = __DEV__;

// Simulated network delay
const delay = (ms: number) => new Promise<void>(resolve => setTimeout(resolve, ms));

// Mock user database
const mockUsers: Map<string, User & { password: string }> = new Map([
  ['test@example.com', {
    id: 'user_1',
    email: 'test@example.com',
    password: 'password123',
    name: 'Test User',
    role: 'both',
    trustTier: 3,
    xp: 2500,
    onboardingComplete: true,
    createdAt: '2024-01-01T00:00:00Z',
  }],
]);

// Mock tasks
const mockTasks: Task[] = [
  {
    id: 'task_1',
    title: 'Help move furniture',
    description: 'Need help moving a couch and two chairs to my new apartment on the 3rd floor. Building has an elevator.',
    category: 'moving' as TaskCategory,
    status: 'open',
    posterId: 'poster_1',
    posterName: 'Sarah M.',
    address: '123 Main St, Seattle, WA 98101',
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
    id: 'task_2',
    title: 'Grocery delivery - Trader Joe\'s',
    description: 'Pick up groceries from Trader Joe\'s and deliver to my home. List will be provided via chat.',
    category: 'delivery' as TaskCategory,
    status: 'open',
    posterId: 'poster_2',
    posterName: 'Mike T.',
    address: '456 Oak Ave, Seattle, WA 98102',
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
    id: 'task_3',
    title: 'Fix leaky faucet',
    description: 'Bathroom sink faucet is dripping constantly. Need someone with plumbing experience.',
    category: 'handyman' as TaskCategory,
    status: 'open',
    posterId: 'poster_3',
    posterName: 'Emily R.',
    address: '789 Pine St, Bellevue, WA 98004',
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
  {
    id: 'task_4',
    title: 'Dog walking - 2 golden retrievers',
    description: 'Need someone to walk my two golden retrievers for about 45 mins. They are friendly but energetic!',
    category: 'pet_care' as TaskCategory,
    status: 'open',
    posterId: 'poster_4',
    posterName: 'Alex K.',
    address: '321 Maple Dr, Seattle, WA 98103',
    latitude: 47.6592,
    longitude: -122.3467,
    distance: 3.2,
    minPay: 20,
    maxPay: 30,
    baseXP: 75,
    estimatedMinutes: 45,
    requiredTrustTier: 1,
    requiresVehicle: false,
    requiresTools: [],
    requiresBackground: false,
  },
  {
    id: 'task_5',
    title: 'IKEA furniture assembly',
    description: 'Need help assembling a PAX wardrobe and MALM dresser. All parts and tools provided.',
    category: 'assembly' as TaskCategory,
    status: 'open',
    posterId: 'poster_5',
    posterName: 'Jordan P.',
    address: '555 Cedar Lane, Kirkland, WA 98033',
    latitude: 47.6769,
    longitude: -122.2060,
    distance: 10.2,
    minPay: 60,
    maxPay: 100,
    baseXP: 180,
    bonusXP: 50,
    estimatedMinutes: 120,
    requiredTrustTier: 2,
    requiresVehicle: true,
    requiresTools: [],
    requiresBackground: false,
  },
];

export const mockApi = {
  // Auth
  async login(email: string, password: string) {
    await delay(800);
    const user = mockUsers.get(email);
    
    if (!user || user.password !== password) {
      throw new Error('Invalid email or password');
    }
    
    // eslint-disable-next-line @typescript-eslint/no-unused-vars
    const { password: _pw, ...safeUser } = user;
    return {
      user: safeUser,
      tokens: {
        accessToken: 'mock_access_token_' + Date.now(),
        refreshToken: 'mock_refresh_token_' + Date.now(),
        expiresIn: 3600,
      },
    };
  },

  async signup(email: string, password: string, name: string) {
    await delay(1000);
    
    if (mockUsers.has(email)) {
      throw new Error('Email already registered');
    }
    
    const newUser: User & { password: string } = {
      id: 'user_' + Date.now(),
      email,
      password,
      name,
      role: 'hustler',
      trustTier: 1,
      xp: 0,
      onboardingComplete: false,
      createdAt: new Date().toISOString(),
    };
    
    mockUsers.set(email, newUser);
    // eslint-disable-next-line @typescript-eslint/no-unused-vars
    const { password: _pwd, ...safeUser } = newUser;
    
    return {
      user: safeUser,
      tokens: {
        accessToken: 'mock_access_token_' + Date.now(),
        refreshToken: 'mock_refresh_token_' + Date.now(),
        expiresIn: 3600,
      },
    };
  },

  // Tasks
  async getTasks(filters: { latitude?: number; longitude?: number } = {}) {
    await delay(500);
    
    let tasks = [...mockTasks];
    
    // Sort by distance if location provided
    if (filters.latitude && filters.longitude) {
      tasks.sort((a, b) => (a.distance || 0) - (b.distance || 0));
    }
    
    return {
      tasks,
      total: tasks.length,
      page: 1,
      hasMore: false,
    };
  },

  async getTask(taskId: string) {
    await delay(300);
    const task = mockTasks.find(t => t.id === taskId);
    if (!task) throw new Error('Task not found');
    return task;
  },

  async claimTask(taskId: string, hustlerId: string, hustlerName: string) {
    await delay(600);
    const task = mockTasks.find(t => t.id === taskId);
    if (!task) throw new Error('Task not found');
    if (task.status !== 'open') throw new Error('Task already claimed');
    
    task.status = 'claimed';
    task.hustlerId = hustlerId;
    task.hustlerName = hustlerName;
    task.claimedAt = new Date().toISOString();
    
    return task;
  },
};
