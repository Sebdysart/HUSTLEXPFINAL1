/**
 * EntryScreen - Chosen-State Design
 * 
 * NORTH STAR:
 * "HustleXP should feel like a beautiful, trustworthy system that has 
 *  already decided you'll succeed — and is calmly guiding you to your first result."
 * 
 * 3 FEELINGS IN FIRST 5 SECONDS:
 * 1. Chosen - "I'm not starting from zero"
 * 2. Guaranteed Outcome - "This works. You're next."
 * 3. Effortless Entry - "I'm already inside"
 * 
 * CTA = Confirmation, not action
 * Background = Availability (soft signals resolving)
 * Hero = Selection (confident, understated, factual)
 */

import React, { useEffect } from 'react';
import { View, StyleSheet, Dimensions, Pressable } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import Animated, {
  useSharedValue,
  useAnimatedStyle,
  withRepeat,
  withSequence,
  withTiming,
  withSpring,
  withDelay,
  Easing,
  FadeIn,
  FadeInUp,
  interpolate,
} from 'react-native-reanimated';
import LinearGradient from 'react-native-linear-gradient';
import { Text } from '../components/Text';
import { hustleColors, hustleGradients, hustleShadows, hustleRadii, hustleSpacing } from '../theme/hustle-tokens';

const { width, height } = Dimensions.get('window');

const AnimatedPressable = Animated.createAnimatedComponent(Pressable);

