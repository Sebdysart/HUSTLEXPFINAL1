/**
 * TrustBadge Component
 * Displays user level and XP with a glowing effect
 */

import React, { useEffect } from 'react';
import { View, StyleSheet, ViewStyle } from 'react-native';
import Animated, {
  useSharedValue,
  useAnimatedStyle,
  withRepeat,
  withTiming,
  withSequence,
  interpolate,
  Easing,
} from 'react-native-reanimated';
import LinearGradient from 'react-native-linear-gradient';
import { colors, radii, spacing, shadows } from '../theme';
import { Text } from './Text';

export type BadgeSize = 'sm' | 'md' | 'lg';

export interface TrustBadgeProps {
  /** User's trust level (1-5 typical) */
  level: number;
  /** Current XP amount */
  xp: number;
  /** Badge size */
  size?: BadgeSize;
  /** Show XP progress bar */
  showProgress?: boolean;
  /** XP required for next level (for progress bar) */
  nextLevelXp?: number;
  /** Disable glow animation */
  disableGlow?: boolean;
  /** Custom style */
  style?: ViewStyle;
}

const sizeConfig: Record<BadgeSize, {
  badgeSize: number;
  fontSize: number;
  xpFontSize: number;
  iconSize: number;
  glowRadius: number;
}> = {
  sm: {
    badgeSize: 48,
    fontSize: 16,
    xpFontSize: 10,
    iconSize: 12,
    glowRadius: 8,
  },
  md: {
    badgeSize: 64,
    fontSize: 22,
    xpFontSize: 12,
    iconSize: 14,
    glowRadius: 12,
  },
  lg: {
    badgeSize: 80,
    fontSize: 28,
    xpFontSize: 14,
    iconSize: 16,
    glowRadius: 16,
  },
};

// Level colors get more vibrant as level increases
const getLevelColor = (level: number): string[] => {
  if (level <= 1) return ['#8E8E93', '#636366']; // Gray
  if (level <= 2) return ['#5856D6', '#4240A0']; // Purple
  if (level <= 3) return ['#FF9500', '#CC7700']; // Orange
  if (level <= 4) return ['#34C759', '#248A3D']; // Green
  return ['#FFD700', '#FFA500']; // Gold for max level
};

const formatXP = (xp: number): string => {
  if (xp >= 1000000) return `${(xp / 1000000).toFixed(1)}M`;
  if (xp >= 1000) return `${(xp / 1000).toFixed(1)}K`;
  return xp.toString();
};

