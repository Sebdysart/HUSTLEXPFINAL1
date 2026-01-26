/**
 * useTasks - Hook for fetching and managing tasks
 */

import { useState, useEffect, useCallback } from 'react';
import { useTaskStore, Task } from '../store';
import { tasksApi, TaskFilters } from '../api/tasks';
import { mockApi, USE_MOCK_API } from '../api/mock';

interface UseTasksOptions {
  autoFetch?: boolean;
  filters?: TaskFilters;
}

interface UseTasksReturn {
  tasks: Task[];
  isLoading: boolean;
  error: string | null;
  hasMore: boolean;
  refresh: () => Promise<void>;
  loadMore: () => Promise<void>;
  claimTask: (taskId: string) => Promise<boolean>;
}

export function useTasks(options: UseTasksOptions = {}): UseTasksReturn {
  const { autoFetch = true, filters = {} } = options;
  const { tasks, setTasks, setLoading, isLoading } = useTaskStore();
  
  const [error, setError] = useState<string | null>(null);
  const [hasMore, setHasMore] = useState(false);
  const [page, setPage] = useState(1);

  const fetchTasks = useCallback(async (pageNum: number = 1) => {
    setLoading(true);
    setError(null);

    try {
      if (USE_MOCK_API) {
        const result = await mockApi.getTasks(filters);
        if (pageNum === 1) {
          setTasks(result.tasks);
        } else {
          setTasks([...tasks, ...result.tasks]);
        }
        setHasMore(result.hasMore);
      } else {
        const response = await tasksApi.getAvailableTasks({ ...filters, page: pageNum });
        if (response.ok) {
          if (pageNum === 1) {
            setTasks(response.data.tasks);
          } else {
            setTasks([...tasks, ...response.data.tasks]);
          }
          setHasMore(response.data.hasMore);
        } else {
          setError(response.error || 'Failed to fetch tasks');
        }
      }
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Failed to fetch tasks');
    } finally {
      setLoading(false);
    }
  }, [filters, tasks, setTasks, setLoading]);

  const refresh = useCallback(async () => {
    setPage(1);
    await fetchTasks(1);
  }, [fetchTasks]);

  const loadMore = useCallback(async () => {
    if (!hasMore || isLoading) return;
    const nextPage = page + 1;
    setPage(nextPage);
    await fetchTasks(nextPage);
  }, [hasMore, isLoading, page, fetchTasks]);

  const claimTask = useCallback(async (taskId: string): Promise<boolean> => {
    try {
      if (USE_MOCK_API) {
        await mockApi.claimTask(taskId, 'user_1', 'Test User');
        await refresh();
        return true;
      } else {
        const response = await tasksApi.claimTask(taskId);
        if (response.ok) {
          await refresh();
          return true;
        }
        setError(response.error || 'Failed to claim task');
        return false;
      }
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Failed to claim task');
      return false;
    }
  }, [refresh]);

  useEffect(() => {
    if (autoFetch) {
      fetchTasks(1);
    }
  }, [autoFetch]);

  return {
    tasks,
    isLoading,
    error,
    hasMore,
    refresh,
    loadMore,
    claimTask,
  };
}
