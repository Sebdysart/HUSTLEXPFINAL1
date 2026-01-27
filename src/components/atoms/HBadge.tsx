/**
 * HBadge - Badge/pill atom
 * 
 * CHOSEN-STATE CONTRACT:
 * - Implies status without demanding attention
 * - Soft glow on important states
 * - Never garish or alarming
 */

import React, { useEffect } from 'react';
import { View, StyleSheet, ViewStyle } from 'react-native';
import Animated, {
  useSharedValue,
  useAnimatedStyle,
  withRepeat,
  withSequence,
  withTiming,
  Easing,
} from 'react-native-reanimated';
import { HText } from './HText';
import { hustleColors, hustleRadii, hustleSpacing, hustleShadows } from '../../theme/hustle-tokens';

type BadgeVariant = 'default' | 'success' | 'warning' | 'error' | 'purple' | 'outline';
type BadgeSize = 'sm' | 'md' | 'lg';

interface HBadgeProps {
  children: React.ReactNode;
  variant?: BadgeVariant;
  size?: BadgeSize;
  /** Subtle pulse animation */
  pulsing?: boolean;
  /** Dot indicator */
  dot?: boolean;
  style?: ViewStyle;
}

const sizeConfig = {
  sm: { paddingH: 8, paddingV: 4, fontSize: 11 as const },
  md: { paddingH: 12, paddingV: 6, fontSize: 13 as const },
  lg: { paddingH: 16, paddingV: 8, fontSize: 14 as const },
};

const variantConfig = {
  default: {
    bg: hustleColors.glass.medium,
    border: hustleColors.glass.border,
    text: hustleColors.text.secondary,
  },
  success: {
    bg: `${hustleColors.semantic.success}22`,
    border: `${hustleColors.semantic.success}44`,
    text: hustleColors.semantic.success,
  },
  warning: {
    bg: `${hustleColors.semantic.warning}22`,
    border: `${hustleColors.semantic.warning}44`,
    text: hustleColors.semantic.warning,
  },
  error: {
    bg: `${hustleColors.semantic.error}22`,
    border: `${hustleColors.semantic.error}44`,
    text: hustleColors.semantic.error,
  },
  purple: {
    bg: `${hustleColors.purple.core}22`,
    border: `${hustleColors.purple.core}44`,
    text: hustleColors.purple.soft,
  },
  outline: {
    bg: 'transparent',
    border: hustleColors.glass.border,
    text: hustleColors.text.secondary,
  },
};

export const HBadge: React.FC<HBadgeProps> = ({
  children,
  variant = 'default',
  size = 'md',
  pulsing = false,
  dot = false,
  style,
}) => {
  const pulse = useSharedValue(1);
  const config = variantConfig[variant];
  const sizeConf = sizeConfig[size];

  useEffect(() => {
    if (pulsing) {
      pulse.value = withRepeat(
        withSequence(
          withTiming(1.05, { duration: 1500, easing: Easing.inOut(Easing.ease) }),
          withTiming(1, { duration: 1500, easing: Easing.inOut(Easing.ease) })
        ),
        -1,
        false
      );
    }
  }, [pulsing]);

  const animatedStyle = useAnimatedStyle(() => ({
    transform: [{ scale: pulse.value }],
  }));

  return (
    <Animated.View
      style={[
        styles.badge,
        {
          backgroundColor: config.bg,
          borderColor: config.border,
          paddingHorizontal: sizeConf.paddingH,
          paddingVertical: sizeConf.paddingV,
        },
        pulsing && variant === 'purple' && hustleShadows.purpleGlow,
        animatedStyle,
        style,
      ]}
    >
      {dot && <View style={[styles.dot, { backgroundColor: config.text }]} />}
      {typeof children === 'string' ? (
        <HText variant="caption" color={config.text} style={{ fontSize: sizeConf.fontSize }}>
          {children}
        </HText>
      ) : (
        children
      )}
    </Animated.View>
  );
};

/**
 * HTrustBadge - Trust tier badge
 * Implies: "You've already earned status"
 */
interface HTrustBadgeProps {
  tier: number;
  xp?: number;
  size?: BadgeSize;
}

export const HTrustBadge: React.FC<HTrustBadgeProps> = ({
  tier,
  xp,
  size = 'md',
}) => {
  const tierColors = [
    hustleColors.text.tertiary,     // Tier 0 (unranked)
    hustleColors.semantic.info,     // Tier 1 (Bronze)
    hustleColors.semantic.success,  // Tier 2 (Silver)
    hustleColors.semantic.warning,  // Tier 3 (Gold)
    hustleColors.purple.soft,       // Tier 4 (Platinum)
    hustleColors.purple.core,       // Tier 5 (Diamond)
  ];

  const color = tierColors[Math.min(tier, 5)];

  return (
    <HBadge
      variant="outline"
      size={size}
      pulsing={tier >= 4}
      style={{ borderColor: color }}
    >
      <View style={styles.trustContent}>
        <HText variant="caption" color={color} bold>
          ⚡ TIER {tier}
        </HText>
        {xp !== undefined && (
          <HText variant="caption" color="muted" style={styles.xpText}>
            {xp.toLocaleString()} XP
          </HText>
        )}
      </View>
    </HBadge>
  );
};

const styles = StyleSheet.create({
  badge: {
    flexDirection: 'row',
    alignItems: 'center',
    borderRadius: hustleRadii.full,
    borderWidth: 1,
    alignSelf: 'flex-start',
  },
  dot: {
    width: 6,
    height: 6,
    borderRadius: 3,
    marginRight: 6,
  },
  trustContent: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
  },
  xpText: {
    marginLeft: 4,
  },
});
