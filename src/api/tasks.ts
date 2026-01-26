/**
 * Tasks API - Task management endpoints
 */

import { api } from './client';
import type { Task, TaskStatus, TaskCategory } from '../store/taskStore';

export interface TaskFilters {
  status?: TaskStatus[];
  category?: TaskCategory[];
  minPay?: number;
  maxDistance?: number;
  latitude?: number;
  longitude?: number;
  page?: number;
  limit?: number;
}

export interface TaskListResponse {
  tasks: Task[];
  total: number;
  page: number;
  hasMore: boolean;
}

export interface CreateTaskRequest {
  title: string;
  description: string;
  category: TaskCategory;
  address: string;
  latitude: number;
  longitude: number;
  minPay: number;
  maxPay: number;
  estimatedMinutes: number;
  scheduledFor?: string;
  requiredTrustTier?: 1 | 2 | 3 | 4 | 5;
  requiresVehicle?: boolean;
  requiresTools?: string[];
  requiresBackground?: boolean;
  photos?: string[];
}

export const tasksApi = {
  /**
   * Get available tasks for hustler
   */
  async getAvailableTasks(filters: TaskFilters = {}) {
    const params: string[] = [];
    
    if (filters.status) params.push(`status=${filters.status.join(',')}`);
    if (filters.category) params.push(`category=${filters.category.join(',')}`);
    if (filters.minPay) params.push(`minPay=${filters.minPay}`);
    if (filters.maxDistance) params.push(`maxDistance=${filters.maxDistance}`);
    if (filters.latitude) params.push(`lat=${filters.latitude}`);
    if (filters.longitude) params.push(`lng=${filters.longitude}`);
    if (filters.page) params.push(`page=${filters.page}`);
    if (filters.limit) params.push(`limit=${filters.limit}`);

    const queryString = params.length > 0 ? `?${params.join('&')}` : '';
    return api.get<TaskListResponse>(`/tasks${queryString}`);
  },

  /**
   * Get task details
   */
  async getTask(taskId: string) {
    return api.get<Task>(`/tasks/${taskId}`);
  },

  /**
   * Create a new task (poster)
   */
  async createTask(data: CreateTaskRequest) {
    return api.post<Task>('/tasks', data);
  },

  /**
   * Update task
   */
  async updateTask(taskId: string, updates: Partial<Task>) {
    return api.patch<Task>(`/tasks/${taskId}`, updates);
  },

  /**
   * Claim a task (hustler)
   */
  async claimTask(taskId: string) {
    return api.post<Task>(`/tasks/${taskId}/claim`);
  },

  /**
   * Start working on task
   */
  async startTask(taskId: string) {
    return api.post<Task>(`/tasks/${taskId}/start`);
  },

  /**
   * Mark as en route
   */
  async setEnRoute(taskId: string, location: { latitude: number; longitude: number }) {
    return api.post<Task>(`/tasks/${taskId}/en-route`, location);
  },

  /**
   * Mark as arrived
   */
  async markArrived(taskId: string) {
    return api.post<Task>(`/tasks/${taskId}/arrived`);
  },

  /**
   * Complete task
   */
  async completeTask(taskId: string, data: {
    finalPay: number;
    photos?: string[];
    notes?: string;
  }) {
    return api.post<Task>(`/tasks/${taskId}/complete`, data);
  },

  /**
   * Cancel task
   */
  async cancelTask(taskId: string, reason?: string) {
    return api.post<Task>(`/tasks/${taskId}/cancel`, { reason });
  },

  /**
   * Rate task (after completion)
   */
  async rateTask(taskId: string, data: {
    rating: number;
    feedback?: string;
  }) {
    return api.post<Task>(`/tasks/${taskId}/rate`, data);
  },

  /**
   * Get my posted tasks (poster)
   */
  async getMyPostedTasks(filters: TaskFilters = {}) {
    const params: string[] = [];
    if (filters.status) params.push(`status=${filters.status.join(',')}`);
    if (filters.page) params.push(`page=${filters.page}`);
    if (filters.limit) params.push(`limit=${filters.limit}`);

    const queryString = params.length > 0 ? `?${params.join('&')}` : '';
    return api.get<TaskListResponse>(`/tasks/my-posts${queryString}`);
  },

  /**
   * Get my claimed/completed tasks (hustler)
   */
  async getMyHustles(filters: TaskFilters = {}) {
    const params: string[] = [];
    if (filters.status) params.push(`status=${filters.status.join(',')}`);
    if (filters.page) params.push(`page=${filters.page}`);
    if (filters.limit) params.push(`limit=${filters.limit}`);

    const queryString = params.length > 0 ? `?${params.join('&')}` : '';
    return api.get<TaskListResponse>(`/tasks/my-hustles${queryString}`);
  },

  /**
   * File a dispute
   */
  async fileDispute(taskId: string, data: {
    reason: string;
    description: string;
    photos?: string[];
  }) {
    return api.post<{ disputeId: string }>(`/tasks/${taskId}/dispute`, data);
  },

  /**
   * Update hustler location during task
   */
  async updateLocation(taskId: string, location: { latitude: number; longitude: number }) {
    return api.post<void>(`/tasks/${taskId}/location`, location);
  },
};
