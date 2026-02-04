/**
 * Adapter for TaskDetailScreen — maps GET /api/tasks/:id to screen props.
 * State: missing task or poster → error; eligibility.ineligible → blocked; else success.
 * Supports both mock and live data sources via source.ts configuration.
 */

import { taskDetailMock } from '../mocks/taskDetail.mock';
import { isLive } from '../source';
import { get, ENDPOINTS, buildUrl, toObservabilityErrorCode } from '../../network';
import { logError } from '../../observability';
import type { AdapterResult } from '../types';
import type { EligibilityStatus } from '../types';
import type { PosterSummary } from '../types';
import type { Task } from '../types';

export interface TaskDetailProps {
  task: Task;
  eligibilityStatus: EligibilityStatus;
  eligibilityReason: string | null;
  poster: PosterSummary;
}

const stubTask: Task = {
  id: '',
  title: '',
  description: '',
  status: 'open',
  priceAmount: 0,
  priceCurrency: 'USD',
  estimatedDuration: 0,
  requiredTrustTier: 0,
  location: { address: '', lat: 0, lng: 0 },
  category: '',
  createdAt: '',
  expiresAt: null,
};

const stubPoster: PosterSummary = { name: '', rating: 0, taskCount: 0 };

const stubProps: TaskDetailProps = {
  task: stubTask,
  eligibilityStatus: 'checking',
  eligibilityReason: null,
  poster: stubPoster,
};

export async function getTaskDetailData(
  taskId: string
): Promise<AdapterResult<TaskDetailProps>> {
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  let data: any;

  if (isLive(ENDPOINTS.TASK_DETAIL)) {
    const url = buildUrl(ENDPOINTS.TASK_DETAIL, { taskId });
    const result = await get<unknown>(url);

    if (!result.ok) {
      logError('network', toObservabilityErrorCode(result.error.code), result.error.message, {
        meta: {
          endpoint: ENDPOINTS.TASK_DETAIL,
          taskId,
          statusCode: result.error.statusCode,
        },
      });
      return { state: 'error', props: stubProps };
    }

    data = result.data;
  } else {
    data = taskDetailMock;
  }

  // Guard: task and poster must exist
  if (!data.task || !data.poster) {
    return { state: 'error', props: stubProps };
  }

  // Guard: task.id and task.title must be non-empty strings
  if (typeof data.task.id !== 'string' || !data.task.id || typeof data.task.title !== 'string') {
    return { state: 'error', props: stubProps };
  }

  // Guard: poster.name must be a string
  if (typeof data.poster.name !== 'string') {
    return { state: 'error', props: stubProps };
  }

  const eligibility = data.eligibility;
  const status = (eligibility?.status ?? 'checking') as EligibilityStatus;

  return {
    state: status === 'ineligible' ? 'blocked' : 'success',
    props: {
      task: data.task,
      eligibilityStatus: status,
      eligibilityReason: eligibility?.reason ?? null,
      poster: data.poster,
    },
  };
}
