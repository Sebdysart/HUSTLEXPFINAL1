/**
 * XPBreakdownScreen — B3.6 Assembly
 *
 * Composes: StatusBanner, Progress, List pattern (molecule patterns)
 * Intent: Expose XP state and progression using assembly only.
 * No logic. No calculations. Registry-compliant layout only.
 */

import React from 'react';
import { View, Text, ScrollView, StyleSheet } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { StatusBanner } from '../../components/molecules';
import { SPACING } from '../../../constants';
import { BRAND, DARK, GRAY } from '../../../constants/colors';
import { FONT_SIZE } from '../../../constants/typography';

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

// --- XPBreakdownScreen ---
export default function XPBreakdownScreen() {
  return (
    <SafeAreaView style={styles.root} edges={['top']}>
      <ScrollView
        style={styles.scroll}
        contentContainerStyle={styles.scrollContent}
        showsVerticalScrollIndicator={false}
      >
        <StatusBanner
          tone="info"
          text="XP updates after task completion"
        />

        <View style={styles.spacerLg} />

        <Progress value={0.62} label="Level Progress" />

        <View style={styles.spacerLg} />

        <View style={styles.listRow}>
          <View style={styles.listRowText}>
            <Text style={styles.listHeadline}>XP Earned</Text>
            <Text style={styles.listBody}>Last 7 days</Text>
          </View>
          <View style={styles.badge}>
            <Text style={styles.badgeText}>+120 XP</Text>
          </View>
        </View>

        <View style={styles.spacerLg} />
      </ScrollView>
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
    paddingTop: SPACING[2],
  },
  spacerLg: {
    height: SPACING[6],
  },
  listRow: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingVertical: SPACING[3],
    paddingHorizontal: SPACING[4],
    backgroundColor: GRAY[50],
    borderRadius: 12,
    borderWidth: 1,
    borderColor: GRAY[200],
  },
  listRowText: {
    flex: 1,
  },
  listHeadline: {
    fontSize: FONT_SIZE.lg,
    fontWeight: '600' as const,
    color: GRAY[900],
    marginBottom: SPACING[1],
  },
  listBody: {
    fontSize: FONT_SIZE.base,
    color: GRAY[600],
    lineHeight: 22,
  },
  badge: {
    backgroundColor: BRAND.PRIMARY,
    paddingHorizontal: SPACING[3],
    paddingVertical: SPACING[2],
    borderRadius: 9999,
  },
  badgeText: {
    fontSize: FONT_SIZE.sm,
    fontWeight: '600' as const,
    color: DARK.TEXT,
  },
});
