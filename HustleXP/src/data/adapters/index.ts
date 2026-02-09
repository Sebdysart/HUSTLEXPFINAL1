/**
 * Central exports for adapters — clean, explicit exports only.
 */

export { getHustlerHomeData } from './hustlerHome.adapter';
export type { HustlerHomeProps } from './hustlerHome.adapter';

export { getTaskFeedData } from './taskFeed.adapter';
export type { TaskFeedProps } from './taskFeed.adapter';

export { getTaskDetailData } from './taskDetail.adapter';
export type { TaskDetailProps } from './taskDetail.adapter';

export { getTaskProgressData } from './taskProgress.adapter';
export type { TaskProgressProps, TaskProgressState } from './taskProgress.adapter';

export { getTaskCompletionData } from './taskCompletion.adapter';
export type { TaskCompletionProps } from './taskCompletion.adapter';

export { getXPData } from './xp.adapter';
export type { XPBreakdownProps } from './xp.adapter';
