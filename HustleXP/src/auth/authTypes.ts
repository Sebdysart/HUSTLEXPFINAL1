import type { UserRole } from '../app/types';

export interface HXUser {
  id: string;
  name: string;
  email: string;
  phone?: string | null;
  bio?: string | null;
  avatarURL?: string | null;
  role: UserRole;
  trustTier: number;
  rating: number;
  totalRatings: number;
  xp: number;
  tasksCompleted: number;
  tasksPosted: number;
  totalEarnings: number;
  totalSpent: number;
  isVerified: boolean;
  createdAt: string;
}

