/**
 * ActionBar Molecule
 *
 * AUTHORITY: HUSTLEXP-DOCS/ui-puzzle/molecules/ActionBar.md
 * STATUS: LOCKED
 *
 * Purpose: Primary and secondary CTAs for TaskDetail, Completion, Onboarding.
 * Composition: Surface, Spacer, Button
 *
 * FORBIDDEN: More than 2 actions, inline business logic, tertiary actions.
 */

import React from 'react';
import { View, Text, TouchableOpacity, ActivityIndicator, StyleSheet } from 'react-native';
import { SPACING, RADIUS, TOUCH } from '../../../constants';
import { BRAND, GRAY, DARK } from '../../../constants/colors';
import { FONT_SIZE } from '../../../constants/typography';

export interface ActionBarPrimary {
  label: string;
  variant?: 'primary' | 'destructive';
  loading?: boolean;
  disabled?: boolean;
}

export interface ActionBarSecondary {
  label: string;
  loading?: boolean;
  disabled?: boolean;
}

export interface ActionBarProps {
  /** Primary CTA (required) */
  primary?: ActionBarPrimary;
  /** Secondary CTA (optional) */
  secondary?: ActionBarSecondary;
  /** Bar placement */
  placement?: 'fixed' | 'floating';
  /** Simplified props for backward compatibility */
  primaryLabel?: string;
  secondaryLabel?: string;
  /** Action handlers (passed from screen) */
  onPrimary?: () => void;
  onSecondary?: () => void;
}

/**
 * ActionBar - CTA display molecule.
 * No business logic. Props only.
 */
export function ActionBar({
  primary,
  secondary,
  primaryLabel,
  secondaryLabel,
  onPrimary,
  onSecondary,
}: ActionBarProps) {
  // Handle simplified props
  const primaryConfig: ActionBarPrimary = primary || {
    label: primaryLabel || 'Continue',
    variant: 'primary',
  };
  const secondaryConfig: ActionBarSecondary | undefined = secondary || (secondaryLabel ? {
    label: secondaryLabel,
  } : undefined);

  const isPrimaryDestructive = primaryConfig.variant === 'destructive';
  const isPrimaryDisabled = primaryConfig.disabled || primaryConfig.loading;
  const isSecondaryDisabled = secondaryConfig?.disabled || secondaryConfig?.loading;

  return (
    <View style={styles.container}>
      {/* Secondary action (optional, left side) */}
      {secondaryConfig && (
        <TouchableOpacity
          style={[styles.secondary, isSecondaryDisabled && styles.disabled]}
          onPress={onSecondary}
          disabled={isSecondaryDisabled}
          accessibilityRole="button"
          accessibilityLabel={secondaryConfig.label}
          accessibilityState={{ disabled: isSecondaryDisabled }}
        >
          {secondaryConfig.loading ? (
            <ActivityIndicator size="small" color={GRAY[600]} />
          ) : (
            <Text style={styles.secondaryText}>{secondaryConfig.label}</Text>
          )}
        </TouchableOpacity>
      )}

      {/* Spacer */}
      <View style={styles.spacer} />

      {/* Primary action (required, right side) */}
      <TouchableOpacity
        style={[
          styles.primary,
          isPrimaryDestructive && styles.primaryDestructive,
          isPrimaryDisabled && styles.disabled,
        ]}
        onPress={onPrimary}
        disabled={isPrimaryDisabled}
        accessibilityRole="button"
        accessibilityLabel={primaryConfig.label}
        accessibilityState={{ disabled: isPrimaryDisabled }}
      >
        {primaryConfig.loading ? (
          <ActivityIndicator size="small" color={DARK.TEXT} />
        ) : (
          <Text
            style={[
              styles.primaryText,
              isPrimaryDestructive && styles.primaryTextDestructive,
            ]}
          >
            {primaryConfig.label}
          </Text>
        )}
      </TouchableOpacity>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: SPACING[4],
    paddingVertical: SPACING[3],
    backgroundColor: GRAY[50],
    borderTopWidth: 1,
    borderTopColor: GRAY[200],
  },
  spacer: {
    flex: 1,
  },
  primary: {
    backgroundColor: BRAND.PRIMARY,
    paddingHorizontal: SPACING[6],
    paddingVertical: SPACING[3],
    borderRadius: RADIUS.xl,
    minHeight: TOUCH.min,
    alignItems: 'center',
    justifyContent: 'center',
  },
  primaryDestructive: {
    backgroundColor: '#EF4444', // STATUS.ERROR
  },
  primaryText: {
    fontSize: FONT_SIZE.base,
    fontWeight: '600' as const,
    color: DARK.TEXT,
  },
  primaryTextDestructive: {
    color: DARK.TEXT,
  },
  secondary: {
    paddingHorizontal: SPACING[4],
    paddingVertical: SPACING[3],
    borderRadius: RADIUS.lg,
    minHeight: TOUCH.min,
    alignItems: 'center',
    justifyContent: 'center',
    borderWidth: 1,
    borderColor: GRAY[300],
  },
  secondaryText: {
    fontSize: FONT_SIZE.base,
    fontWeight: '500' as const,
    color: GRAY[700],
  },
  disabled: {
    opacity: 0.6,
  },
});
