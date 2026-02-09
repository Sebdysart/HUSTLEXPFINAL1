/**
 * StatusBanner Molecule
 *
 * AUTHORITY: HUSTLEXP-DOCS/ui-puzzle/molecules/StatusBanner.md
 * STATUS: LOCKED
 *
 * Purpose: System messages only - errors, maintenance, trust locks.
 * Composition: Surface, Icon, Text, Spacer, Badge (optional)
 *
 * FORBIDDEN: Retry logic, CTAs, animations, marketing copy.
 */

import React from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { GlassCard } from '../../../components';
import { SPACING } from '../../../constants';
import { STATUS, GRAY } from '../../../constants/colors';
import { FONT_SIZE } from '../../../constants/typography';

export interface StatusBannerProps {
  /** SF Symbol name (rendered as emoji/text for RN) */
  icon?: string;
  /** Primary message */
  title?: string;
  /** Secondary text (optional) */
  description?: string;
  /** Semantic variant */
  tone: 'info' | 'warning' | 'danger' | 'success';
  /** Simplified text prop for backward compatibility */
  text?: string;
}

const TONE_COLORS: Record<string, string> = {
  info: STATUS.INFO,
  warning: STATUS.WARNING,
  danger: STATUS.ERROR,
  success: STATUS.SUCCESS,
};

/**
 * StatusBanner - System status display molecule.
 * No business logic. Props only.
 */
export function StatusBanner({
  icon,
  title,
  description,
  tone,
  text,
}: StatusBannerProps) {
  const color = TONE_COLORS[tone] ?? STATUS.INFO;
  const displayTitle = title || text;

  return (
    <GlassCard variant="secondary">
      <View style={styles.container}>
        {/* Icon indicator */}
        <View style={[styles.dot, { backgroundColor: color }]} />

        {/* Text block */}
        <View style={styles.textBlock}>
          {icon && <Text style={styles.icon}>{icon}</Text>}
          {displayTitle && (
            <Text style={[styles.title, { color: color }]}>{displayTitle}</Text>
          )}
          {description && (
            <Text style={styles.description}>{description}</Text>
          )}
        </View>
      </View>
    </GlassCard>
  );
}

const styles = StyleSheet.create({
  container: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingVertical: SPACING[2],
    paddingHorizontal: SPACING[3],
  },
  dot: {
    width: 8,
    height: 8,
    borderRadius: 4,
    marginRight: SPACING[2],
  },
  icon: {
    fontSize: FONT_SIZE.base,
    marginRight: SPACING[1],
  },
  textBlock: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'center',
    flexWrap: 'wrap',
  },
  title: {
    fontSize: FONT_SIZE.sm,
    fontWeight: '500' as const,
  },
  description: {
    fontSize: FONT_SIZE.xs,
    color: GRAY[600],
    marginLeft: SPACING[1],
  },
});
