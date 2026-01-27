/**
 * HButton - Button atom
 * 
 * CHOSEN-STATE CONTRACT:
 * - CTA feels like confirmation, not action
 * - Tap feedback is light, obvious, safe
 * - Primary uses purple gradient (action happens here)
 * - Never aggressive or demanding
 */

import React from 'react';
import {
  Pressable,
  PressableProps,
  StyleSheet,
  ActivityIndicator,
  View,
  ViewStyle,
} from 'react-native';
import Animated, {
  useSharedValue,
  useAnimatedStyle,
  withSpring,
} from 'react-native-reanimated';
import LinearGradient from 'react-native-linear-gradient';
import { HText } from './HText';
import { hustleColors, hustleRadii, hustleShadows, hustleGradients } from '../../theme/hustle-tokens';

const AnimatedPressable = Animated.createAnimatedComponent(Pressable);

type ButtonVariant = 'primary' | 'secondary' | 'ghost' | 'success';
type ButtonSize = 'sm' | 'md' | 'lg';

interface HButtonProps extends Omit<PressableProps, 'style'> {
  children: string;
  variant?: ButtonVariant;
  size?: ButtonSize;
  loading?: boolean;
  disabled?: boolean;
  fullWidth?: boolean;
  leftIcon?: React.ReactNode;
  rightIcon?: React.ReactNode;
  style?: ViewStyle;
}

const sizeConfig = {
  sm: { height: 40, paddingHorizontal: 16, fontSize: 14 },
  md: { height: 48, paddingHorizontal: 24, fontSize: 16 },
  lg: { height: 56, paddingHorizontal: 32, fontSize: 17 },
};

export const HButton: React.FC<HButtonProps> = ({
  children,
  variant = 'primary',
  size = 'md',
  loading = false,
  disabled = false,
  fullWidth = false,
  leftIcon,
  rightIcon,
  style,
  onPress,
  ...props
}) => {
  const scale = useSharedValue(1);
  const isDisabled = disabled || loading;
  const config = sizeConfig[size];

  const handlePressIn = () => {
    if (!isDisabled) {
      scale.value = withSpring(0.97, { damping: 20, stiffness: 400 });
    }
  };

  const handlePressOut = () => {
    scale.value = withSpring(1, { damping: 15, stiffness: 400 });
  };

  const animatedStyle = useAnimatedStyle(() => ({
    transform: [{ scale: scale.value }],
  }));

  const renderContent = () => (
    <View style={styles.content}>
      {loading ? (
        <ActivityIndicator
          color={variant === 'primary' ? hustleColors.white : hustleColors.purple.soft}
          size="small"
        />
      ) : (
        <>
          {leftIcon && <View style={styles.iconLeft}>{leftIcon}</View>}
          <HText
            variant="headline"
            color={variant === 'primary' || variant === 'success' 
              ? hustleColors.white 
              : hustleColors.purple.soft}
            style={{ fontSize: config.fontSize }}
          >
            {children}
          </HText>
          {rightIcon && <View style={styles.iconRight}>{rightIcon}</View>}
        </>
      )}
    </View>
  );

  const buttonStyle: ViewStyle = {
    height: config.height,
    paddingHorizontal: config.paddingHorizontal,
    borderRadius: hustleRadii.full,
    opacity: isDisabled ? 0.5 : 1,
  };

  // Primary: Gradient with glow
  if (variant === 'primary') {
    return (
      <AnimatedPressable
        onPress={onPress}
        onPressIn={handlePressIn}
        onPressOut={handlePressOut}
        disabled={isDisabled}
        style={[
          animatedStyle,
          hustleShadows.purpleGlow,
          fullWidth && styles.fullWidth,
          style,
        ]}
        {...props}
      >
        <LinearGradient
          colors={hustleGradients.action}
          style={[styles.button, buttonStyle]}
          start={{ x: 0, y: 0 }}
          end={{ x: 1, y: 1 }}
        >
          {renderContent()}
        </LinearGradient>
      </AnimatedPressable>
    );
  }

  // Success: Green gradient
  if (variant === 'success') {
    return (
      <AnimatedPressable
        onPress={onPress}
        onPressIn={handlePressIn}
        onPressOut={handlePressOut}
        disabled={isDisabled}
        style={[
          animatedStyle,
          hustleShadows.moneyGlow,
          fullWidth && styles.fullWidth,
          style,
        ]}
        {...props}
      >
        <LinearGradient
          colors={hustleGradients.earnings}
          style={[styles.button, buttonStyle]}
          start={{ x: 0, y: 0 }}
          end={{ x: 1, y: 1 }}
        >
          {renderContent()}
        </LinearGradient>
      </AnimatedPressable>
    );
  }

  // Secondary: Glass with border
  if (variant === 'secondary') {
    return (
      <AnimatedPressable
        onPress={onPress}
        onPressIn={handlePressIn}
        onPressOut={handlePressOut}
        disabled={isDisabled}
        style={[
          styles.button,
          buttonStyle,
          styles.secondary,
          animatedStyle,
          fullWidth && styles.fullWidth,
          style,
        ]}
        {...props}
      >
        {renderContent()}
      </AnimatedPressable>
    );
  }

  // Ghost: Transparent
  return (
    <AnimatedPressable
      onPress={onPress}
      onPressIn={handlePressIn}
      onPressOut={handlePressOut}
      disabled={isDisabled}
      style={[
        styles.button,
        buttonStyle,
        styles.ghost,
        animatedStyle,
        fullWidth && styles.fullWidth,
        style,
      ]}
      {...props}
    >
      {renderContent()}
    </AnimatedPressable>
  );
};

/**
 * HTextButton - Simple text button
 * For "I already have an account" style actions
 */
interface HTextButtonProps extends Omit<PressableProps, 'style'> {
  children: string;
  color?: string;
  style?: ViewStyle;
}

export const HTextButton: React.FC<HTextButtonProps> = ({
  children,
  color = hustleColors.purple.soft,
  style,
  onPress,
  ...props
}) => (
  <Pressable onPress={onPress} style={[styles.textButton, style]} {...props}>
    <HText variant="callout" color={color} medium>
      {children}
    </HText>
  </Pressable>
);

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
  secondary: {
    backgroundColor: hustleColors.glass.medium,
    borderWidth: 1,
    borderColor: hustleColors.purple.soft,
  },
  ghost: {
    backgroundColor: 'transparent',
  },
  fullWidth: {
    width: '100%',
  },
  textButton: {
    padding: 12,
    alignItems: 'center',
  },
});
