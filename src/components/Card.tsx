/**
 * Card Component
 * Glass morphism style card with variants
 */

import React from 'react';
import {
  View,
  ViewProps,
  ViewStyle,
  StyleProp,
} from 'react-native';
import Animated, {
  useSharedValue,
  useAnimatedStyle,
  withSpring,
} from 'react-native-reanimated';
import { colors, radii, spacing, shadows } from '../theme';

export type CardVariant = 'default' | 'elevated';
export type CardPadding = 'none' | 'sm' | 'md' | 'lg';

export interface CardProps extends ViewProps {
  /** Card variant */
  variant?: CardVariant;
  /** Padding preset */
  padding?: CardPadding;
  /** Enable press animation */
  pressable?: boolean;
  /** On press handler (only when pressable) */
  onPress?: () => void;
  /** Custom border radius */
  radius?: 'sm' | 'md' | 'lg';
  /** Children */
  children: React.ReactNode;
  /** Custom style */
  style?: StyleProp<ViewStyle>;
}

const paddingMap: Record<CardPadding, number> = {
  none: 0,
  sm: spacing.sm,
  md: spacing.lg,
  lg: spacing['2xl'],
};

export const Card: React.FC<CardProps> = ({
  variant = 'default',
  padding = 'md',
  pressable = false,
  onPress,
  radius = 'lg',
  children,
  style,
  ...props
}) => {
  const scale = useSharedValue(1);

  const handlePressIn = () => {
    if (pressable) {
      scale.value = withSpring(0.98, { damping: 15, stiffness: 400 });
    }
  };

  const handlePressOut = () => {
    if (pressable) {
      scale.value = withSpring(1, { damping: 15, stiffness: 400 });
    }
  };

  const animatedStyle = useAnimatedStyle(() => ({
    transform: [{ scale: scale.value }],
  }));

  const getContainerStyle = (): ViewStyle => {
    const base: ViewStyle = {
      borderRadius: radii[radius],
      padding: paddingMap[padding],
      overflow: 'hidden',
    };

    switch (variant) {
      case 'elevated':
        return {
          ...base,
          backgroundColor: colors.surface.secondary,
          ...shadows.lg,
        };
      default:
        // Glass morphism style
        return {
          ...base,
          backgroundColor: `${colors.surface.secondary}CC`, // 80% opacity
          borderWidth: 1,
          borderColor: `${colors.surface.tertiary}80`, // 50% opacity
        };
    }
  };

  const containerStyle = getContainerStyle();

  if (pressable) {
    const Pressable = require('react-native').Pressable;
    return (
      <Pressable
        onPress={onPress}
        onPressIn={handlePressIn}
        onPressOut={handlePressOut}
      >
        <Animated.View style={[containerStyle, animatedStyle, style]} {...props}>
          {children}
        </Animated.View>
      </Pressable>
    );
  }

  return (
    <View style={[containerStyle, style]} {...props}>
      {children}
    </View>
  );
};

// Convenience variants
export const ElevatedCard: React.FC<Omit<CardProps, 'variant'>> = (props) => (
  <Card variant="elevated" {...props} />
);

export const PressableCard: React.FC<Omit<CardProps, 'pressable'>> = (props) => (
  <Card pressable {...props} />
);

export default Card;