export const TrustBadge: React.FC<TrustBadgeProps> = ({
  level,
  xp,
  size = 'md',
  showProgress = false,
  nextLevelXp,
  disableGlow = false,
  style,
}) => {
  const glowAnimation = useSharedValue(0);
  const pulseAnimation = useSharedValue(1);

  const config = sizeConfig[size];
  const levelColors = getLevelColor(level);

  useEffect(() => {
    if (!disableGlow) {
      // Glow pulsing animation
      glowAnimation.value = withRepeat(
        withSequence(
          withTiming(1, { duration: 1500, easing: Easing.inOut(Easing.ease) }),
          withTiming(0, { duration: 1500, easing: Easing.inOut(Easing.ease) })
        ),
        -1,
        false
      );

      // Subtle scale pulse
      pulseAnimation.value = withRepeat(
        withSequence(
          withTiming(1.02, { duration: 2000, easing: Easing.inOut(Easing.ease) }),
          withTiming(1, { duration: 2000, easing: Easing.inOut(Easing.ease) })
        ),
        -1,
        false
      );
    }
  }, [disableGlow, glowAnimation, pulseAnimation]);

  const glowStyle = useAnimatedStyle(() => {
    const glowOpacity = interpolate(glowAnimation.value, [0, 1], [0.4, 0.8]);
    const glowScale = interpolate(glowAnimation.value, [0, 1], [1, 1.15]);

    return {
      opacity: glowOpacity,
      transform: [{ scale: glowScale }],
    };
  });

  const badgeStyle = useAnimatedStyle(() => ({
    transform: [{ scale: pulseAnimation.value }],
  }));

  const progress = showProgress && nextLevelXp ? Math.min(xp / nextLevelXp, 1) : 0;

  return (
    <View style={[styles.container, style]}>
      {/* Glow effect */}
      {!disableGlow && (
        <Animated.View
          style={[
            styles.glow,
            {
              width: config.badgeSize + config.glowRadius * 2,
              height: config.badgeSize + config.glowRadius * 2,
              borderRadius: (config.badgeSize + config.glowRadius * 2) / 2,
              backgroundColor: levelColors[0],
            },
            glowStyle,
          ]}
        />
      )}

      {/* Badge */}
      <Animated.View style={badgeStyle}>
        <LinearGradient
          colors={levelColors}
          start={{ x: 0, y: 0 }}
          end={{ x: 1, y: 1 }}
          style={[
            styles.badge,
            {
              width: config.badgeSize,
              height: config.badgeSize,
              borderRadius: config.badgeSize / 2,
            },
          ]}
        >
          <Text
            style={[styles.levelText, { fontSize: config.fontSize }]}
            color="primary"
            bold
          >
            {level}
          </Text>
        </LinearGradient>
      </Animated.View>

      {/* XP Display */}
      <View style={styles.xpContainer}>
        <Text
          variant="caption"
          color={colors.secondary}
          bold
          style={[styles.xpText, { fontSize: config.xpFontSize }]}
        >
          {formatXP(xp)} XP
        </Text>

        {/* Progress bar */}
        {showProgress && nextLevelXp && (
          <View style={styles.progressContainer}>
            <View style={styles.progressBackground}>
              <LinearGradient
                colors={colors.gradients.xp as unknown as string[]}
                start={{ x: 0, y: 0 }}
                end={{ x: 1, y: 0 }}
                style={[styles.progressFill, { width: `${progress * 100}%` }]}
              />
            </View>
          </View>
        )}
      </View>
    </View>
  );
};

// Compact inline version
export interface TrustBadgeInlineProps {
  level: number;
  xp?: number;
  size?: 'sm' | 'md';
}

export const TrustBadgeInline: React.FC<TrustBadgeInlineProps> = ({
  level,
  xp,
  size = 'sm',
}) => {
  const levelColors = getLevelColor(level);
  const badgeSize = size === 'sm' ? 24 : 32;
  const fontSize = size === 'sm' ? 12 : 14;

  return (
    <View style={styles.inlineContainer}>
      <LinearGradient
        colors={levelColors}
        start={{ x: 0, y: 0 }}
        end={{ x: 1, y: 1 }}
        style={[
          styles.inlineBadge,
          {
            width: badgeSize,
            height: badgeSize,
            borderRadius: badgeSize / 2,
          },
        ]}
      >
        <Text style={[styles.inlineLevelText, { fontSize }]}>
          {level}
        </Text>
      </LinearGradient>
      {xp !== undefined && (
        <Text variant="caption" color={colors.secondary} bold>
          {formatXP(xp)}
        </Text>
      )}
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    alignItems: 'center',
    justifyContent: 'center',
  },
  glow: {
    position: 'absolute',
  },
  badge: {
    alignItems: 'center',
    justifyContent: 'center',
    ...shadows.md,
  },
  levelText: {
    color: colors.white,
  },
  xpContainer: {
    marginTop: spacing.sm,
    alignItems: 'center',
  },
  xpText: {
    color: colors.secondary,
  },
  progressContainer: {
    marginTop: spacing.xs,
    width: 60,
  },
  progressBackground: {
    height: 4,
    backgroundColor: colors.surface.tertiary,
    borderRadius: radii.full,
    overflow: 'hidden',
  },
  progressFill: {
    height: '100%',
    borderRadius: radii.full,
  },
  // Inline styles
  inlineContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: spacing.xs,
  },
  inlineBadge: {
    alignItems: 'center',
    justifyContent: 'center',
  },
  inlineLevelText: {
    fontWeight: '700',
    color: colors.white,
  },
});

export default TrustBadge;
