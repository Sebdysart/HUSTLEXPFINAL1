/**
 * HustlerProfileScreen — B3.7 Assembly
 *
 * Archetype: E — Progress / Status
 * Composes: Surface, Avatar pattern, Text, Badge, Progress, List pattern, ActionBar
 * Intent: Profile composition template for Hustler role.
 * No logic. No fetching. Registry-compliant layout only.
 */

import React from 'react';
import {
  View,
  Text,
  ScrollView,
  StyleSheet,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { ActionBar } from '../../components/molecules';
import { SPACING, RADIUS } from '../../../constants';
import { BRAND, DARK, STATUS, GRAY } from '../../../constants/colors';
import { FONT_SIZE } from '../../../constants/typography';

const AVATAR_SIZE_LG = 80;

// --- Avatar (atom pattern, placeholder) ---
function Avatar({ size = 'lg' }: { size?: 'lg' }) {
  const sizePx = size === 'lg' ? AVATAR_SIZE_LG : AVATAR_SIZE_LG;
  return (
    <View
      style={[
        avatarStyles.circle,
        { width: sizePx, height: sizePx, borderRadius: sizePx / 2 },
      ]}
    />
  );
}

const avatarStyles = StyleSheet.create({
  circle: {
    backgroundColor: GRAY[300],
  },
});

// --- Progress (local atom, not a molecule) ---
function Progress({
  value,
  label,
}: {
  value: number;
  label?: string;
}) {
  return (
    <View style={progressStyles.wrapper}>
      {label && (
        <Text style={progressStyles.label}>{label}</Text>
      )}
      <View style={progressStyles.track}>
        <View
          style={[
            progressStyles.fill,
            {
              width: `${Math.max(0, Math.min(1, value)) * 100}%`,
            },
          ]}
        />
      </View>
    </View>
  );
}

const progressStyles = StyleSheet.create({
  wrapper: {
    marginBottom: SPACING[2],
  },
  label: {
    fontSize: FONT_SIZE.sm,
    color: GRAY[600],
    marginBottom: SPACING[2],
  },
  track: {
    height: 6,
    backgroundColor: GRAY[200],
    borderRadius: 3,
    overflow: 'hidden',
  },
  fill: {
    height: '100%',
    backgroundColor: BRAND.PRIMARY,
    borderRadius: 3,
  },
});

// --- HustlerProfileScreen ---
const STATS_ROWS = [
  { label: 'Completed Tasks', value: '24' },
  { label: 'Success Rate', value: '98%' },
  { label: 'Response Time', value: '< 1 hr' },
];

export default function HustlerProfileScreen() {
  return (
    <SafeAreaView style={styles.root} edges={['top']}>
      <ScrollView
        style={styles.scroll}
        contentContainerStyle={styles.scrollContent}
        showsVerticalScrollIndicator={false}
      >
        <View style={styles.header}>
          <Avatar size="lg" />
          <View style={styles.spacer} />
          <Text style={styles.userName}>Alex Hustler</Text>
          <View style={styles.spacerSm} />
          <Text style={styles.roleLabel}>Hustler</Text>
          <View style={styles.spacerSm} />
          <View style={styles.badge}>
            <Text style={styles.badgeText}>Trust Tier I</Text>
          </View>
        </View>

        <View style={styles.spacer} />

        <Progress value={0.6} label="XP Progress" />
        <Text style={styles.progressCaption}>Level 4</Text>

        <View style={styles.spacer} />

        <View style={styles.statsList}>
          {STATS_ROWS.map((row, index) => (
            <View
              key={index}
              style={[
                styles.statsRow,
                index < STATS_ROWS.length - 1 && styles.statsRowBorder,
              ]}
            >
              <Text style={styles.statsLabel}>{row.label}</Text>
              <Text style={styles.statsValue}>{row.value}</Text>
            </View>
          ))}
        </View>

        <View style={styles.spacer} />

        <View style={styles.footerSpacer} />
      </ScrollView>

      <ActionBar primaryLabel="Edit Profile" secondaryLabel="Settings" />
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  root: {
    flex: 1,
    backgroundColor: GRAY[50],
  },
  scroll: {
    flex: 1,
  },
  scrollContent: {
    paddingHorizontal: SPACING[4],
    paddingTop: SPACING[4],
  },
  header: {
    alignItems: 'center',
    paddingVertical: SPACING[4],
  },
  spacer: {
    height: SPACING[4],
  },
  spacerSm: {
    height: SPACING[2],
  },
  userName: {
    fontSize: FONT_SIZE['2xl'],
    fontWeight: '600' as const,
    color: GRAY[900],
  },
  roleLabel: {
    fontSize: FONT_SIZE.xs,
    color: GRAY[600],
  },
  badge: {
    backgroundColor: STATUS.SUCCESS,
    paddingHorizontal: SPACING[3],
    paddingVertical: SPACING[2],
    borderRadius: RADIUS.full,
    marginTop: SPACING[2],
  },
  badgeText: {
    fontSize: FONT_SIZE.sm,
    fontWeight: '600' as const,
    color: DARK.TEXT,
  },
  progressCaption: {
    fontSize: FONT_SIZE.xs,
    color: GRAY[600],
    marginTop: SPACING[1],
  },
  statsList: {
    backgroundColor: GRAY[50],
    borderRadius: 12,
    borderWidth: 1,
    borderColor: GRAY[200],
    overflow: 'hidden',
  },
  statsRow: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingVertical: SPACING[3],
    paddingHorizontal: SPACING[4],
  },
  statsRowBorder: {
    borderBottomWidth: 1,
    borderBottomColor: GRAY[200],
  },
  statsLabel: {
    fontSize: FONT_SIZE.base,
    color: GRAY[700],
  },
  statsValue: {
    fontSize: FONT_SIZE.lg,
    fontWeight: '600' as const,
    color: GRAY[900],
  },
  footerSpacer: {
    height: SPACING[8],
  },
});
