/**
 * ForgotPasswordScreen - Password recovery
 */

import React, { useState } from 'react';
import { View, StyleSheet, KeyboardAvoidingView, Platform } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { useNavigation } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import type { RootStackParamList } from './../navigation/types';

type NavigationProp = NativeStackNavigationProp<RootStackParamList>;
import { Button, Text, Input, Spacing, Card } from '../components';
import { theme } from '../theme';

export function ForgotPasswordScreen() {
  const insets = useSafeAreaInsets();
  const navigation = useNavigation<NavigationProp>();
  const [email, setEmail] = useState('');
  const [loading, setLoading] = useState(false);
  const [sent, setSent] = useState(false);
  const [error, setError] = useState('');

  const handleResetPassword = () => {
    if (!email.trim()) {
      setError('Email is required');
      return;
    }
    
    if (!/\S+@\S+\.\S+/.test(email)) {
      setError('Invalid email format');
      return;
    }
    
    setError('');
    setLoading(true);
    
    // TODO: Implement actual password reset
    console.log('Reset password for:', email);
    
    setTimeout(() => {
      setLoading(false);
      setSent(true);
    }, 1500);
  };

  const handleBackToLogin = () => {
    console.log('Back to login pressed');
  };

  if (sent) {
    return (
      <View style={[styles.container, { paddingTop: insets.top, paddingBottom: insets.bottom }]}>
        <View style={styles.content}>
          <Card variant="elevated" padding="lg">
            <View style={styles.successIcon}>
              <Text variant="hero" align="center">✉️</Text>
            </View>
            
            <Spacing size={24} />
            
            <Text variant="title2" color="primary" align="center">
              Check your email
            </Text>
            
            <Spacing size={12} />
            
            <Text variant="body" color="secondary" align="center">
              We've sent password reset instructions to {email}
            </Text>
            
            <Spacing size={32} />
            
            <Button
              variant="primary"
              size="lg"
              onPress={handleBackToLogin}
            >
              Back to Sign In
            </Button>
            
            <Spacing size={16} />
            
            <Button
              variant="ghost"
              size="sm"
              onPress={() => setSent(false)}
            >
              Didn't receive email? Try again
            </Button>
          </Card>
        </View>
      </View>
    );
  }

  return (
    <KeyboardAvoidingView 
      style={[styles.container, { paddingTop: insets.top, paddingBottom: insets.bottom }]}
      behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
    >
      <View style={styles.content}>
        {/* Header */}
        <View style={styles.header}>
          <Text variant="title1" color="primary" align="center">
            Reset Password
          </Text>
          <Spacing size={8} />
          <Text variant="body" color="secondary" align="center">
            Enter your email and we'll send you instructions to reset your password
          </Text>
        </View>

        <Spacing size={32} />

        {/* Reset Form */}
        <Card variant="default" padding="lg">
          <Input
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

          <Spacing size={24} />

          <Button
            variant="primary"
            size="lg"
            onPress={handleResetPassword}
            loading={loading}
            disabled={!email}
          >
            Send Reset Link
          </Button>
        </Card>

        <Spacing size={24} />

        {/* Back to Login */}
        <View style={styles.footer}>
          <Button
            variant="ghost"
            size="md"
            onPress={handleBackToLogin}
          >
            ← Back to Sign In
          </Button>
        </View>
      </View>
    </KeyboardAvoidingView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: theme.colors.surface.primary,
  },
  content: {
    flex: 1,
    paddingHorizontal: theme.spacing[4],
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
});

export default ForgotPasswordScreen;
