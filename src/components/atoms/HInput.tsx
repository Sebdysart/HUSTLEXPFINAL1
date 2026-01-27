/**
 * HInput - Input atom
 * 
 * CHOSEN-STATE CONTRACT:
 * - Never feels like "filling out a form"
 * - Focus state implies system responding
 * - Minimal, clean, welcoming
 */

import React, { useState } from 'react';
import {
  TextInput,
  TextInputProps,
  View,
  StyleSheet,
  Pressable,
  ViewStyle,
} from 'react-native';
import Animated, {
  useSharedValue,
  useAnimatedStyle,
  withTiming,
} from 'react-native-reanimated';
import { HText } from './HText';
import { hustleColors, hustleRadii, hustleSpacing } from '../../theme/hustle-tokens';

interface HInputProps extends TextInputProps {
  /** Label above input */
  label?: string;
  /** Error message */
  error?: string;
  /** Left icon */
  leftIcon?: React.ReactNode;
  /** Right icon/action */
  rightIcon?: React.ReactNode;
  /** Container style */
  containerStyle?: ViewStyle;
}

const AnimatedView = Animated.createAnimatedComponent(View);

export const HInput: React.FC<HInputProps> = ({
  label,
  error,
  leftIcon,
  rightIcon,
  containerStyle,
  onFocus,
  onBlur,
  style,
  ...props
}) => {
  const [isFocused, setIsFocused] = useState(false);
  const borderColor = useSharedValue(hustleColors.glass.border);

  const handleFocus = (e: any) => {
    setIsFocused(true);
    borderColor.value = withTiming(hustleColors.purple.soft, { duration: 200 });
    onFocus?.(e);
  };

  const handleBlur = (e: any) => {
    setIsFocused(false);
    borderColor.value = withTiming(
      error ? hustleColors.semantic.error : hustleColors.glass.border,
      { duration: 200 }
    );
    onBlur?.(e);
  };

  const animatedBorderStyle = useAnimatedStyle(() => ({
    borderColor: borderColor.value,
  }));

  return (
    <View style={containerStyle}>
      {label && (
        <HText variant="subhead" color="secondary" style={styles.label}>
          {label}
        </HText>
      )}
      <AnimatedView style={[styles.inputContainer, animatedBorderStyle]}>
        {leftIcon && <View style={styles.leftIcon}>{leftIcon}</View>}
        <TextInput
          style={[styles.input, style]}
          placeholderTextColor={hustleColors.text.muted}
          selectionColor={hustleColors.purple.soft}
          {...props}
          onFocus={handleFocus}
          onBlur={handleBlur}
        />
        {rightIcon && <View style={styles.rightIcon}>{rightIcon}</View>}
      </AnimatedView>
      {error && (
        <HText variant="caption" color="error" style={styles.error}>
          {error}
        </HText>
      )}
    </View>
  );
};

/**
 * HPasswordInput - Password input with toggle
 */
interface HPasswordInputProps extends Omit<HInputProps, 'secureTextEntry' | 'rightIcon'> {}

export const HPasswordInput: React.FC<HPasswordInputProps> = (props) => {
  const [visible, setVisible] = useState(false);

  return (
    <HInput
      {...props}
      secureTextEntry={!visible}
      rightIcon={
        <Pressable onPress={() => setVisible(!visible)} style={styles.toggleButton}>
          <HText variant="caption" color="purple">
            {visible ? 'Hide' : 'Show'}
          </HText>
        </Pressable>
      }
    />
  );
};

/**
 * HSearchInput - Search input with icon
 */
interface HSearchInputProps extends Omit<HInputProps, 'leftIcon'> {
  onSearch?: (text: string) => void;
}

export const HSearchInput: React.FC<HSearchInputProps> = ({
  onSearch,
  onChangeText,
  ...props
}) => {
  const handleChange = (text: string) => {
    onChangeText?.(text);
    onSearch?.(text);
  };

  return (
    <HInput
      {...props}
      onChangeText={handleChange}
      leftIcon={<HText color="tertiary">🔍</HText>}
      placeholder={props.placeholder || 'Search...'}
    />
  );
};

const styles = StyleSheet.create({
  label: {
    marginBottom: hustleSpacing.xs,
    marginLeft: 4,
  },
  inputContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: hustleColors.dark.elevated,
    borderRadius: hustleRadii.lg,
    borderWidth: 1,
    paddingHorizontal: hustleSpacing.md,
  },
  input: {
    flex: 1,
    height: 48,
    fontSize: 16,
    color: hustleColors.text.primary,
  },
  leftIcon: {
    marginRight: hustleSpacing.sm,
  },
  rightIcon: {
    marginLeft: hustleSpacing.sm,
  },
  error: {
    marginTop: hustleSpacing.xs,
    marginLeft: 4,
  },
  toggleButton: {
    padding: 8,
  },
});
