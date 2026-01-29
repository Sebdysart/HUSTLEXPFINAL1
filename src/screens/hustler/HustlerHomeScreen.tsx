/**
 * HustlerHomeScreen - Main dashboard for hustlers
 * 
 * CHOSEN-STATE: "Things are happening. You're next."
 * - System feels alive (ambient + signals)
 * - Never empty, always momentum
 * - Copy is human, confident, understated
 */

import React from 'react';
import { View, StyleSheet, TouchableOpacity } from 'react-native';
import { useNavigation } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';

import { 
  HScreen, 
  HText, 
  HCard, 
  HButton, 
  HMoney,
  HSignalStream,
  HActivityIndicator,
} from '../../components/atoms';
import { TrustBadge } from '../../components';
import { hustleColors, hustleSpacing } from '../../theme/hustle-tokens';
import { useAuthStore, Task } from '../../store';
import { useTasks } from '../../hooks';
import type { RootStackParamList } from '../../navigation/types';

type NavigationProp = NativeStackNavigationProp<RootStackParamList>;

// Activity signals - system is alive
const ACTIVITY_SIGNALS = [
  { text: 'Jake just completed a pickup in Capitol Hill', icon: '✓' },
  { text: '3 new tasks posted nearby', icon: '●' },
  { text: 'Maria earned $45 this hour', icon: '💰' },
  { text: 'New high-pay task in your zone', icon: '🔥' },
  { text: 'You\'re 12 XP from Tier 3', icon: '⚡' },
  { text: 'Peak hours starting soon', icon: '📈' },
];

export function HustlerHomeScreen() {
  const navigation = useNavigation<NavigationProp>();
  const { user } = useAuthStore();
  const { tasks } = useTasks();
  
  // Get 3 nearest tasks
  const nearbyTasks = [...tasks]
    .filter(t => t.status === 'open')
    .sort((a, b) => (a.distance || 0) - (b.distance || 0))
    .slice(0, 3);

  const handleFindTasks = () => navigation.navigate('TaskFeed');
  const handleMyTasks = () => navigation.navigate('TaskHistory');
  const handleEarnings = () => navigation.navigate('Earnings');
  const handleProfile = () => navigation.navigate('Profile');
  const handleTaskPress = (taskId: string) => navigation.navigate('TaskDetail', { taskId });
  const handleSeeAllTasks = () => navigation.navigate('TaskFeed');

  // Header component
  const header = (
    <View style={styles.header}>
      <View>
        <HText variant="footnote" color="secondary">
          {getGreeting()}, {user?.name?.split(' ')[0] || 'you'}
        </HText>
        <HActivityIndicator active label="Live" />
      </View>
      <TouchableOpacity onPress={() => navigation.navigate('TrustTierLadder')}>
        <TrustBadge level={user?.trustTier || 1} xp={user?.xp || 0} size="md" />
      </TouchableOpacity>
    </View>
  );

  return (
    <HScreen 
      ambient={true}
      header={header}
      scroll={true}
    >
      {/* Activity Signal Stream - "System is alive" */}
      <HSignalStream signals={ACTIVITY_SIGNALS} interval={4000} duration={3000} />
      
      <View style={styles.spacerMd} />

      {/* Earnings Card */}
      <HCard variant="success" padding="lg" onPress={handleEarnings}>
        <HText variant="footnote" color="secondary">This week</HText>
        <View style={styles.spacerXs} />
        <HMoney amount={347.50} size="lg" />
        <View style={styles.spacerMd} />
        <View style={styles.statsRow}>
          <StatItem label="Tasks" value="5" />
          <StatItem label="Hours" value="12" />
          <StatItem label="Rating" value="4.9" />
        </View>
      </HCard>

      <View style={styles.spacerLg} />

      {/* Quick Actions */}
      <HText variant="headline" color="primary">Jump in</HText>
      <View style={styles.spacerSm} />
      <View style={styles.actions}>
        <ActionCard emoji="🔍" label="Find" onPress={handleFindTasks} />
        <ActionCard emoji="📋" label="Active" onPress={handleMyTasks} />
        <ActionCard emoji="💰" label="Money" onPress={handleEarnings} />
        <ActionCard emoji="👤" label="You" onPress={handleProfile} />
      </View>

      <View style={styles.spacerXl} />

      {/* Nearby Tasks - NEVER empty */}
      <View style={styles.sectionHeader}>
        <HText variant="headline" color="primary">Around you</HText>
        <HButton variant="ghost" size="sm" onPress={handleSeeAllTasks}>
          See all
        </HButton>
      </View>
      <View style={styles.spacerSm} />
      
      {nearbyTasks.length === 0 ? (
        // No empty states - show momentum instead
        <HCard variant="outlined" padding="lg">
          <HText variant="body" color="secondary" center>
            Tasks are dropping in your area
          </HText>
          <View style={styles.spacerSm} />
          <HText variant="caption" color="tertiary" center>
            Pull down to refresh or browse what's out there
          </HText>
          <View style={styles.spacerMd} />
          <HButton variant="secondary" size="sm" onPress={handleFindTasks}>
            Let's go
          </HButton>
        </HCard>
      ) : (
        nearbyTasks.map((task, i) => (
          <React.Fragment key={task.id}>
            <TaskPreview task={task} onPress={() => handleTaskPress(task.id)} />
            {i < nearbyTasks.length - 1 && <View style={styles.spacerSm} />}
          </React.Fragment>
        ))
      )}

      <View style={styles.spacerXl} />

      {/* XP Progress */}
      <TouchableOpacity onPress={() => navigation.navigate('XPBreakdown')}>
        <HCard variant="default" padding="md">
          <View style={styles.xpHeader}>
            <HText variant="headline" color="primary">Progress</HText>
            <HText variant="caption" color="success">+{user?.xp || 0} XP</HText>
          </View>
          <View style={styles.spacerSm} />
          <View style={styles.xpBar}>
            <View style={[styles.xpFill, { width: `${Math.min((user?.xp || 0) / 5, 100)}%` }]} />
          </View>
          <View style={styles.spacerXs} />
          <HText variant="caption" color="tertiary">
            {500 - ((user?.xp || 0) % 500)} XP to level up
          </HText>
        </HCard>
      </TouchableOpacity>

      <View style={styles.spacerXl} />
    </HScreen>
  );
}

