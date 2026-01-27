/**
 * ProfileScreen - Progress Archetype
 * 
 * EMOTIONAL CONTRACT: "Value is accumulating"
 * - HTrustBadge for tier display
 * - HMoney prominent for total earned
 * - HStatCard for metrics
 * - Quiet power, celebratory without being loud
 */

import React from 'react';
import { View, StyleSheet, ScrollView, TouchableOpacity } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { useNavigation } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import type { RootStackParamList } from '../../navigation/types';

import { HScreen, HText, HCard, HButton, HTrustBadge, HMoney, HStatCard, HBadge } from '../../components/atoms';
import { hustleColors, hustleSpacing, hustleRadii } from '../../theme/hustle-tokens';
import { useAuthStore, useTaskStore } from '../../store';

type NavigationProp = NativeStackNavigationProp<RootStackParamList>;

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
    <HScreen ambient>
      <ScrollView 
        contentContainerStyle={[styles.scroll, { paddingTop: insets.top + hustleSpacing.xl }]}
        showsVerticalScrollIndicator={false}
      >
        {/* Profile Header */}
        <View style={styles.header}>
          <View style={styles.avatar}>
            <HText variant="hero">👤</HText>
          </View>
          
          <HText variant="title1" color="primary" style={styles.name}>
            {user?.name || 'Hustler'}
          </HText>
          <HText variant="body" color="secondary">{user?.email || 'Ready to hustle'}</HText>
          
          {/* Trust Badge - Prominent */}
          <TouchableOpacity onPress={handleTrustLadder} style={styles.badgeContainer}>
            <HTrustBadge tier={user?.trustTier || 1} xp={user?.xp || 0} size="lg" />
          </TouchableOpacity>
          
          <HButton variant="ghost" size="sm" onPress={handleXPBreakdown}>
            View XP breakdown →
          </HButton>
        </View>

        {/* Stats Grid - HStatCard for metrics */}
        <View style={styles.statsGrid}>
          <HStatCard 
            label="Tasks done" 
            value={completedTasks.length || 47} 
            color={hustleColors.text.primary}
          />
          <HStatCard 
            label="Avg rating" 
            value="4.9" 
            color={hustleColors.xp.primary}
          />
          <HStatCard 
            label="Completion" 
            value="98%" 
            color={hustleColors.semantic.success}
          />
          <View style={styles.earningsCard}>
            <HMoney 
              amount={totalEarned > 0 ? totalEarned : 2400} 
              size="md" 
              label="You've earned"
              align="center"
            />
          </View>
        </View>

        {/* Skills */}
        <View style={styles.section}>
          <HText variant="headline" color="primary">Skills</HText>
        </View>
        
        <View style={styles.skills}>
          <SkillChip label="Moving" />
          <SkillChip label="Assembly" />
          <SkillChip label="Delivery" />
          <SkillChip label="Cleaning" />
          <SkillChip label="Tech Help" />
        </View>

        {/* Recent Reviews */}
        <View style={styles.section}>
          <HText variant="headline" color="primary">Recent Reviews</HText>
        </View>

        <ReviewCard 
          name="Sarah M." 
          rating={5} 
          text="Great job! Very careful with my furniture." 
          date="2 days ago" 
        />
        <ReviewCard 
          name="Mike T." 
          rating={5} 
          text="Fast and efficient. Would hire again!" 
          date="1 week ago" 
        />

        {/* Settings */}
        <HButton 
          variant="secondary" 
          size="md" 
          onPress={handleSettings}
          style={styles.settingsBtn}
        >
          Settings
        </HButton>
      </ScrollView>
    </HScreen>
  );
}

function SkillChip({ label }: { label: string }) {
  return (
    <View style={styles.skillChip}>
      <HText variant="caption" color="primary">{label}</HText>
    </View>
  );
}

interface ReviewCardProps {
  name: string;
  rating: number;
  text: string;
  date: string;
}

function ReviewCard({ name, rating, text, date }: ReviewCardProps) {
  return (
    <HCard variant="default" padding="lg" style={styles.reviewCard}>
      <View style={styles.reviewHeader}>
        <HText variant="headline" color="primary">{name}</HText>
        <HText variant="caption" color="tertiary">
          {'⭐'.repeat(rating)} • {date}
        </HText>
      </View>
      <HText variant="body" color="secondary" style={styles.reviewText}>
        "{text}"
      </HText>
    </HCard>
  );
}

const styles = StyleSheet.create({
  scroll: { 
    padding: hustleSpacing.lg,
    paddingBottom: hustleSpacing['4xl'],
  },
  header: { 
    alignItems: 'center',
    marginBottom: hustleSpacing.xl,
  },
  avatar: { 
    width: 100, 
    height: 100, 
    borderRadius: 50, 
    backgroundColor: hustleColors.dark.elevated, 
    justifyContent: 'center', 
    alignItems: 'center',
    borderWidth: 1,
    borderColor: hustleColors.glass.border,
  },
  name: {
    marginTop: hustleSpacing.lg,
  },
  badgeContainer: {
    marginTop: hustleSpacing.lg,
    marginBottom: hustleSpacing.sm,
  },
  statsGrid: { 
    flexDirection: 'row', 
    flexWrap: 'wrap', 
    gap: hustleSpacing.md,
    marginBottom: hustleSpacing.xl,
  },
  earningsCard: {
    flex: 1,
    minWidth: '47%',
    backgroundColor: hustleColors.dark.elevated,
    borderRadius: hustleRadii.xl,
    borderWidth: 1,
    borderColor: hustleColors.glass.border,
    padding: hustleSpacing.md,
  },
  section: {
    marginBottom: hustleSpacing.md,
  },
  skills: { 
    flexDirection: 'row', 
    flexWrap: 'wrap', 
    gap: hustleSpacing.sm,
    marginBottom: hustleSpacing.xl,
  },
  skillChip: { 
    backgroundColor: hustleColors.glass.medium, 
    paddingHorizontal: hustleSpacing.md, 
    paddingVertical: hustleSpacing.sm, 
    borderRadius: hustleRadii.full,
  },
  reviewCard: {
    marginBottom: hustleSpacing.md,
  },
  reviewHeader: { 
    flexDirection: 'row', 
    justifyContent: 'space-between',
    marginBottom: hustleSpacing.xs,
  },
  reviewText: {
    fontStyle: 'italic',
  },
  settingsBtn: {
    marginTop: hustleSpacing.xl,
  },
});

export default ProfileScreen;
