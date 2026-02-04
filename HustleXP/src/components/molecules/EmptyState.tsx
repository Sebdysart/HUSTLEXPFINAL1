/**
 * EmptyState Molecule
 *
 * AUTHORITY: HUSTLEXP-DOCS/ui-puzzle/molecules/EmptyState.md
 * STATUS: LOCKED
 *
 * Purpose: Canonical zero-data representation.
 * Composition: Surface, Icon, Text, Spacer, Button (optional)
 *
 * FORBIDDEN: Custom illustrations, screen-specific copy, conditional logic,
 *            retry logic, loading indicators, animations, role-based copy.
 */

import React from 'react';
import { View, Text, TouchableOpacity, StyleSheet } from 'react-native';
import { SPACING, RADIUS } from '../../../constants';
import { BRAND, GRAY, DARK } from '../../../constants/colors';
import { FONT_SIZE } from '../../../constants/typography';

export interface EmptyStateAction {
  label: string;
  emphasis?: 'default' | 'highlighted';
}

export interface EmptyStateProps {
  /** SF Symbol name (rendered as emoji/text for RN) */
  icon: string;
  /** Primary message */
  title: string;
  /** Secondary text */
  description?: string;
  /** Optional action button */
  action?: EmptyStateAction;
  /** Visual tone */
  tone?: 'neutral' | 'informational';
  /** Action handler (passed from screen) */
  onAction?: () => void;
}

/**
 * EmptyState - Zero-data display molecule.
 * No business logic. Props only.
 */
export function EmptyState({
  icon,
  title,
  description,
  action,
  onAction,
}: EmptyStateProps) {
  return (
    <View style={styles.container}>
      {/* Icon */}
      <Text style={styles.icon}>{icon}</Text>

      {/* Title */}
      <Text style={styles.title}>{title}</Text>

      {/* Description (optional) */}
      {description && (
        <Text style={styles.description}>{description}</Text>
      )}

      {/* Action button (optional) */}
      {action && (
        <TouchableOpacity
          style={[
            styles.action,
            action.emphasis === 'highlighted' && styles.actionHighlighted,
          ]}
          onPress={onAction}
          accessibilityRole="button"
          accessibilityLabel={action.label}
        >
          <Text
            style={[
              styles.actionText,
              action.emphasis === 'highlighted' && styles.actionTextHighlighted,
            ]}
          >
            {action.label}
          </Text>
        </TouchableOpacity>
      )}
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    padding: SPACING[8],
    alignItems: 'center',
    justifyContent: 'center',
    flex: 1,
  },
  icon: {
    fontSize: 48,
    marginBottom: SPACING[4],
  },
  title: {
    fontSize: FONT_SIZE.lg,
    fontWeight: '600' as const,
    color: GRAY[900],
    textAlign: 'center',
    marginBottom: SPACING[2],
  },
  description: {
    fontSize: FONT_SIZE.sm,
    color: GRAY[600],
    textAlign: 'center',
  },
  action: {
    marginTop: SPACING[4],
    paddingHorizontal: SPACING[4],
    paddingVertical: SPACING[2],
    borderRadius: RADIUS.lg,
    borderWidth: 1,
    borderColor: GRAY[300],
  },
  actionHighlighted: {
    backgroundColor: BRAND.PRIMARY,
    borderColor: BRAND.PRIMARY,
  },
  actionText: {
    fontSize: FONT_SIZE.sm,
    fontWeight: '500' as const,
    color: GRAY[700],
  },
  actionTextHighlighted: {
    color: DARK.TEXT,
  },
});
