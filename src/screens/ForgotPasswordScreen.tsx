/**
 * ForgotPasswordScreen - Chosen-State Edition
 * 
 * "No worries, we've got you" — supportive, not bureaucratic.
 */

import React, { useState } from 'react';
import { View, StyleSheet, KeyboardAvoidingView, Platform } from 'react-native';
import { useNavigation } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import { HScreen, HText, HInput, HButton, HTextButton, HCard } from '../components/atoms';
import { hustleSpacing } from '../theme/hustle-tokens';
import { useAuth } from '../hooks';
import type { RootStackParamList } from '../navigation/types';

type NavigationProp = NativeStackNavigationProp<RootStackParamList>;

export function ForgotPasswordScreen() {
  const navigation = useNavigation<NavigationProp>();
  const { forgotPassword, isLoading } = useAuth();
  
  const [email, setEmail] = useState('');
  const [sent, setSent] = useState(false);
  const [error, setError] = useState('');

  const handleResetPassword = async () => {
    if (!email.trim()) {
      setError("We'll need your email for this");
      return;
    }
    
    if (!/\S+@\S+\.\S+/.test(email)) {
      setError("That doesn't look quite right");
      return;
    }
    
    setError('');
    const success = await forgotPassword(email);
    if (success) {
      setSent(true);
    } else {
      setError("Something went wrong. Want to try again?");
    }
  };

  const handleBackToLogin = () => {
    navigation.navigate('Login');
  };

  // Success state
  if (sent) {
    return (
      <HScreen ambient scroll={false}>
        <View style={styles.centerContent}>
          <HCard variant="elevated" padding="xl">
            <View style={styles.successIcon}>
              <HText variant="hero" center>✉️</HText>
            </View>
            
            <View style={styles.spacerLg} />
            
            <HText variant="title2" color="primary" center>
              Check your inbox
            </HText>
            
            <View style={styles.spacerSm} />
            
            <HText variant="body" color="secondary" center>
              We sent reset instructions to {email}
            </HText>
            
            <View style={styles.spacerXl} />
            
            <HButton
              variant="primary"
              size="lg"
              onPress={handleBackToLogin}
              fullWidth
            >
              Back to Sign In
            </HButton>
            
            <View style={styles.spacerMd} />
            
            <HTextButton onPress={() => setSent(false)}>
              Didn't get it? Try again
            </HTextButton>
          </HCard>
        </View>
      </HScreen>
    );
  }

  // Form state
  return (
    <HScreen ambient scroll={false}>
      <KeyboardAvoidingView 
        style={styles.container}
        behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
      >
        <View style={styles.centerContent}>
          {/* Header - Supportive, not bureaucratic */}
          <View style={styles.header}>
            <HText variant="title1" color="primary" center>
              No worries
            </HText>
            <View style={styles.spacerSm} />
            <HText variant="body" color="secondary" center>
              We'll help you get back in
            </HText>
          </View>

          <View style={styles.spacerLg} />

          {/* Reset Form */}
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
              error={error}
            />

            <View style={styles.spacerLg} />

            <HButton
              variant="primary"
              size="lg"
              onPress={handleResetPassword}
              loading={isLoading}
              disabled={!email}
              fullWidth
            >
              Send Reset Link
            </HButton>
          </HCard>

          <View style={styles.spacerLg} />

          {/* Back to Login */}
          <View style={styles.footer}>
            <HTextButton onPress={handleBackToLogin}>
              ← Back to Sign In
            </HTextButton>
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
  centerContent: {
    flex: 1,
    justifyContent: 'center',
  },
  header: {
    alignItems: 'center',
  },
  footer: {
    alignItems: 'center',
  },
  successIcon: {
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

export default ForgotPasswordScreen;
