/**
 * NeonButton - Premium glowing button with animations
 * Top 1% fintech aesthetic
 */

import React from 'react';
import {
  Pressable,
  PressableProps,
  StyleSheet,
  ActivityIndicator,
  ViewStyle,
  View,
} from 'react-native';
import Animated, {
  useSharedValue,
  useAnimatedStyle,
  withSpring,
  withSequence,
  withTiming,
  Easing,
} from 'react-native-reanimated';
import LinearGradient from 'react-native-linear-gradient';
import { neonColors, neonShadows, neonRadii } from '../theme/neon-tokens';
import { Text } from './Text';

const AnimatedPressable = Animated.createAnimatedComponent(Pressable);
const AnimatedLinearGradient = Animated.createAnimatedComponent(LinearGradient);

export type NeonButtonVariant = 'primary' | 'secondary' | 'ghost' | 'danger';
export type NeonButtonSize = 'sm' | 'md' | 'lg';

export interface NeonButtonProps extends Omit<PressableProps, 'style'> {
  children: string;
  variant?: NeonButtonVariant;
  size?: NeonButtonSize;
  loading?: boolean;
  disabled?: boolean;
  fullWidth?: boolean;
  glowColor?: string;
  leftIcon?: React.ReactNode;
  rightIcon?: React.ReactNode;
  style?: ViewStyle;
}

const sizeConfig = {
  sm: { height: 40, paddingHorizontal: 16, fontSize: 14 },
  md: { height: 48, paddingHorizontal: 24, fontSize: 16 },
  lg: { height: 56, paddingHorizontal: 32, fontSize: 18 },
};

const variantConfig = {
  primary: {
    gradient: neonColors.gradients.neonPrimary,
    textColor: neonColors.surface.void,
    glowColor: neonColors.cyan,
  },
  secondary: {
    gradient: [neonColors.glass.heavy, neonColors.glass.medium],
    textColor: neonColors.cyan,
    glowColor: neonColors.cyan,
    borderColor: neonColors.cyan,
  },
  ghost: {
    gradient: ['transparent', 'transparent'],
    textColor: neonColors.cyan,
    glowColor: 'transparent',
  },
  danger: {
    gradient: neonColors.gradients.neonHot,
    textColor: neonColors.white,
    glowColor: neonColors.error,
  },
};

export const NeonButton: React.FC<NeonButtonProps> = ({
  children,
  variant = 'primary',
  size = 'md',
  loading = false,
  disabled = false,
  fullWidth = false,
  glowColor: customGlow,
  leftIcon,
  rightIcon,
  style,
  onPress,
  ...props
}) => {
  const scale = useSharedValue(1);
  const glowOpacity = useSharedValue(0.4);
  
  const config = variantConfig[variant];
  const sizeConf = sizeConfig[size];
  const isDisabled = disabled || loading;
  const glowColor = customGlow || config.glowColor;

  const handlePressIn = () => {
    if (!isDisabled) {
      scale.value = withSpring(0.96, { damping: 15, stiffness: 500 });
      glowOpacity.value = withTiming(0.8, { duration: 100 });
    }
  };

  const handlePressOut = () => {
    scale.value = withSpring(1, { damping: 15, stiffness: 500 });
    glowOpacity.value = withTiming(0.4, { duration: 200 });
  };

  const animatedContainerStyle = useAnimatedStyle(() => ({
    transform: [{ scale: scale.value }],
  }));

  const animatedGlowStyle = useAnimatedStyle(() => ({
    shadowOpacity: glowOpacity.value,
  }));

  return (
    <AnimatedPressable
      onPress={onPress}
      onPressIn={handlePressIn}
      onPressOut={handlePressOut}
      disabled={isDisabled}
      style={[
        animatedContainerStyle,
        animatedGlowStyle,
        {
          ...neonShadows.glow(glowColor, 0.4),
          opacity: isDisabled ? 0.5 : 1,
        },
        fullWidth && { width: '100%' },
        style,
      ]}
      {...props}
    >
      <LinearGradient
        colors={config.gradient as [string, string]}
        start={{ x: 0, y: 0 }}
        end={{ x: 1, y: 1 }}
        style={[
          styles.button,
          {
            height: sizeConf.height,
            paddingHorizontal: sizeConf.paddingHorizontal,
            borderRadius: neonRadii.full,
          },
          variant === 'secondary' && {
            borderWidth: 1,
            borderColor: config.borderColor,
          },
        ]}
      >
        {loading ? (
          <ActivityIndicator color={config.textColor} size="small" />
        ) : (
          <View style={styles.content}>
            {leftIcon && <View style={styles.iconLeft}>{leftIcon}</View>}
            <Text
              variant="headline"
              color={config.textColor}
              style={{ fontSize: sizeConf.fontSize }}
            >
              {children}
            </Text>
            {rightIcon && <View style={styles.iconRight}>{rightIcon}</View>}
          </View>
        )}
      </LinearGradient>
    </AnimatedPressable>
  );
};

/**
 * NeonIconButton - Circular icon button with glow
 */
export interface NeonIconButtonProps extends Omit<PressableProps, 'style'> {
  icon: React.ReactNode;
  size?: number;
  glowColor?: string;
  style?: ViewStyle;
}

export const NeonIconButton: React.FC<NeonIconButtonProps> = ({
  icon,
  size = 48,
  glowColor = neonColors.cyan,
  style,
  onPress,
  ...props
}) => {
  const scale = useSharedValue(1);

  const handlePressIn = () => {
    scale.value = withSequence(
      withTiming(0.9, { duration: 50 }),
      withSpring(1.05, { damping: 8, stiffness: 400 })
    );
  };

  const handlePressOut = () => {
    scale.value = withSpring(1, { damping: 15, stiffness: 400 });
  };

  const animatedStyle = useAnimatedStyle(() => ({
    transform: [{ scale: scale.value }],
  }));

  return (
    <AnimatedPressable
      onPress={onPress}
      onPressIn={handlePressIn}
      onPressOut={handlePressOut}
      style={[
        animatedStyle,
        styles.iconButton,
        {
          width: size,
          height: size,
          borderRadius: size / 2,
          borderColor: glowColor,
        },
        neonShadows.glow(glowColor, 0.4),
        style,
      ]}
      {...props}
    >
      {icon}
    </AnimatedPressable>
  );
};

const styles = StyleSheet.create({
  button: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
  },
  content: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  iconLeft: {
    marginRight: 8,
  },
  iconRight: {
    marginLeft: 8,
  },
  iconButton: {
    backgroundColor: neonColors.glass.medium,
    borderWidth: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
});
