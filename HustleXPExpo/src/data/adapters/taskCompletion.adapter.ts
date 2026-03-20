/**
 * Adapter for TaskCompletionScreen — maps GET /api/tasks/:id/completion to screen props.
 * State: missing task or earnings → error; else success.
 * Supports both mock and live data sources via source.ts configuration.
 */

import { taskCompletionMock } from '../mocks/taskCompletion.mock';
import { isLive } from '../source';
import { get, ENDPOINTS, buildUrl, toObservabilityErrorCode } from '../../network';
import { logError } from '../../observability';
import type { AdapterResult } from '../types';
import type { SubmissionStatus } from '../types';
import type { Task } from '../types';

export interface TaskCompletionProps {
  task: Task;
  submissionStatus: SubmissionStatus;
  rejectionReason: string | null;
  xpAwarded: number | null;
  earningsAmount: number;
}

const stubTask: Task = {
  id: '',
  title: '',
  description: '',
  status: 'completed',
  priceAmount: 0,
  priceCurrency: 'USD',
  estimatedDuration: 0,
  requiredTrustTier: 0,
  location: { address: '', lat: 0, lng: 0 },
  category: '',
  createdAt: '',
  expiresAt: null,
};

const stubProps: TaskCompletionProps = {
  task: stubTask,
  submissionStatus: 'pending',
  rejectionReason: null,
  xpAwarded: null,
  earningsAmount: 0,
};

export async function getTaskCompletionData(
  taskId: string
): Promise<AdapterResult<TaskCompletionProps>> {
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  let data: any;

  if (isLive(ENDPOINTS.TASK_COMPLETION)) {
    const url = buildUrl(ENDPOINTS.TASK_COMPLETION, { taskId });
    const result = await get<unknown>(url);

    if (!result.ok) {
      logError('network', toObservabilityErrorCode(result.error.code), result.error.message, {
        meta: {
          endpoint: ENDPOINTS.TASK_COMPLETION,
          taskId,
          statusCode: result.error.statusCode,
        },
      });
      return { state: 'error', props: stubProps };
    }

    data = result.data;
  } else {
    data = taskCompletionMock;
  }

  // Guard: task and earnings must exist
  if (!data.task || data.earnings === undefined) {
    return { state: 'error', props: stubProps };
  }

  // Guard: task.id must be non-empty string
  if (typeof data.task.id !== 'string' || !data.task.id) {
    return { state: 'error', props: stubProps };
  }

  // Guard: earnings.amount must be a number
  if (typeof data.earnings.amount !== 'number') {
    return { state: 'error', props: stubProps };
  }

  // Guard: submission.status must be valid enum if present
  const validStatuses: SubmissionStatus[] = ['pending', 'submitted', 'approved', 'rejected'];
  const submissionStatus = data.submission?.status ?? 'pending';
  if (!validStatuses.includes(submissionStatus)) {
    return { state: 'error', props: stubProps };
  }

  return {
    state: 'success',
    props: {
      task: data.task,
      submissionStatus,
      rejectionReason: data.submission?.rejectionReason ?? null,
      xpAwarded: data.earnings.xpAwarded ?? null,
      earningsAmount: data.earnings.amount,
    },
  };
}
