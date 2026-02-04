/**
 * TaskCard Molecule
 *
 * AUTHORITY: HUSTLEXP-DOCS/ui-puzzle/molecules/TaskCard.md
 * STATUS: LOCKED
 *
 * Purpose: Canonical task representation across HustleXP.
 * Composition: Card (base), Text, Badge, Progress, Icon, Spacer, Surface
 *
 * FORBIDDEN: Navigation, onPress handlers, async logic, animations,
 *            conditionals based on user role.
 */

import React from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { GlassCard } from '../../../components';
import { SPACING, RADIUS } from '../../../constants';
import { BRAND, DARK, GRAY } from '../../../constants/colors';
import { FONT_SIZE } from '../../../constants/typography';

export interface TaskCardBadge {
  label: string;
  tone: 'neutral' | 'positive' | 'warning' | 'critical';
}

export interface TaskCardProgress {
  value: number; // 0-1
  label?: string;
}

export interface TaskCardProps {
  /** Task title */
  title: string;
  /** Task status */
  status?: 'open' | 'assigned' | 'in_progress' | 'completed' | 'disputed';
  /** Price display */
  priceLabel: string;
  /** Time, urgency, or distance */
  metaLabel?: string;
  /** Optional status badge (string for backward compatibility) */
  badge?: string | TaskCardBadge;
  /** 0-1; maps to Progress atom */
  progress?: TaskCardProgress;
  /** Footer text */
  footerLabel?: string;
  /** Visual emphasis */
  emphasis?: 'default' | 'highlighted';
}

/**
 * TaskCard - Task display molecule.
 * No business logic. Props only.
 */
export function TaskCard({
  title,
  priceLabel,
  metaLabel,
  badge,
  progress,
  footerLabel,
  emphasis = 'default',
}: TaskCardProps) {
  const isHighlighted = emphasis === 'highlighted';

  // Handle badge as string or object
  const badgeLabel = typeof badge === 'string' ? badge : badge?.label;
  const badgeHighlight = typeof badge === 'object' && badge?.tone === 'positive';

  return (
    <GlassCard variant={isHighlighted ? 'primary' : 'secondary'}>
      <View style={styles.container}>
        {/* Header: Title + Badge */}
        <View style={styles.header}>
          <Text style={styles.title} numberOfLines={2}>
            {title}
          </Text>
          {badgeLabel && (
            <View
              style={[
                styles.badge,
                (isHighlighted || badgeHighlight) && styles.badgeHighlighted,
              ]}
            >
              <Text
                style={[
                  styles.badgeText,
                  (isHighlighted || badgeHighlight) && styles.badgeTextHighlighted,
                ]}
              >
                {badgeLabel}
              </Text>
            </View>
          )}
        </View>

        {/* Meta: Price + Time/Distance */}
        <View style={styles.meta}>
          <Text style={styles.price}>{priceLabel}</Text>
          {metaLabel && <Text style={styles.metaLabel}>{metaLabel}</Text>}
        </View>

        {/* Progress (optional) */}
        {progress && (
          <View style={styles.progressContainer}>
            <View style={styles.progressTrack}>
              <View
                style={[
                  styles.progressFill,
                  { width: `${Math.min(100, Math.max(0, progress.value * 100))}%` },
                ]}
              />
            </View>
            {progress.label && (
              <Text style={styles.progressLabel}>{progress.label}</Text>
            )}
          </View>
        )}

        {/* Footer (optional) */}
        {footerLabel && (
          <Text style={styles.footer}>{footerLabel}</Text>
        )}
      </View>
    </GlassCard>
  );
}

const styles = StyleSheet.create({
  container: {
    padding: SPACING[4],
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'flex-start',
    marginBottom: SPACING[2],
  },
  title: {
    fontSize: FONT_SIZE.lg,
    fontWeight: '600' as const,
    color: GRAY[900],
    flex: 1,
  },
  badge: {
    backgroundColor: GRAY[200],
    paddingHorizontal: SPACING[2],
    paddingVertical: SPACING[1],
    borderRadius: RADIUS.full,
    marginLeft: SPACING[2],
  },
  badgeHighlighted: {
    backgroundColor: BRAND.PRIMARY,
  },
  badgeText: {
    fontSize: FONT_SIZE.xs,
    fontWeight: '600' as const,
    color: GRAY[700],
  },
  badgeTextHighlighted: {
    color: DARK.TEXT,
  },
  meta: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: SPACING[2],
  },
  price: {
    fontSize: FONT_SIZE.base,
    fontWeight: '600' as const,
    color: BRAND.PRIMARY,
  },
  metaLabel: {
    fontSize: FONT_SIZE.sm,
    color: GRAY[600],
  },
  progressContainer: {
    marginTop: SPACING[3],
  },
  progressTrack: {
    height: 4,
    backgroundColor: GRAY[200],
    borderRadius: 2,
    overflow: 'hidden',
  },
  progressFill: {
    height: '100%',
    backgroundColor: BRAND.PRIMARY,
    borderRadius: 2,
  },
  progressLabel: {
    fontSize: FONT_SIZE.xs,
    color: GRAY[600],
    marginTop: SPACING[1],
  },
  footer: {
    fontSize: FONT_SIZE.sm,
    color: GRAY[600],
    marginTop: SPACING[2],
  },
});