// Helper: time-aware greeting (human touch)
function getGreeting(): string {
  const hour = new Date().getHours();
  if (hour < 12) return 'Morning';
  if (hour < 17) return 'Afternoon';
  return 'Evening';
}

function StatItem({ label, value }: { label: string; value: string }) {
  return (
    <View style={styles.statItem}>
      <HText variant="title2" color="primary">{value}</HText>
      <HText variant="caption" color="tertiary">{label}</HText>
    </View>
  );
}

function ActionCard({ emoji, label, onPress }: { emoji: string; label: string; onPress: () => void }) {
  return (
    <TouchableOpacity onPress={onPress} style={styles.actionCard}>
      <HCard variant="default" padding="md">
        <View style={styles.actionCardInner}>
          <HText variant="title2">{emoji}</HText>
          <View style={styles.spacerXs} />
          <HText variant="caption" color="secondary" center>{label}</HText>
        </View>
      </HCard>
    </TouchableOpacity>
  );
}

interface TaskPreviewProps {
  task: Task;
  onPress: () => void;
}

function TaskPreview({ task, onPress }: TaskPreviewProps) {
  const formatDistance = (miles?: number) => {
    if (!miles) return 'nearby';
    return miles < 1 ? `${(miles * 5280).toFixed(0)} ft` : `${miles.toFixed(1)} mi`;
  };
  
  const formatTime = (minutes: number) => {
    if (minutes < 60) return `${minutes}m`;
    return `${Math.floor(minutes / 60)}h`;
  };

  return (
    <HCard variant="default" padding="md" onPress={onPress}>
      <View style={styles.taskRow}>
        <View style={styles.taskInfo}>
          <HText variant="headline" color="primary">{task.title}</HText>
          <HText variant="footnote" color="tertiary">
            {formatDistance(task.distance)} · {formatTime(task.estimatedMinutes)}
          </HText>
        </View>
        <View style={styles.taskRight}>
          <HMoney amount={task.maxPay} size="md" />
          <HText variant="caption" color="success">+{task.baseXP} XP</HText>
        </View>
      </View>
    </HCard>
  );
}

const styles = StyleSheet.create({
  header: { 
    flexDirection: 'row', 
    justifyContent: 'space-between', 
    alignItems: 'center',
    paddingHorizontal: hustleSpacing.lg,
    paddingVertical: hustleSpacing.sm,
  },
  statsRow: { 
    flexDirection: 'row', 
    justifyContent: 'space-around',
  },
  statItem: { 
    alignItems: 'center',
  },
  actions: { 
    flexDirection: 'row', 
    justifyContent: 'space-between',
  },
  actionCard: { 
    width: '23%',
  },
  actionCardInner: { 
    alignItems: 'center',
  },
  sectionHeader: { 
    flexDirection: 'row', 
    justifyContent: 'space-between', 
    alignItems: 'center',
  },
  taskRow: { 
    flexDirection: 'row', 
    justifyContent: 'space-between', 
    alignItems: 'center',
  },
  taskInfo: { 
    flex: 1,
  },
  taskRight: { 
    alignItems: 'flex-end',
  },
  xpHeader: { 
    flexDirection: 'row', 
    justifyContent: 'space-between', 
    alignItems: 'center',
  },
  xpBar: { 
    height: 8, 
    backgroundColor: hustleColors.glass.medium, 
    borderRadius: 4,
    overflow: 'hidden',
  },
  xpFill: { 
    height: '100%', 
    backgroundColor: hustleColors.purple.core,
    borderRadius: 4,
  },
  // Spacing utilities
  spacerXs: { height: hustleSpacing.xs },
  spacerSm: { height: hustleSpacing.sm },
  spacerMd: { height: hustleSpacing.md },
  spacerLg: { height: hustleSpacing.lg },
  spacerXl: { height: hustleSpacing.xl },
});

export default HustlerHomeScreen;
