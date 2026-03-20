/**
 * Adapter for TaskFeedScreen — maps GET /api/tasks/feed to screen props.
 * State: tasks.length === 0 → empty; missing lastUpdatedAt → error; else success.
 * Supports both mock and live data sources via source.ts configuration.
 */

import { taskFeedMock } from '../mocks/taskFeed.mock';
import { isLive } from '../source';
import { get, ENDPOINTS, buildUrl, toObservabilityErrorCode } from '../../network';
import { logError } from '../../observability';
import type { AdapterResult } from '../types';
import type { FilterState } from '../types';
import type { Task } from '../types';

export interface TaskFeedProps {
  tasks: Task[];
  hasMore: boolean;
  filters: FilterState;
  systemStatus: import('../types').SystemStatus | null;
  lastUpdatedAt: string;
}

const defaultFilters: FilterState = {};

const stubProps: TaskFeedProps = {
  tasks: [],
  hasMore: false,
  filters: defaultFilters,
  systemStatus: null,
  lastUpdatedAt: '',
};

export async function getTaskFeedData(): Promise<AdapterResult<TaskFeedProps>> {
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  let data: any;

  if (isLive(ENDPOINTS.TASK_FEED)) {
    const url = buildUrl(ENDPOINTS.TASK_FEED);
    const result = await get<unknown>(url);

    if (!result.ok) {
      logError('network', toObservabilityErrorCode(result.error.code), result.error.message, {
        meta: {
          endpoint: ENDPOINTS.TASK_FEED,
          statusCode: result.error.statusCode,
        },
      });
      return { state: 'error', props: stubProps };
    }

    data = result.data;
  } else {
    data = taskFeedMock;
  }

  if (typeof data.lastUpdatedAt !== 'string' || !data.lastUpdatedAt) {
    return { state: 'error', props: stubProps };
  }

  const tasks = Array.isArray(data.tasks) ? data.tasks : [];
  const state = tasks.length === 0 ? 'empty' : 'success';

  return {
    state,
    props: {
      tasks,
      hasMore: data.hasMore ?? false,
      filters: defaultFilters,
      systemStatus: data.systemStatus ?? null,
      lastUpdatedAt: data.lastUpdatedAt,
    },
  };
}
