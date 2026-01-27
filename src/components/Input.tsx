/**
 * Input Component
 * Styled text input with label, error, and helper text
 */

import React, { useState, forwardRef } from 'react';
import {
  View,
  TextInput,
  TextInputProps,
  StyleSheet,
  ViewStyle,
  Pressable,
} from 'react-native';
import Animated, {
  useSharedValue,
  useAnimatedStyle,
  withTiming,
  interpolateColor,
} from 'react-native-reanimated';
import { colors, radii, spacing, typography, durations, touchTargets } from '../theme';
import { Text } from './Text';

const AnimatedView = Animated.View;

export interface InputProps extends Omit<TextInputProps, 'style'> {
  /** Input label */
  label?: string;
  /** Helper text (shown below input) */
  helperText?: string;
  /** Error message (replaces helper text when present) */
  error?: string;
  /** Disabled state */
  disabled?: boolean;
  /** Left icon/element */
  leftElement?: React.ReactNode;
  /** Right icon/element */
  rightElement?: React.ReactNode;
  /** Container style */
  containerStyle?: ViewStyle;
  /** Full width */
  fullWidth?: boolean;
}

export const Input = forwardRef<TextInput, InputProps>(({
  label,
  helperText,
  error,
  disabled = false,
  leftElement,
  rightElement,
  containerStyle,
  fullWidth = true,
  onFocus,
  onBlur,
  ...props
}, ref) => {
  const [_isFocused, setIsFocused] = useState(false);
  const focusAnimation = useSharedValue(0);

  const handleFocus = (e: any) => {
    setIsFocused(true);
    focusAnimation.value = withTiming(1, { duration: durations.normal });
    onFocus?.(e);
  };

  const handleBlur = (e: any) => {
    setIsFocused(false);
    focusAnimation.value = withTiming(0, { duration: durations.normal });
    onBlur?.(e);
  };

  const animatedBorderStyle = useAnimatedStyle(() => {
    const borderColor = error
      ? colors.danger
      : interpolateColor(
          focusAnimation.value,
          [0, 1],
          [colors.surface.tertiary, colors.primary]
        );

    return {
      borderColor,
      borderWidth: focusAnimation.value > 0.5 || error ? 1.5 : 1,
    };
  });

  const hasError = !!error;

  return (
    <View style={[fullWidth && styles.fullWidth, containerStyle]}>
      {label && (
        <Text
          variant="subhead"
          color={hasError ? 'danger' : 'secondary'}
          style={styles.label}
        >
          {label}
        </Text>
      )}

      <AnimatedView style={[styles.inputContainer, animatedBorderStyle]}>
        {leftElement && (
          <View style={styles.leftElement}>
            {leftElement}
          </View>
        )}

        <TextInput
          ref={ref}
          style={[
            styles.input,
            leftElement ? styles.inputWithLeft : undefined,
            rightElement ? styles.inputWithRight : undefined,
            disabled ? styles.inputDisabled : undefined,
          ]}
          placeholderTextColor={colors.text.disabled}
          editable={!disabled}
          onFocus={handleFocus}
          onBlur={handleBlur}
          selectionColor={colors.primary}
          {...props}
        />

        {rightElement && (
          <View style={styles.rightElement}>
            {rightElement}
          </View>
        )}
      </AnimatedView>

      {(helperText || error) && (
        <Text
          variant="caption"
          color={hasError ? 'danger' : 'secondary'}
          style={styles.helperText}
        >
          {error || helperText}
        </Text>
      )}
    </View>
  );
});

Input.displayName = 'Input';

// Password input with toggle visibility
export interface PasswordInputProps extends Omit<InputProps, 'secureTextEntry' | 'rightElement'> {
  showPasswordIcon?: React.ReactNode;
  hidePasswordIcon?: React.ReactNode;
}

export const PasswordInput = forwardRef<TextInput, PasswordInputProps>(({
  showPasswordIcon: _showPasswordIcon,
  hidePasswordIcon: _hidePasswordIcon,
  ...props
}, ref) => {
  const [visible, setVisible] = useState(false);

  return (
    <Input
      ref={ref}
      secureTextEntry={!visible}
      rightElement={
        <Pressable
          onPress={() => setVisible(!visible)}
          hitSlop={8}
          style={styles.passwordToggle}
        >
          <Text variant="caption" color="secondary">
            {visible ? 'Hide' : 'Show'}
          </Text>
        </Pressable>
      }
      {...props}
    />
  );
});

PasswordInput.displayName = 'PasswordInput';

const styles = StyleSheet.create({
  fullWidth: {
    width: '100%',
  },
  label: {
    marginBottom: spacing.xs,
    marginLeft: spacing.xs,
  },
  inputContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: colors.surface.secondary,
    borderRadius: radii.md,
    minHeight: touchTargets.comfortable,
    borderWidth: 1,
    borderColor: colors.surface.tertiary,
  },
  input: {
    flex: 1,
    paddingHorizontal: spacing.lg,
    paddingVertical: spacing.md,
    color: colors.text.primary,
    ...typography.body,
  },
  inputWithLeft: {
    paddingLeft: spacing.xs,
  },
  inputWithRight: {
    paddingRight: spacing.xs,
  },
  inputDisabled: {
    color: colors.text.disabled,
  },
  leftElement: {
    paddingLeft: spacing.md,
  },
  rightElement: {
    paddingRight: spacing.md,
  },
  helperText: {
    marginTop: spacing.xs,
    marginLeft: spacing.xs,
  },
  passwordToggle: {
    padding: spacing.sm,
  },
});

export default Input;
