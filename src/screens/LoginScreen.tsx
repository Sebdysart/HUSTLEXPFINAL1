/**
 * LoginScreen - Chosen-State Edition
 * 
 * "Welcome back" — not a gate, a homecoming.
 */

import React, { useState } from 'react';
import { View, StyleSheet, KeyboardAvoidingView, Platform } from 'react-native';
import { useNavigation } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import { HScreen, HText, HInput, HButton, HTextButton, HCard } from '../components/atoms';
import { hustleSpacing, hustleColors } from '../theme/hustle-tokens';
import { useAuthStore } from '../store';
import type { RootStackParamList } from '../navigation/types';

type NavigationProp = NativeStackNavigationProp<RootStackParamList>;

export function LoginScreen() {
  const navigation = useNavigation<NavigationProp>();
  const { login } = useAuthStore();
  
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  const handleLogin = async () => {
    setLoading(true);
    setError('');
    
    try {
      const success = await login(email, password);
      if (success) {
        const { user } = useAuthStore.getState();
        if (user?.onboardingComplete) {
          navigation.reset({
            index: 0,
            routes: [{ name: 'MainTabs' }],
          });
        } else {
          navigation.reset({
            index: 0,
            routes: [{ name: 'Framing' }],
          });
        }
      }
    } catch {
      setError("Hmm, that didn't work. Double-check your details?");
    } finally {
      setLoading(false);
    }
  };

  const handleForgotPassword = () => {
    navigation.navigate('ForgotPassword');
  };

  const handleSignUp = () => {
    navigation.navigate('Signup');
  };

  return (
    <HScreen ambient scroll={false}>
      <KeyboardAvoidingView 
        style={styles.container}
        behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
      >
        <View style={styles.content}>
          {/* Header - Welcoming, not demanding */}
          <View style={styles.header}>
            <HText variant="hero" color="primary" center>
              HustleXP
            </HText>
            <View style={styles.spacerSm} />
            <HText variant="body" color="secondary" center>
              Welcome back
            </HText>
          </View>

          <View style={styles.spacerXl} />

          {/* Login Form */}
          <HCard variant="default" padding="lg">
            <HInput
              label="Email"
              placeholder="you@example.com"
              value={email}
              onChangeText={(text) => {
                setEmail(text);
                setError('');
              }}
              keyboardType="email-address"
              autoCapitalize="none"
              autoCorrect={false}
            />
            
            <View style={styles.spacerMd} />
            
            <HInput
              label="Password"
              placeholder="Your password"
              value={password}
              onChangeText={(text) => {
                setPassword(text);
                setError('');
              }}
              secureTextEntry
              error={error}
            />

            <View style={styles.spacerSm} />

            <HTextButton onPress={handleForgotPassword}>
              Forgot password?
            </HTextButton>

            <View style={styles.spacerLg} />

            <HButton
              variant="primary"
              size="lg"
              onPress={handleLogin}
              loading={loading}
              disabled={!email || !password}
              fullWidth
            >
              Continue
            </HButton>
          </HCard>

          <View style={styles.spacerXl} />

          {/* Sign Up Link */}
          <View style={styles.footer}>
            <HText variant="body" color="secondary" center>
              New here?
            </HText>
            <View style={styles.spacerSm} />
            <HButton
              variant="secondary"
              size="md"
              onPress={handleSignUp}
            >
              Create Account
            </HButton>
          </View>
        </View>
      </KeyboardAvoidingView>
    </HScreen>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  content: {
    flex: 1,
    justifyContent: 'center',
  },
  header: {
    alignItems: 'center',
  },
  footer: {
    alignItems: 'center',
  },
  spacerSm: {
    height: hustleSpacing.sm,
  },
  spacerMd: {
    height: hustleSpacing.lg,
  },
  spacerLg: {
    height: hustleSpacing['2xl'],
  },
  spacerXl: {
    height: hustleSpacing['4xl'],
  },
});

export default LoginScreen;
