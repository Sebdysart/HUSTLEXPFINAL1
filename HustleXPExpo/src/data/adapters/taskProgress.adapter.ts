/**
 * Adapter for TaskInProgressScreen — maps GET /api/tasks/:id/progress to screen props.
 * State: missing task or destination → error; else success.
 * Supports both mock and live data sources via source.ts configuration.
 */

import { taskProgressMock } from '../mocks/taskProgress.mock';
import { isLive } from '../source';
import { get, ENDPOINTS, buildUrl, toObservabilityErrorCode } from '../../network';
import { logError } from '../../observability';
import type { AdapterResult, Task, TaskProgressState } from '../types';

export type { TaskProgressState };

export interface TaskProgressProps {
  task: Task;
  taskState: TaskProgressState;
  elapsedTime: number;
  destination: { lat: number; lng: number; address: string };
}

const stubTask: Task = {
  id: '',
  title: '',
  description: '',
  status: 'in_progress',
  priceAmount: 0,
  priceCurrency: 'USD',
  estimatedDuration: 0,
  requiredTrustTier: 0,
  location: { address: '', lat: 0, lng: 0 },
  category: '',
  createdAt: '',
  expiresAt: null,
};

const stubProps: TaskProgressProps = {
  task: stubTask,
  taskState: 'WORKING',
  elapsedTime: 0,
  destination: { lat: 0, lng: 0, address: '' },
};

export async function getTaskProgressData(
  taskId: string
): Promise<AdapterResult<TaskProgressProps>> {
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  let data: any;

  if (isLive(ENDPOINTS.TASK_PROGRESS)) {
    const url = buildUrl(ENDPOINTS.TASK_PROGRESS, { taskId });
    const result = await get<unknown>(url);

    if (!result.ok) {
      logError('network', toObservabilityErrorCode(result.error.code), result.error.message, {
        meta: {
          endpoint: ENDPOINTS.TASK_PROGRESS,
          taskId,
          statusCode: result.error.statusCode,
        },
      });
      return { state: 'error', props: stubProps };
    }

    data = result.data;
  } else {
    data = taskProgressMock;
  }

  // Guard: task and destination must exist
  if (!data.task || !data.destination) {
    return { state: 'error', props: stubProps };
  }

  // Guard: task.id must be non-empty string
  if (typeof data.task.id !== 'string' || !data.task.id) {
    return { state: 'error', props: stubProps };
  }

  // Guard: destination.address must be a string
  if (typeof data.destination.address !== 'string') {
    return { state: 'error', props: stubProps };
  }

  // Guard: state must be valid enum
  const validStates: TaskProgressState[] = ['EN_ROUTE', 'WORKING'];
  if (!validStates.includes(data.state)) {
    return { state: 'error', props: stubProps };
  }

  return {
    state: 'success',
    props: {
      task: data.task,
      taskState: data.state,
      elapsedTime: data.elapsedTime ?? 0,
      destination: data.destination,
    },
  };
}
