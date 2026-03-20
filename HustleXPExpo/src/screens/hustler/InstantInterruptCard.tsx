/**
 * InstantInterruptCard — B3.8 Assembly
 *
 * System-level interrupt (safety, escalation, time-critical).
 * Composes: StatusBanner, Card, ActionBar (molecule patterns).
 * No logic. No conditionals. Registry-compliant layout only.
 */

import React from 'react';
import {
  View,
  Text,
  StyleSheet,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { GlassCard } from '../../../components';
import { StatusBanner, ActionBar } from '../../components/molecules';
import { SPACING } from '../../../constants';
import { GRAY } from '../../../constants/colors';
import { FONT_SIZE } from '../../../constants/typography';

// --- InstantInterruptCard ---
export default function InstantInterruptCard() {
  return (
    <SafeAreaView style={styles.root} edges={['top']}>
      <View style={styles.content}>
        <StatusBanner
          tone="danger"
          text="Immediate Action Required"
        />

        <View style={styles.spacer} />

        <GlassCard variant="secondary">
          <View style={styles.cardContent}>
            <Text style={styles.cardTitle}>Task requires your attention</Text>
            <Text style={styles.cardBody}>
              A system message has been sent. Please review and take action as needed.
            </Text>
          </View>
        </GlassCard>

        <View style={styles.spacer} />
      </View>

      <ActionBar primaryLabel="Resolve Now" secondaryLabel="Contact Support" />
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  root: {
    flex: 1,
    backgroundColor: GRAY[50],
  },
  content: {
    flex: 1,
    paddingHorizontal: SPACING[4],
    paddingTop: SPACING[4],
  },
  spacer: {
    height: SPACING[4],
  },
  cardContent: {
    padding: SPACING[4],
  },
  cardTitle: {
    fontSize: FONT_SIZE.lg,
    fontWeight: '600' as const,
    color: GRAY[900],
    marginBottom: SPACING[2],
  },
  cardBody: {
    fontSize: FONT_SIZE.base,
    color: GRAY[600],
    lineHeight: 22,
  },
});
