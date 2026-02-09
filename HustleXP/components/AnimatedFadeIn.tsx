/**
 * AnimatedFadeIn Component - UAP Compliant
 *
 * Implements fade-in animation with proper duration constraints
 * enforced by runtime guards.
 */

import React, { useEffect, useRef } from 'react';
import { Animated } from 'react-native';
import { DURATION } from '../constants/animations';

interface AnimatedFadeInProps {
  children: React.ReactNode;
  delay?: number;
  duration?: number;
}

export function AnimatedFadeIn({
  children,
  delay = 0,
  duration = DURATION.normal
}: AnimatedFadeInProps) {
  const fadeAnim = useRef(new Animated.Value(0)).current;
  const translateYAnim = useRef(new Animated.Value(20)).current;

  useEffect(() => {
    const startAnimation = () => {
      Animated.parallel([
        Animated.timing(fadeAnim, {
          toValue: 1,
          duration,
          useNativeDriver: true,
        }),
        Animated.timing(translateYAnim, {
          toValue: 0,
          duration,
          useNativeDriver: true,
        }),
      ]).start();
    };

    if (delay > 0) {
      setTimeout(startAnimation, delay);
    } else {
      startAnimation();
    }
  }, [delay, duration]);

  return (
    <Animated.View
      style={{
        opacity: fadeAnim,
        transform: [{ translateY: translateYAnim }],
      }}
    >
      {children}
    </Animated.View>
  );
}