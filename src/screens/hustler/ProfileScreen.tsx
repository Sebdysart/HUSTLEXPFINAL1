/**
 * ProfileScreen - Hustler profile view
 */

import React from 'react';
import { View, StyleSheet, ScrollView, TouchableOpacity } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { useNavigation } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import type { RootStackParamList } from '../../navigation/types';

type NavigationProp = NativeStackNavigationProp<RootStackParamList>;
import { Text, Spacing, Card, TrustBadge, Button } from '../../components';
import { theme } from '../../theme';
import { useAuthStore, useTaskStore } from '../../store';

export function ProfileScreen() {
  const insets = useSafeAreaInsets();
  const navigation = useNavigation<NavigationProp>();
  const { user } = useAuthStore();
  const { tasks } = useTaskStore();
  
  const completedTasks = tasks.filter(t => t.status === 'completed');
  const totalEarned = completedTasks.reduce((sum, t) => sum + (t.finalPay || t.maxPay), 0);
  
  const handleSettings = () => navigation.navigate('Settings');
  const handleXPBreakdown = () => navigation.navigate('XPBreakdown');
  const handleTrustLadder = () => navigation.navigate('TrustTierLadder');

  return (
    <View style={[styles.container, { paddingTop: insets.top }]}>
      <ScrollView contentContainerStyle={styles.scroll}>
        {/* Profile Header */}
        <View style={styles.header}>
          <View style={styles.avatar}>
            <Text variant="hero">👤</Text>
          </View>
          <Spacing size={16} />
          <Text variant="title1" color="primary">{user?.name || 'Hustler'}</Text>
          <Text variant="body" color="secondary">{user?.email || 'Hustler'}</Text>
          <Spacing size={12} />
          <TouchableOpacity onPress={handleTrustLadder}>
            <TrustBadge level={user?.trustTier || 1} xp={user?.xp || 0} size="lg" />
          </TouchableOpacity>
          <Spacing size={8} />
          <Button variant="ghost" size="sm" onPress={handleXPBreakdown}>View XP Breakdown</Button>
        </View>

        <Spacing size={24} />

        {/* Stats */}
        <View style={styles.statsGrid}>
          <StatCard value={String(completedTasks.length || 47)} label="Tasks Done" />
          <StatCard value="4.9" label="Avg Rating" />
          <StatCard value="98%" label="Completion" />
          <StatCard value={`$${totalEarned > 0 ? totalEarned.toFixed(0) : '2.4k'}`} label="Total Earned" />
        </View>

        <Spacing size={24} />

        {/* Skills */}
        <Text variant="headline" color="primary">Skills</Text>
        <Spacing size={12} />
        <View style={styles.skills}>
          <SkillChip label="Moving" />
          <SkillChip label="Assembly" />
          <SkillChip label="Delivery" />
          <SkillChip label="Cleaning" />
          <SkillChip label="Tech Help" />
        </View>

        <Spacing size={24} />

        {/* Reviews */}
        <View style={styles.sectionHeader}>
          <Text variant="headline" color="primary">Recent Reviews</Text>
          <Button variant="ghost" size="sm" onPress={() => {}}>See all</Button>
        </View>
        <Spacing size={12} />
        <ReviewCard name="Sarah M." rating={5} text="Great job! Very careful with my furniture." date="2 days ago" />
        <Spacing size={12} />
        <ReviewCard name="Mike T." rating={5} text="Fast and efficient. Would hire again!" date="1 week ago" />

        <Spacing size={24} />

        {/* Actions */}
        <Button variant="secondary" size="md" onPress={handleSettings}>Settings</Button>
      </ScrollView>
    </View>
  );
}

function StatCard({ value, label }: { value: string; label: string }) {
  return (
    <Card variant="default" padding="md" style={styles.statCard}>
      <Text variant="title2" color="primary">{value}</Text>
      <Text variant="caption" color="secondary">{label}</Text>
    </Card>
  );
}

function SkillChip({ label }: { label: string }) {
  return (
    <View style={styles.skillChip}>
      <Text variant="caption" color="primary">{label}</Text>
    </View>
  );
}

function ReviewCard({ name, rating, text, date }: { name: string; rating: number; text: string; date: string }) {
  return (
    <Card variant="default" padding="md">
      <View style={styles.reviewHeader}>
        <Text variant="headline" color="primary">{name}</Text>
        <Text variant="caption" color="secondary">{'⭐'.repeat(rating)} • {date}</Text>
      </View>
      <Spacing size={4} />
      <Text variant="body" color="secondary">"{text}"</Text>
    </Card>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: theme.colors.surface.primary },
  scroll: { padding: theme.spacing[4] },
  header: { alignItems: 'center' },
  avatar: { width: 100, height: 100, borderRadius: 50, backgroundColor: theme.colors.surface.secondary, justifyContent: 'center', alignItems: 'center' },
  statsGrid: { flexDirection: 'row', flexWrap: 'wrap', gap: theme.spacing[3] },
  statCard: { width: '47%', alignItems: 'center' },
  skills: { flexDirection: 'row', flexWrap: 'wrap', gap: theme.spacing[2] },
  skillChip: { backgroundColor: theme.colors.surface.secondary, paddingHorizontal: theme.spacing[3], paddingVertical: theme.spacing[2], borderRadius: theme.radii.full },
  sectionHeader: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center' },
  reviewHeader: { flexDirection: 'row', justifyContent: 'space-between' },
});

export default ProfileScreen;
