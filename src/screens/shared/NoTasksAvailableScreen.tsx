/**
 * NoTasksAvailableScreen - Feed Archetype (B)
 * "Things are happening. You're next."
 * 
 * NEVER shows empty state - always implies momentum
 */

import React from 'react';
import { View, StyleSheet, RefreshControl } from 'react-native';
import { useNavigation } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import type { RootStackParamList } from '../../navigation/types';
import {
  HScreen,
  HText,
  HCard,
  HButton,
  HSignalStream,
  HActivityIndicator,
} from '../../components/atoms';
import { hustleColors, hustleSpacing } from '../../theme/hustle-tokens';

type NavigationProp = NativeStackNavigationProp<RootStackParamList>;

function getTimeGreeting(): string {
  const hour = new Date().getHours();
  if (hour < 12) return 'Morning';
  if (hour < 17) return 'Afternoon';
  if (hour < 21) return 'Evening';
  return 'Night owl';
}

export function NoTasksAvailableScreen() {
  const navigation = useNavigation<NavigationProp>();
  const [refreshing, setRefreshing] = React.useState(false);

  const handleRefresh = async () => {
    setRefreshing(true);
    await new Promise<void>(r => setTimeout(r, 800));
    setRefreshing(false);
  };

  const greeting = getTimeGreeting();

  return (
    <HScreen
      ambient
      scroll
      refreshControl={
        <RefreshControl
          refreshing={refreshing}
          onRefresh={handleRefresh}
          tintColor={hustleColors.purple.core}
        />
      }
    >
      {/* Floating Activity Signals - Proof of Life */}
      <HSignalStream
        signals={[
          { text: 'Tasks dropping in your area', icon: '📍' },
          { text: '$89 earned nearby this hour', icon: '💸' },
          { text: '12 hustlers active around you', icon: '👥' },
        ]}
      />

      {/* Header */}
      <View style={styles.header}>
        <HText variant="body" color="secondary">{greeting}, hustler</HText>
        <HText variant="title1" color="primary">Scanning your area...</HText>
      </View>

      {/* Activity Card - Implies momentum */}
      <HCard variant="elevated" padding="lg" style={styles.activityCard}>
        <View style={styles.scanningRow}>
          <HActivityIndicator />
          <HText variant="headline" color="primary">Fresh tasks incoming</HText>
        </View>
        <HText variant="body" color="secondary" style={styles.activityText}>
          Pull down to catch the latest drops. Tasks are being posted throughout the day.
        </HText>
      </HCard>

      {/* Stats - Social Proof */}
      <HCard variant="default" padding="md" style={styles.proofCard}>
        <HText variant="caption" color="secondary" style={styles.proofLabel}>Around you today</HText>
        <View style={styles.proofRow}>
          <View style={styles.proofStat}>
            <HText variant="title2" color="primary">47</HText>
            <HText variant="caption" color="secondary">Tasks posted</HText>
          </View>
          <View style={styles.proofStat}>
            <HText variant="title2" color="primary">$2.4k</HText>
            <HText variant="caption" color="secondary">Paid out</HText>
          </View>
          <View style={styles.proofStat}>
            <HText variant="title2" color="primary">23</HText>
            <HText variant="caption" color="secondary">Hustlers active</HText>
          </View>
        </View>
      </HCard>

      {/* Tips - Positioned as optimization, not desperation */}
      <HCard variant="default" padding="md" style={styles.tipsCard}>
        <HText variant="headline" color="primary">Catch more tasks</HText>
        <View style={styles.tips}>
          <TipItem icon="📍" text="Expand your radius" />
          <TipItem icon="🔔" text="Turn on push notifications" />
          <TipItem icon="⚡" text="Add more skills" />
        </View>
      </HCard>

      {/* CTAs */}
      <View style={styles.ctas}>
        <HButton variant="primary" size="lg" onPress={() => navigation.navigate('Settings')}>
          Let's go
        </HButton>
        <HButton variant="secondary" size="md" onPress={() => navigation.navigate('TaskFeed')}>
          Browse what's out there
        </HButton>
      </View>
    </HScreen>
  );
}

function TipItem({ icon, text }: { icon: string; text: string }) {
  return (
    <View style={styles.tipRow}>
      <HText variant="body">{icon}</HText>
      <HText variant="body" color="secondary" style={styles.tipText}>{text}</HText>
    </View>
  );
}

const styles = StyleSheet.create({
  header: {
    marginBottom: hustleSpacing.xl,
  },
  activityCard: {
    marginBottom: hustleSpacing.lg,
  },
  scanningRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: hustleSpacing.md,
    marginBottom: hustleSpacing.sm,
  },
  activityText: {
    marginTop: hustleSpacing.xs,
  },
  proofCard: {
    marginBottom: hustleSpacing.lg,
  },
  proofLabel: {
    textAlign: 'center',
    marginBottom: hustleSpacing.md,
  },
  proofRow: {
    flexDirection: 'row',
    justifyContent: 'space-around',
  },
  proofStat: {
    alignItems: 'center',
  },
  tipsCard: {
    marginBottom: hustleSpacing.xl,
  },
  tips: {
    marginTop: hustleSpacing.md,
    gap: hustleSpacing.sm,
  },
  tipRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: hustleSpacing.md,
  },
  tipText: {
    flex: 1,
  },
  ctas: {
    gap: hustleSpacing.md,
  },
});

export default NoTasksAvailableScreen;
