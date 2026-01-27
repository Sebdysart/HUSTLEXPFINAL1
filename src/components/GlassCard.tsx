/**
 * GlassCard - Premium glassmorphism card with neon accents
 * Top 1% fintech aesthetic
 */

import React from 'react';
import {
  View,
  StyleSheet,
  ViewStyle,
  Pressable,
  PressableProps,
} from 'react-native';
import Animated, {
  useSharedValue,
  useAnimatedStyle,
  withSpring,
  withTiming,
  interpolateColor,
} from 'react-native-reanimated';
import LinearGradient from 'react-native-linear-gradient';
import { BlurView } from '@react-native-community/blur';
import { neonColors, neonShadows, neonRadii, glassStyles } from '../theme/neon-tokens';

const AnimatedPressable = Animated.createAnimatedComponent(Pressable);

export interface GlassCardProps extends Omit<PressableProps, 'style'> {
  children: React.ReactNode;
  variant?: 'default' | 'elevated' | 'neon';
  glowColor?: string;
  padding?: 'none' | 'sm' | 'md' | 'lg' | 'xl';
  borderRadius?: keyof typeof neonRadii;
  style?: ViewStyle;
  animated?: boolean;
}

const paddingMap = {
  none: 0,
  sm: 12,
  md: 16,
  lg: 20,
  xl: 24,
};

export const GlassCard: React.FC<GlassCardProps> = ({
  children,
  variant = 'default',
  glowColor = neonColors.cyan,
  padding = 'lg',
  borderRadius = 'xl',
  style,
  animated = true,
  onPress,
  ...props
}) => {
  const scale = useSharedValue(1);
  const glowIntensity = useSharedValue(0);

  const handlePressIn = () => {
    if (animated) {
      scale.value = withSpring(0.98, { damping: 15, stiffness: 400 });
      glowIntensity.value = withTiming(1, { duration: 150 });
    }
  };

  const handlePressOut = () => {
    if (animated) {
      scale.value = withSpring(1, { damping: 15, stiffness: 400 });
      glowIntensity.value = withTiming(0, { duration: 200 });
    }
  };

  const animatedStyle = useAnimatedStyle(() => ({
    transform: [{ scale: scale.value }],
  }));

  const glowStyle = useAnimatedStyle(() => ({
    shadowOpacity: 0.15 + glowIntensity.value * 0.4,
    shadowRadius: 12 + glowIntensity.value * 8,
  }));

  const cardStyle: ViewStyle = {
    ...glassStyles.card,
    padding: paddingMap[padding],
    borderRadius: neonRadii[borderRadius],
    overflow: 'hidden',
  };

  const neonBorderStyle: ViewStyle = variant === 'neon' ? {
    borderWidth: 1,
    borderColor: glowColor,
    ...neonShadows.glow(glowColor, 0.3),
  } : {};

  const Content = (
    <View style={[cardStyle, neonBorderStyle, style]}>
      {/* Glass overlay */}
      <View style={StyleSheet.absoluteFill}>
        <LinearGradient
          colors={[
            'rgba(255,255,255,0.08)',
            'rgba(255,255,255,0.02)',
            'transparent',
          ]}
          start={{ x: 0, y: 0 }}
          end={{ x: 1, y: 1 }}
          style={StyleSheet.absoluteFill}
        />
      </View>
      {children}
    </View>
  );

  if (onPress) {
    return (
      <AnimatedPressable
        onPress={onPress}
        onPressIn={handlePressIn}
        onPressOut={handlePressOut}
        style={[
          animatedStyle,
          glowStyle,
          variant === 'elevated' && neonShadows.card,
        ]}
        {...props}
      >
        {Content}
      </AnimatedPressable>
    );
  }

  return (
    <Animated.View
      style={[
        variant === 'elevated' && neonShadows.card,
      ]}
    >
      {Content}
    </Animated.View>
  );
};

/**
 * NeonBadge - Glowing badge/pill component
 */
export interface NeonBadgeProps {
  children: React.ReactNode;
  color?: string;
  size?: 'sm' | 'md' | 'lg';
  pulsing?: boolean;
}

export const NeonBadge: React.FC<NeonBadgeProps> = ({
  children,
  color = neonColors.cyan,
  size = 'md',
  pulsing = false,
}) => {
  const pulseValue = useSharedValue(1);

  React.useEffect(() => {
    if (pulsing) {
      const pulse = () => {
        pulseValue.value = withTiming(1.1, { duration: 1000 }, () => {
          pulseValue.value = withTiming(1, { duration: 1000 });
        });
      };
      pulse();
      const interval = setInterval(pulse, 2000);
      return () => clearInterval(interval);
    }
  }, [pulsing, pulseValue]);

  const animatedStyle = useAnimatedStyle(() => ({
    transform: [{ scale: pulseValue.value }],
  }));

  const sizeStyles = {
    sm: { paddingHorizontal: 8, paddingVertical: 4, fontSize: 11 },
    md: { paddingHorizontal: 12, paddingVertical: 6, fontSize: 13 },
    lg: { paddingHorizontal: 16, paddingVertical: 8, fontSize: 15 },
  };

  return (
    <Animated.View
      style={[
        styles.badge,
        {
          backgroundColor: `${color}22`,
          borderColor: color,
          paddingHorizontal: sizeStyles[size].paddingHorizontal,
          paddingVertical: sizeStyles[size].paddingVertical,
        },
        neonShadows.glow(color, 0.4),
        animatedStyle,
      ]}
    >
      {children}
    </Animated.View>
  );
};

const styles = StyleSheet.create({
  badge: {
    borderRadius: neonRadii.full,
    borderWidth: 1,
    alignSelf: 'flex-start',
  },
});
