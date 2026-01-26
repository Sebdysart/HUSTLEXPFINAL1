/**
 * LoginScreen - User authentication
 */

import React, { useState } from 'react';
import { View, StyleSheet, KeyboardAvoidingView, Platform } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { Button, Text, Input, Spacing, Card } from '../components';
import { theme } from '../theme';

export function LoginScreen() {
  const insets = useSafeAreaInsets();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  const handleLogin = () => {
    setLoading(true);
    setError('');
    // TODO: Implement actual login
    console.log('Login pressed', { email, password });
    setTimeout(() => {
      setLoading(false);
    }, 1500);
  };

  const handleForgotPassword = () => {
    console.log('Forgot password pressed');
  };

  const handleSignUp = () => {
    console.log('Sign up pressed');
  };

  return (
    <KeyboardAvoidingView 
      style={[styles.container, { paddingTop: insets.top, paddingBottom: insets.bottom }]}
      behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
    >
      <View style={styles.content}>
        {/* Header */}
        <View style={styles.header}>
          <Text variant="hero" color="primary" align="center">
            HustleXP
          </Text>
          <Spacing size={8} />
          <Text variant="body" color="secondary" align="center">
            Sign in to continue
          </Text>
        </View>

        <Spacing size={40} />

        {/* Login Form */}
        <Card variant="default" padding="lg">
          <Input
            label="Email"
            placeholder="you@example.com"
            value={email}
            onChangeText={setEmail}
            keyboardType="email-address"
            autoCapitalize="none"
            autoCorrect={false}
            error={error}
          />
          
          <Spacing size={16} />
          
          <Input
            label="Password"
            placeholder="Enter your password"
            value={password}
            onChangeText={setPassword}
            secureTextEntry
          />

          <Spacing size={8} />

          <Button
            variant="ghost"
            size="sm"
            onPress={handleForgotPassword}
          >
            Forgot password?
          </Button>

          <Spacing size={24} />

          <Button
            variant="primary"
            size="lg"
            onPress={handleLogin}
            loading={loading}
            disabled={!email || !password}
          >
            Sign In
          </Button>
        </Card>

        <Spacing size={24} />

        {/* Sign Up Link */}
        <View style={styles.footer}>
          <Text variant="body" color="secondary">
            Don't have an account?
          </Text>
          <Spacing size={8} />
          <Button
            variant="secondary"
            size="md"
            onPress={handleSignUp}
          >
            Create Account
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
});

export default LoginScreen;
