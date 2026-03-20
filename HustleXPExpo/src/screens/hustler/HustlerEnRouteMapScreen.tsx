/**
 * HustlerEnRouteMapScreen — B3.9 Assembly
 *
 * "Hustler is en route" state. Map as placeholder Surface. No SDK.
 * Composes: StatusBanner, Surface, Card, ActionBar (molecule patterns).
 * No logic. No conditionals. Registry-compliant layout only.
 */

import React from 'react';
import {
  View,
  Text,
  ScrollView,
  StyleSheet,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { GlassCard } from '../../../components';
import { StatusBanner, ActionBar } from '../../components/molecules';
import { SPACING, RADIUS } from '../../../constants';
import { BRAND, DARK, GRAY } from '../../../constants/colors';
import { FONT_SIZE } from '../../../constants/typography';

const MAP_PLACEHOLDER_HEIGHT = 240;

// --- HustlerEnRouteMapScreen ---
export default function HustlerEnRouteMapScreen() {
  return (
    <SafeAreaView style={styles.root} edges={['top']}>
      <ScrollView
        style={styles.scroll}
        contentContainerStyle={styles.scrollContent}
        showsVerticalScrollIndicator={false}
      >
        <StatusBanner
          tone="info"
          text="On the way — Navigate to the task location"
        />

        <View style={styles.spacer} />

        <View style={styles.mapPlaceholder}>
          <Text style={styles.mapIcon}>📍</Text>
          <Text style={styles.mapCaption}>
            Map preview (live map loads here)
          </Text>
        </View>

        <View style={styles.spacer} />

        <GlassCard variant="secondary">
          <View style={styles.cardContent}>
            <View style={styles.cardHeader}>
              <Text style={styles.cardTitle}>Help move couch to second floor</Text>
              <View style={styles.badge}>
                <Text style={styles.badgeText}>Active</Text>
              </View>
            </View>
            <Text style={styles.cardMeta}>123 Main St • $45</Text>
          </View>
        </GlassCard>

        <View style={styles.spacer} />
      </ScrollView>

      <ActionBar primaryLabel="Message Poster" secondaryLabel="Cancel Task" />
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
  spacer: {
    height: SPACING[4],
  },
  mapPlaceholder: {
    height: MAP_PLACEHOLDER_HEIGHT,
    backgroundColor: GRAY[200],
    borderRadius: RADIUS.lg,
    alignItems: 'center',
    justifyContent: 'center',
    overflow: 'hidden',
  },
  mapIcon: {
    fontSize: 48,
    marginBottom: SPACING[2],
  },
  mapCaption: {
    fontSize: FONT_SIZE.xs,
    color: GRAY[600],
  },
  cardContent: {
    padding: SPACING[4],
  },
  cardHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'flex-start',
    marginBottom: SPACING[2],
  },
  cardTitle: {
    fontSize: FONT_SIZE.lg,
    fontWeight: '600' as const,
    color: GRAY[900],
    flex: 1,
  },
  badge: {
    backgroundColor: BRAND.PRIMARY,
    paddingHorizontal: SPACING[2],
    paddingVertical: SPACING[1],
    borderRadius: RADIUS.full,
    marginLeft: SPACING[2],
  },
  badgeText: {
    fontSize: FONT_SIZE.xs,
    fontWeight: '600' as const,
    color: DARK.TEXT,
  },
  cardMeta: {
    fontSize: FONT_SIZE.sm,
    color: GRAY[600],
  },
});
