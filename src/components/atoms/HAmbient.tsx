/**
 * HAmbient - Ambient motion elements
 * 
 * CHOSEN-STATE CONTRACT:
 * - System always feels alive
 * - Motion is slow, hypnotic, calming
 * - Never aggressive or distracting
 */

import React, { useEffect } from 'react';
import { View, StyleSheet, Dimensions } from 'react-native';
import Animated, {
  useSharedValue,
  useAnimatedStyle,
  withRepeat,
  withSequence,
  withTiming,
  Easing,
} from 'react-native-reanimated';
import LinearGradient from 'react-native-linear-gradient';
import { hustleColors } from '../../theme/hustle-tokens';

const { width, height } = Dimensions.get('window');

interface HAmbientOrbProps {
  /** Position from top (0-1) */
  top?: number;
  /** Size of orb */
  size?: number;
  /** Color of glow */
  color?: string;
  /** Opacity */
  opacity?: number;
}

export const HAmbientOrb: React.FC<HAmbientOrbProps> = ({
  top = 0.12,
  size = 350,
  color = hustleColors.purple.core,
  opacity = 0.2,
}) => {
  const scale = useSharedValue(1);
  const translateY = useSharedValue(0);

  useEffect(() => {
    // Gentle breathing (8 seconds)
    scale.value = withRepeat(
      withSequence(
        withTiming(1.08, { duration: 4000, easing: Easing.inOut(Easing.ease) }),
        withTiming(1, { duration: 4000, easing: Easing.inOut(Easing.ease) })
      ),
      -1,
      false
    );

    // Subtle drift (12 seconds)
    translateY.value = withRepeat(
      withSequence(
        withTiming(20, { duration: 6000, easing: Easing.inOut(Easing.ease) }),
        withTiming(-20, { duration: 6000, easing: Easing.inOut(Easing.ease) })
      ),
      -1,
      true
    );
  }, [scale, translateY]);

  const animatedStyle = useAnimatedStyle(() => ({
    transform: [
      { scale: scale.value },
      { translateY: translateY.value },
    ],
  }));

  return (
    <Animated.View
      style={[
        styles.orb,
        {
          top: height * top,
          left: width * 0.5 - size / 2,
          width: size,
          height: size,
        },
        animatedStyle,
      ]}
    >
      <LinearGradient
        colors={[`${color}${Math.round(opacity * 255).toString(16).padStart(2, '0')}`, 'transparent']}
        style={styles.gradient}
        start={{ x: 0.5, y: 0.3 }}
        end={{ x: 0.5, y: 1 }}
      />
    </Animated.View>
  );
};

/**
 * HAmbientDots - Floating particle effect
 * Implies: "Activity happening in the background"
 */
export const HAmbientDots: React.FC = () => {
  const dots = Array.from({ length: 5 }, (_, i) => ({
    id: i,
    delay: i * 2000,
    x: Math.random() * width,
    y: Math.random() * height * 0.5,
  }));

  return (
    <View style={StyleSheet.absoluteFill} pointerEvents="none">
      {dots.map((dot) => (
        <AmbientDot key={dot.id} x={dot.x} y={dot.y} delay={dot.delay} />
      ))}
    </View>
  );
};

const AmbientDot: React.FC<{ x: number; y: number; delay: number }> = ({ x, y, delay }) => {
  const opacity = useSharedValue(0);
  const translateY = useSharedValue(0);

  useEffect(() => {
    const animate = () => {
      opacity.value = withSequence(
        withTiming(0, { duration: 0 }),
        withTiming(0.6, { duration: 1500, easing: Easing.out(Easing.ease) }),
        withTiming(0, { duration: 1500, easing: Easing.in(Easing.ease) })
      );
      translateY.value = withSequence(
        withTiming(0, { duration: 0 }),
        withTiming(-30, { duration: 3000, easing: Easing.out(Easing.ease) })
      );
    };

    const timeout = setTimeout(() => {
      animate();
      const interval = setInterval(animate, 8000);
      return () => clearInterval(interval);
    }, delay);

    return () => clearTimeout(timeout);
  }, [delay, opacity, translateY]);

  const style = useAnimatedStyle(() => ({
    opacity: opacity.value,
    transform: [{ translateY: translateY.value }],
  }));

  return (
    <Animated.View
      style={[
        styles.dot,
        { left: x, top: y },
        style,
      ]}
    />
  );
};

const styles = StyleSheet.create({
  orb: {
    position: 'absolute',
  },
  gradient: {
    width: '100%',
    height: '100%',
    borderRadius: 999,
  },
  dot: {
    position: 'absolute',
    width: 4,
    height: 4,
    borderRadius: 2,
    backgroundColor: hustleColors.purple.soft,
  },
});
