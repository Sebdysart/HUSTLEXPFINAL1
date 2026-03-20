/**
 * Skeleton Atom
 *
 * AUTHORITY: HUSTLEXP-DOCS/ui-puzzle/atoms/Skeleton.md
 * STATUS: LOCKED
 *
 * Purpose: Loading placeholders only.
 * Animation: Opacity pulse only (no shimmer, no gradients).
 *
 * FORBIDDEN: Fetching, conditional rendering, screen-specific sizing.
 */

import React, { useEffect, useRef } from 'react';
import { View, Animated, StyleSheet } from 'react-native';
import { SPACING, RADIUS } from '../../../constants';
import { GRAY } from '../../../constants/colors';

export type SkeletonVariant = 'card' | 'detail' | 'line';

export interface SkeletonProps {
  /** Skeleton variant determines size/shape */
  variant: SkeletonVariant;
}

const VARIANT_STYLES: Record<SkeletonVariant, { height: number; borderRadius: number }> = {
  card: {
    height: 120,
    borderRadius: RADIUS.lg,
  },
  detail: {
    height: 200,
    borderRadius: RADIUS.lg,
  },
  line: {
    height: 16,
    borderRadius: RADIUS.sm,
  },
};

/**
 * Skeleton - Loading placeholder atom.
 * No business logic. Props only.
 */
export function Skeleton({ variant }: SkeletonProps) {
  const opacity = useRef(new Animated.Value(0.4)).current;

  useEffect(() => {
    const pulse = Animated.loop(
      Animated.sequence([
        Animated.timing(opacity, {
          toValue: 1,
          duration: 800,
          useNativeDriver: true,
        }),
        Animated.timing(opacity, {
          toValue: 0.4,
          duration: 800,
          useNativeDriver: true,
        }),
      ])
    );

    pulse.start();

    return () => {
      pulse.stop();
    };
  }, [opacity]);

  const variantStyle = VARIANT_STYLES[variant];

  return (
    <Animated.View
      style={[
        styles.base,
        {
          height: variantStyle.height,
          borderRadius: variantStyle.borderRadius,
          opacity,
        },
      ]}
      accessibilityRole="none"
      accessibilityLabel="Loading"
    />
  );
}

/**
 * SkeletonGroup - Render multiple skeletons for list loading.
 * Convenience wrapper, no logic.
 */
export function SkeletonGroup({
  count = 3,
  variant = 'card',
}: {
  count?: number;
  variant?: SkeletonVariant;
}) {
  return (
    <View style={styles.group}>
      {Array.from({ length: count }).map((_, index) => (
        <View key={index} style={styles.groupItem}>
          <Skeleton variant={variant} />
        </View>
      ))}
    </View>
  );
}

const styles = StyleSheet.create({
  base: {
    backgroundColor: GRAY[200],
    width: '100%',
  },
  group: {
    width: '100%',
  },
  groupItem: {
    marginBottom: SPACING[4],
  },
});