export function EntryScreen({ navigation }: any) {
  const insets = useSafeAreaInsets();
  
  // Ambient animations
  const orbScale = useSharedValue(1);
  const orbY = useSharedValue(0);
  
  // Activity signal animations
  const signal1Opacity = useSharedValue(0);
  const signal2Opacity = useSharedValue(0);
  const signal3Opacity = useSharedValue(0);
  
  // CTA
  const ctaScale = useSharedValue(1);

  useEffect(() => {
    // Gentle orb breathing
    orbScale.value = withRepeat(
      withSequence(
        withTiming(1.08, { duration: 4000, easing: Easing.inOut(Easing.ease) }),
        withTiming(1, { duration: 4000, easing: Easing.inOut(Easing.ease) })
      ),
      -1,
      false
    );
    
    // Subtle vertical drift
    orbY.value = withRepeat(
      withSequence(
        withTiming(15, { duration: 6000, easing: Easing.inOut(Easing.ease) }),
        withTiming(-15, { duration: 6000, easing: Easing.inOut(Easing.ease) })
      ),
      -1,
      true
    );
    
    // Staggered activity signals - implies system is alive
    const animateSignals = () => {
      signal1Opacity.value = withDelay(1000, 
        withSequence(
          withTiming(1, { duration: 800 }),
          withDelay(2000, withTiming(0, { duration: 600 }))
        )
      );
      signal2Opacity.value = withDelay(3500,
        withSequence(
          withTiming(1, { duration: 800 }),
          withDelay(2000, withTiming(0, { duration: 600 }))
        )
      );
      signal3Opacity.value = withDelay(6000,
        withSequence(
          withTiming(1, { duration: 800 }),
          withDelay(2000, withTiming(0, { duration: 600 }))
        )
      );
    };
    
    animateSignals();
    const interval = setInterval(animateSignals, 9000);
    return () => clearInterval(interval);
  }, [orbScale, orbY, signal1Opacity, signal2Opacity, signal3Opacity]);

  const orbAnimatedStyle = useAnimatedStyle(() => ({
    transform: [
      { scale: orbScale.value },
      { translateY: orbY.value },
    ],
  }));

  const signal1Style = useAnimatedStyle(() => ({
    opacity: signal1Opacity.value,
    transform: [{ translateY: interpolate(signal1Opacity.value, [0, 1], [10, 0]) }],
  }));
  
  const signal2Style = useAnimatedStyle(() => ({
    opacity: signal2Opacity.value,
    transform: [{ translateY: interpolate(signal2Opacity.value, [0, 1], [10, 0]) }],
  }));
  
  const signal3Style = useAnimatedStyle(() => ({
    opacity: signal3Opacity.value,
    transform: [{ translateY: interpolate(signal3Opacity.value, [0, 1], [10, 0]) }],
  }));

  const handleCtaPressIn = () => {
    ctaScale.value = withSpring(0.97, { damping: 20, stiffness: 300 });
  };

  const handleCtaPressOut = () => {
    ctaScale.value = withSpring(1, { damping: 15, stiffness: 400 });
  };

  const ctaAnimatedStyle = useAnimatedStyle(() => ({
    transform: [{ scale: ctaScale.value }],
  }));

  const handleContinue = () => {
    navigation.navigate('Signup');
  };

  const handleSignIn = () => {
    navigation.navigate('Login');
  };

  return (
    <View style={[styles.container, { paddingTop: insets.top, paddingBottom: insets.bottom }]}>
      {/* Background - implies availability */}
      <LinearGradient
        colors={[...hustleGradients.backgroundMesh]}
        style={StyleSheet.absoluteFill}
        start={{ x: 0.5, y: 0 }}
        end={{ x: 0.5, y: 1 }}
      />
      
      {/* Ambient orb - soft, alive */}
      <Animated.View style={[styles.ambientOrb, orbAnimatedStyle]}>
        <LinearGradient
          colors={['rgba(124, 106, 239, 0.25)', 'transparent']}
          style={styles.orb}
          start={{ x: 0.5, y: 0.3 }}
          end={{ x: 0.5, y: 1 }}
        />
      </Animated.View>
      
      {/* Activity signals - "requests resolving themselves" */}
      <View style={styles.signalsContainer}>
        <Animated.View style={[styles.signal, styles.signal1, signal1Style]}>
          <Text style={styles.signalText}>✓ Task completed nearby</Text>
        </Animated.View>
        <Animated.View style={[styles.signal, styles.signal2, signal2Style]}>
          <Text style={styles.signalText}>↑ Someone just earned $45</Text>
        </Animated.View>
        <Animated.View style={[styles.signal, styles.signal3, signal3Style]}>
          <Text style={styles.signalText}>● 3 tasks available now</Text>
        </Animated.View>
      </View>
      
      {/* Content */}
      <View style={styles.content}>
        {/* Logo */}
        <Animated.View 
          entering={FadeIn.delay(200).duration(800)}
          style={styles.logoArea}
        >
          <View style={styles.logoMark}>
            <Text style={styles.logoText}>H</Text>
          </View>
        </Animated.View>
        
        {/* Hero - confident, understated, factual (not persuasive) */}
        <Animated.View 
          entering={FadeInUp.delay(400).duration(600).springify()}
          style={styles.messaging}
        >
          {/* Implies selection, not sales pitch */}
          <Text style={styles.headline}>
            Things are happening.
          </Text>
          <Text style={styles.subheadline}>
            You're next.
          </Text>
        </Animated.View>
        
        {/* Understated value - factual, not hype */}
        <Animated.View 
          entering={FadeInUp.delay(600).duration(600).springify()}
          style={styles.valueProp}
        >
          <Text style={styles.valueText}>
            Tasks getting done. People getting paid.{'\n'}
            The system is ready for you.
          </Text>
        </Animated.View>
      </View>
      
      {/* CTA - feels like confirmation, not action */}
      <Animated.View 
        entering={FadeInUp.delay(800).duration(600).springify()}
        style={styles.ctaContainer}
      >
        {/* Primary: Confirmation language */}
        <AnimatedPressable
          onPress={handleContinue}
          onPressIn={handleCtaPressIn}
          onPressOut={handleCtaPressOut}
          style={[styles.primaryCta, ctaAnimatedStyle, hustleShadows.purpleGlow]}
        >
          <LinearGradient
            colors={[...hustleGradients.action]}
            style={styles.ctaGradient}
            start={{ x: 0, y: 0 }}
            end={{ x: 1, y: 1 }}
          >
            <Text style={styles.ctaText}>Let's go</Text>
          </LinearGradient>
        </AnimatedPressable>
        
        {/* Secondary */}
        <Pressable onPress={handleSignIn} style={styles.secondaryCta}>
          <Text style={styles.secondaryCtaText}>
            I already have an account
          </Text>
        </Pressable>
      </Animated.View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: hustleColors.dark.void,
  },
  ambientOrb: {
    position: 'absolute',
    top: height * 0.12,
    left: width * 0.5 - 175,
    width: 350,
    height: 350,
  },
  orb: {
    width: '100%',
    height: '100%',
    borderRadius: 999,
  },
  
  // Activity signals - subtle proof of life
  signalsContainer: {
    position: 'absolute',
    top: height * 0.15,
    left: 0,
    right: 0,
    alignItems: 'center',
  },
  signal: {
    position: 'absolute',
    backgroundColor: hustleColors.glass.medium,
    paddingHorizontal: 16,
    paddingVertical: 10,
    borderRadius: hustleRadii.full,
    borderWidth: 1,
    borderColor: hustleColors.glass.border,
  },
  signal1: {
    top: 0,
    right: 20,
  },
  signal2: {
    top: 50,
    left: 30,
  },
  signal3: {
    top: 100,
    right: 40,
  },
  signalText: {
    fontSize: 13,
    color: hustleColors.text.secondary,
    fontWeight: '500',
  },
  
  content: {
    flex: 1,
    justifyContent: 'center',
    paddingHorizontal: hustleSpacing['2xl'],
  },
  logoArea: {
    alignItems: 'center',
    marginBottom: hustleSpacing['4xl'],
  },
  logoMark: {
    width: 72,
    height: 72,
    borderRadius: hustleRadii.xl,
    backgroundColor: hustleColors.purple.core,
    alignItems: 'center',
    justifyContent: 'center',
    ...hustleShadows.purpleGlow,
  },
  logoText: {
    fontSize: 36,
    fontWeight: '700',
    color: hustleColors.white,
  },
  messaging: {
    alignItems: 'center',
    marginBottom: hustleSpacing.xl,
  },
  headline: {
    fontSize: 34,
    fontWeight: '700',
    color: hustleColors.text.primary,
    textAlign: 'center',
    letterSpacing: -0.5,
    marginBottom: hustleSpacing.xs,
  },
  subheadline: {
    fontSize: 34,
    fontWeight: '700',
    color: hustleColors.purple.soft,
    textAlign: 'center',
    letterSpacing: -0.5,
  },
  valueProp: {
    alignItems: 'center',
  },
  valueText: {
    fontSize: 16,
    color: hustleColors.text.tertiary,
    textAlign: 'center',
    lineHeight: 24,
  },
  ctaContainer: {
    paddingHorizontal: hustleSpacing['2xl'],
    paddingBottom: hustleSpacing['2xl'],
  },
  primaryCta: {
    borderRadius: hustleRadii.full,
    overflow: 'hidden',
    marginBottom: hustleSpacing.lg,
  },
  ctaGradient: {
    paddingVertical: 18,
    paddingHorizontal: 32,
    alignItems: 'center',
    justifyContent: 'center',
    borderRadius: hustleRadii.full,
  },
  ctaText: {
    fontSize: 17,
    fontWeight: '600',
    color: hustleColors.white,
    letterSpacing: -0.2,
  },
  secondaryCta: {
    alignItems: 'center',
    paddingVertical: hustleSpacing.md,
  },
  secondaryCtaText: {
    fontSize: 15,
    color: hustleColors.purple.soft,
    fontWeight: '500',
  },
});
