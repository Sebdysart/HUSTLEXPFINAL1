/**
 * PrimaryActionButton Component - UAP Compliant
 *
 * Implements the primary action button with proper glassmorphic styling,
 * animations, and accessibility features.
 */

import React, { useRef } from 'react';
import { TouchableOpacity, Text, ActivityIndicator, Animated, ViewStyle, TextStyle } from 'react-native';
import { StyleSheet } from 'react-native';
import { BRAND, DARK, TYPOGRAPHY, SPACING, RADIUS, TOUCH } from '../constants';

interface PrimaryActionButtonProps {
  title: string;
  onPress: () => void;
  loading?: boolean;
  disabled?: boolean;
  style?: ViewStyle;
  textStyle?: TextStyle;
}

export function PrimaryActionButton({
  title,
  onPress,
  loading = false,
  disabled = false,
  style,
  textStyle,
}: PrimaryActionButtonProps) {
  const scaleAnim = useRef(new Animated.Value(1)).current;

  const handlePressIn = () => {
    Animated.timing(scaleAnim, {
      toValue: 0.95,
      duration: 100,
      useNativeDriver: true,
    }).start();
  };

  const handlePressOut = () => {
    Animated.timing(scaleAnim, {
      toValue: 1,
      duration: 100,
      useNativeDriver: true,
    }).start();
  };

  const isDisabled = disabled || loading;

  return (
    <Animated.View style={[{ transform: [{ scale: scaleAnim }] }, style]}>
      <TouchableOpacity
        style={[
          styles.button,
          isDisabled && styles.disabled,
        ]}
        onPress={onPress}
        onPressIn={handlePressIn}
        onPressOut={handlePressOut}
        disabled={isDisabled}
        activeOpacity={0.8}
        accessibilityRole="button"
        accessibilityLabel={title}
        accessibilityState={{ disabled: isDisabled }}
      >
        {loading ? (
          <ActivityIndicator
            size="small"
            color={DARK.TEXT}
          />
        ) : (
          <Text style={[styles.text, textStyle]}>
            {title}
          </Text>
        )}
      </TouchableOpacity>
    </Animated.View>
  );
}

const styles = StyleSheet.create({
  button: {
    backgroundColor: BRAND.PRIMARY,
    borderRadius: RADIUS.xl,
    minHeight: TOUCH.comfortable,
    minWidth: 200,
    paddingHorizontal: SPACING[6],
    paddingVertical: SPACING[4],
    alignItems: 'center',
    justifyContent: 'center',
    shadowColor: BRAND.PRIMARY,
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.3,
    shadowRadius: 8,
    elevation: 4,
  },
  text: {
    ...TYPOGRAPHY.label,
    color: DARK.TEXT,
    fontWeight: '600',
    fontSize: 16,
  },
  disabled: {
    opacity: 0.6,
    shadowOpacity: 0.1,
  },
});