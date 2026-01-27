/**
 * BootstrapScreen - The first breath
 * 
 * CHOSEN-STATE: Nothing to read, nothing to do.
 * Just logo + ambient. System is waking up.
 * 
 * Auto-navigates after stability check.
 */

import React, { useEffect } from 'react';
import { View, StyleSheet, Image } from 'react-native';
import Animated, {
  useSharedValue,
  useAnimatedStyle,
  withTiming,
  withDelay,
  Easing,
} from 'react-native-reanimated';
import { useNavigation } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import { HScreen, HText } from '../components/atoms';
import { hustleColors } from '../theme/hustle-tokens';
import type { RootStackParamList } from '../navigation/types';

type NavigationProp = NativeStackNavigationProp<RootStackParamList>;

export function BootstrapScreen() {
  const navigation = useNavigation<NavigationProp>();
  const logoOpacity = useSharedValue(0);
  const logoScale = useSharedValue(0.9);

  useEffect(() => {
    // Logo fade in
    logoOpacity.value = withDelay(
      300,
      withTiming(1, { duration: 800, easing: Easing.out(Easing.ease) })
    );
    logoScale.value = withDelay(
      300,
      withTiming(1, { duration: 800, easing: Easing.out(Easing.ease) })
    );

    // Auto-navigate after stability window
    const timer = setTimeout(() => {
      navigation.replace('Login');
    }, 2000);

    return () => clearTimeout(timer);
  }, [navigation]);

  const logoStyle = useAnimatedStyle(() => ({
    opacity: logoOpacity.value,
    transform: [{ scale: logoScale.value }],
  }));

  return (
    <HScreen ambient scroll={false} padding={0}>
      <View style={styles.container}>
        {/* Logo - center of gravity */}
        <Animated.View style={[styles.logoContainer, logoStyle]}>
          <HText variant="hero" color="primary" center>
            H
          </HText>
        </Animated.View>
      </View>
    </HScreen>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  logoContainer: {
    width: 80,
    height: 80,
    borderRadius: 20,
    backgroundColor: hustleColors.purple.core,
    justifyContent: 'center',
    alignItems: 'center',
  },
});

export default BootstrapScreen;
