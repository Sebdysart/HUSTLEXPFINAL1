/**
 * HSignal - Activity signal atom
 * 
 * CHOSEN-STATE CONTRACT:
 * - Implies "requests resolving themselves"
 * - System is alive without being loud
 * - Soft fade in/out, never jarring
 */

import React, { useEffect } from 'react';
import { View, StyleSheet, ViewStyle } from 'react-native';
import Animated, {
  useSharedValue,
  useAnimatedStyle,
  withSequence,
  withTiming,
  withDelay,
  Easing,
  interpolate,
} from 'react-native-reanimated';
import { HText } from './HText';
import { hustleColors, hustleRadii, hustleSpacing } from '../../theme/hustle-tokens';

interface HSignalProps {
  /** Signal text */
  text: string;
  /** Icon/emoji */
  icon?: string;
  /** Delay before showing (ms) */
  delay?: number;
  /** Duration visible (ms) */
  duration?: number;
  /** Position style */
  style?: ViewStyle;
}

export const HSignal: React.FC<HSignalProps> = ({
  text,
  icon = '●',
  delay = 0,
  duration = 3000,
  style,
}) => {
  const opacity = useSharedValue(0);
  const translateY = useSharedValue(10);

  useEffect(() => {
    opacity.value = withDelay(
      delay,
      withSequence(
        withTiming(1, { duration: 600, easing: Easing.out(Easing.ease) }),
        withDelay(duration, withTiming(0, { duration: 500, easing: Easing.in(Easing.ease) }))
      )
    );
    translateY.value = withDelay(
      delay,
      withSequence(
        withTiming(0, { duration: 600, easing: Easing.out(Easing.ease) }),
        withDelay(duration, withTiming(-10, { duration: 500, easing: Easing.in(Easing.ease) }))
      )
    );
  }, [delay, duration]);

  const animatedStyle = useAnimatedStyle(() => ({
    opacity: opacity.value,
    transform: [{ translateY: translateY.value }],
  }));

  return (
    <Animated.View style={[styles.signal, animatedStyle, style]}>
      <HText variant="caption" color="secondary">
        {icon} {text}
      </HText>
    </Animated.View>
  );
};

/**
 * HSignalStream - Multiple signals appearing/disappearing
 * Creates "system is alive" feeling
 */
interface HSignalStreamProps {
  signals: Array<{ text: string; icon?: string }>;
  /** Interval between signals (ms) */
  interval?: number;
  /** How long each signal stays visible (ms) */
  duration?: number;
  style?: ViewStyle;
}

export const HSignalStream: React.FC<HSignalStreamProps> = ({
  signals,
  interval = 3000,
  duration = 2500,
  style,
}) => {
  const [currentIndex, setCurrentIndex] = React.useState(0);
  const [key, setKey] = React.useState(0);

  useEffect(() => {
    const timer = setInterval(() => {
      setCurrentIndex((prev) => (prev + 1) % signals.length);
      setKey((prev) => prev + 1);
    }, interval);

    return () => clearInterval(timer);
  }, [signals.length, interval]);

  const signal = signals[currentIndex];

  return (
    <View style={[styles.streamContainer, style]}>
      <HSignal
        key={key}
        text={signal.text}
        icon={signal.icon}
        duration={duration}
      />
    </View>
  );
};

/**
 * HActivityIndicator - Subtle "things happening" indicator
 */
interface HActivityIndicatorProps {
  /** Is activity happening */
  active?: boolean;
  /** Label */
  label?: string;
  style?: ViewStyle;
}

export const HActivityIndicator: React.FC<HActivityIndicatorProps> = ({
  active = true,
  label,
  style,
}) => {
  const dotOpacity = useSharedValue(0.3);

  useEffect(() => {
    if (active) {
      dotOpacity.value = withSequence(
        withTiming(1, { duration: 600 }),
        withTiming(0.3, { duration: 600 })
      );
      
      const interval = setInterval(() => {
        dotOpacity.value = withSequence(
          withTiming(1, { duration: 600 }),
          withTiming(0.3, { duration: 600 })
        );
      }, 1200);

      return () => clearInterval(interval);
    }
  }, [active]);

  const dotStyle = useAnimatedStyle(() => ({
    opacity: dotOpacity.value,
  }));

  if (!active) return null;

  return (
    <View style={[styles.activityContainer, style]}>
      <Animated.View style={[styles.activityDot, dotStyle]} />
      {label && (
        <HText variant="caption" color="tertiary" style={styles.activityLabel}>
          {label}
        </HText>
      )}
    </View>
  );
};

const styles = StyleSheet.create({
  signal: {
    backgroundColor: hustleColors.glass.medium,
    paddingHorizontal: hustleSpacing.md,
    paddingVertical: hustleSpacing.sm,
    borderRadius: hustleRadii.full,
    borderWidth: 1,
    borderColor: hustleColors.glass.border,
    alignSelf: 'flex-start',
  },
  streamContainer: {
    minHeight: 36,
    justifyContent: 'center',
  },
  activityContainer: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  activityDot: {
    width: 8,
    height: 8,
    borderRadius: 4,
    backgroundColor: hustleColors.semantic.success,
    marginRight: hustleSpacing.xs,
  },
  activityLabel: {
    marginLeft: 4,
  },
});
