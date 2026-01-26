/**
 * Button Component
 * Primary action component with variants and loading state
 */

import React from 'react';
import {
  Pressable,
  PressableProps,
  StyleSheet,
  ActivityIndicator,
  ViewStyle,
  TextStyle,
  View,
} from 'react-native';
import Animated, {
  useSharedValue,
  useAnimatedStyle,
  withSpring,
  withTiming,
  interpolate,
} from 'react-native-reanimated';
import LinearGradient from 'react-native-linear-gradient';
import { colors, radii, spacing, touchTargets, typography, durations } from '../theme';
import { Text } from './Text';

const AnimatedPressable = Animated.createAnimatedComponent(Pressable);

export type ButtonVariant = 'primary' | 'secondary' | 'ghost' | 'danger';
export type ButtonSize = 'sm' | 'md' | 'lg';

export interface ButtonProps extends Omit<PressableProps, 'style'> {
  /** Button variant */
  variant?: ButtonVariant;
  /** Button size */
  size?: ButtonSize;
  /** Button text */
  children: string;
  /** Loading state */
  loading?: boolean;
  /** Disabled state */
  disabled?: boolean;
  /** Full width */
  fullWidth?: boolean;
  /** Left icon */
  leftIcon?: React.ReactNode;
  /** Right icon */
  rightIcon?: React.ReactNode;
  /** Custom style */
  style?: ViewStyle;
}

const sizeConfig: Record<ButtonSize, { height: number; paddingHorizontal: number; textVariant: 'footnote' | 'callout' | 'headline' }> = {
  sm: {
    height: touchTargets.min,
    paddingHorizontal: spacing.lg,
    textVariant: 'footnote',
  },
  md: {
    height: touchTargets.comfortable,
    paddingHorizontal: spacing.xl,
    textVariant: 'callout',
  },
  lg: {
    height: touchTargets.large,
    paddingHorizontal: spacing['2xl'],
    textVariant: 'headline',
  },
};

export const Button: React.FC<ButtonProps> = ({
  variant = 'primary',
  size = 'md',
  children,
  loading = false,
  disabled = false,
  fullWidth = false,
  leftIcon,
  rightIcon,
  style,
  onPressIn,
  onPressOut,
  ...props
}) => {
  const scale = useSharedValue(1);
  const opacity = useSharedValue(1);

  const config = sizeConfig[size];
  const isDisabled = disabled || loading;

  const handlePressIn = (e: any) => {
    scale.value = withSpring(0.97, { damping: 15, stiffness: 400 });
    opacity.value = withTiming(0.9, { duration: durations.fast });
    onPressIn?.(e);
  };

  const handlePressOut = (e: any) => {
    scale.value = withSpring(1, { damping: 15, stiffness: 400 });
    opacity.value = withTiming(1, { duration: durations.fast });
    onPressOut?.(e);
  };

  const animatedStyle = useAnimatedStyle(() => ({
    transform: [{ scale: scale.value }],
    opacity: opacity.value,
  }));

  const getContainerStyle = (): ViewStyle => {
    const base: ViewStyle = {
      height: config.height,
      paddingHorizontal: config.paddingHorizontal,
      borderRadius: radii.md,
      flexDirection: 'row',
      alignItems: 'center',
      justifyContent: 'center',
      gap: spacing.sm,
    };

    if (fullWidth) {
      base.width = '100%';
    }

    switch (variant) {
      case 'secondary':
        return {
          ...base,
          backgroundColor: 'transparent',
          borderWidth: 1.5,
          borderColor: colors.primary,
        };
      case 'ghost':
        return {
          ...base,
          backgroundColor: 'transparent',
        };
      case 'danger':
        return {
          ...base,
          backgroundColor: colors.danger,
        };
      default:
        return base;
    }
  };

  const getTextColor = (): string => {
    if (isDisabled) return colors.text.disabled;
    
    switch (variant) {
      case 'secondary':
        return colors.primary;
      case 'ghost':
        return colors.text.primary;
      case 'danger':
        return colors.white;
      default:
        return colors.white;
    }
  };

  const renderContent = () => (
    <>
      {loading ? (
        <ActivityIndicator color={getTextColor()} size="small" />
      ) : (
        <>
          {leftIcon}
          <Text
            variant={config.textVariant}
            color={getTextColor()}
            bold
          >
            {children}
          </Text>
          {rightIcon}
        </>
      )}
    </>
  );

  const containerStyle = getContainerStyle();

  // Primary variant uses gradient
  if (variant === 'primary') {
    return (
      <AnimatedPressable
        onPressIn={handlePressIn}
        onPressOut={handlePressOut}
        disabled={isDisabled}
        style={[
          animatedStyle,
          isDisabled && styles.disabled,
          style,
        ]}
        {...props}
      >
        <LinearGradient
          colors={isDisabled ? [colors.surface.tertiary, colors.surface.tertiary] : colors.gradients.primary as unknown as string[]}
          start={{ x: 0, y: 0 }}
          end={{ x: 1, y: 1 }}
          style={[containerStyle, styles.gradient]}
        >
          {renderContent()}
        </LinearGradient>
      </AnimatedPressable>
    );
  }

  return (
    <AnimatedPressable
      onPressIn={handlePressIn}
      onPressOut={handlePressOut}
      disabled={isDisabled}
      style={[
        animatedStyle,
        containerStyle,
        isDisabled && styles.disabled,
        variant === 'secondary' && isDisabled && styles.disabledOutline,
        style,
      ]}
      {...props}
    >
      {renderContent()}
    </AnimatedPressable>
  );
};

const styles = StyleSheet.create({
  gradient: {
    overflow: 'hidden',
  },
  disabled: {
    opacity: 0.5,
  },
  disabledOutline: {
    borderColor: colors.text.disabled,
  },
});

export default Button;
