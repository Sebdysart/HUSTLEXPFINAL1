/**
 * EntryScreen - The First Impression
 * 
 * EMOTIONAL CONTRACT:
 * - "Oh wow."
 * - "This makes sense instantly."
 * - "I want to keep going."
 * 
 * NOT: Intimidating, chaotic, instructional, pressure
 * YES: Welcoming, empowering, alive, addictive
 * 
 * The system is alive — but it's inviting you in, not shouting.
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

const AnimatedLinearGradient = Animated.createAnimatedComponent(LinearGradient);
const AnimatedPressable = Animated.createAnimatedComponent(Pressable);

export function EntryScreen({ navigation }: any) {
  const insets = useSafeAreaInsets();
  
  // Ambient gradient animation - slow, hypnotic
  const gradientPosition = useSharedValue(0);
  const orbScale = useSharedValue(1);
  const orbOpacity = useSharedValue(0.15);
  
  // CTA button animation
  const ctaScale = useSharedValue(1);

  useEffect(() => {
    // Slow drift animation (12 seconds, infinite)
    gradientPosition.value = withRepeat(
      withSequence(
        withTiming(1, { duration: 12000, easing: Easing.inOut(Easing.ease) }),
        withTiming(0, { duration: 12000, easing: Easing.inOut(Easing.ease) })
      ),
      -1,
      false
    );
    
    // Gentle pulse on orb (3 seconds)
    orbScale.value = withRepeat(
      withSequence(
        withTiming(1.1, { duration: 3000, easing: Easing.inOut(Easing.ease) }),
        withTiming(1, { duration: 3000, easing: Easing.inOut(Easing.ease) })
      ),
      -1,
      false
    );
    
    // Subtle opacity pulse
    orbOpacity.value = withRepeat(
      withSequence(
        withTiming(0.25, { duration: 4000, easing: Easing.inOut(Easing.ease) }),
        withTiming(0.15, { duration: 4000, easing: Easing.inOut(Easing.ease) })
      ),
      -1,
      false
    );
  }, []);

  const orbAnimatedStyle = useAnimatedStyle(() => ({
    transform: [
      { scale: orbScale.value },
      { translateY: interpolate(gradientPosition.value, [0, 1], [0, 30]) },
    ],
    opacity: orbOpacity.value,
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

  const handleGetStarted = () => {
    navigation.navigate('Signup');
  };

  const handleSignIn = () => {
    navigation.navigate('Login');
  };

  return (
    <View style={[styles.container, { paddingTop: insets.top, paddingBottom: insets.bottom }]}>
      {/* Background - dark base with soft gradient mesh */}
      <LinearGradient
        colors={hustleGradients.backgroundMesh}
        style={StyleSheet.absoluteFill}
        start={{ x: 0.5, y: 0 }}
        end={{ x: 0.5, y: 1 }}
      />
      
      {/* Ambient orb - soft purple glow, slow drift */}
      <Animated.View style={[styles.ambientOrb, orbAnimatedStyle]}>
        <LinearGradient
          colors={['rgba(124, 106, 239, 0.4)', 'transparent']}
          style={styles.orb}
          start={{ x: 0.5, y: 0.5 }}
          end={{ x: 0.5, y: 1 }}
        />
      </Animated.View>
      
      {/* Content */}
      <View style={styles.content}>
        {/* Logo / Brand mark area */}
        <Animated.View 
          entering={FadeIn.delay(200).duration(800)}
          style={styles.logoArea}
        >
          <View style={styles.logoMark}>
            <Text style={styles.logoText}>H</Text>
          </View>
        </Animated.View>
        
        {/* Main messaging - human, simple, outcome-oriented */}
        <Animated.View 
          entering={FadeInUp.delay(400).duration(600).springify()}
          style={styles.messaging}
        >
          <Text style={styles.headline}>
            Get things done.
          </Text>
          <Text style={styles.subheadline}>
            Or get paid doing them.
          </Text>
        </Animated.View>
        
        {/* Subtle value prop - no sides, no pressure */}
        <Animated.View 
          entering={FadeInUp.delay(600).duration(600).springify()}
          style={styles.valueProp}
        >
          <Text style={styles.valueText}>
            A marketplace that works for you —{'\n'}however you participate.
          </Text>
        </Animated.View>
      </View>
      
      {/* CTAs - light, obvious, safe, tempting */}
      <Animated.View 
        entering={FadeInUp.delay(800).duration(600).springify()}
        style={styles.ctaContainer}
      >
        {/* Primary CTA - inviting, not demanding */}
        <AnimatedPressable
          onPress={handleGetStarted}
          onPressIn={handleCtaPressIn}
          onPressOut={handleCtaPressOut}
          style={[styles.primaryCta, ctaAnimatedStyle, hustleShadows.purpleGlow]}
        >
          <LinearGradient
            colors={hustleGradients.action}
            style={styles.ctaGradient}
            start={{ x: 0, y: 0 }}
            end={{ x: 1, y: 1 }}
          >
            <Text style={styles.ctaText}>Get Started</Text>
          </LinearGradient>
        </AnimatedPressable>
        
        {/* Secondary - existing users */}
        <Pressable onPress={handleSignIn} style={styles.secondaryCta}>
          <Text style={styles.secondaryCtaText}>
            Already have an account? <Text style={styles.signInLink}>Sign in</Text>
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
    top: height * 0.15,
    left: width * 0.5 - 150,
    width: 300,
    height: 300,
  },
  orb: {
    width: '100%',
    height: '100%',
    borderRadius: 999,
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
    fontSize: 36,
    fontWeight: '700',
    color: hustleColors.text.primary,
    textAlign: 'center',
    letterSpacing: -0.5,
    marginBottom: hustleSpacing.xs,
  },
  subheadline: {
    fontSize: 36,
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
    color: hustleColors.text.tertiary,
  },
  signInLink: {
    color: hustleColors.purple.soft,
    fontWeight: '500',
  },
});
