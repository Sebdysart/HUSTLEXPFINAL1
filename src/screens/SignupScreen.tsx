/**
 * SignupScreen - Create new account
 */

import React, { useState } from 'react';
import { View, StyleSheet, KeyboardAvoidingView, Platform, ScrollView } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { useNavigation } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import type { RootStackParamList } from './../navigation/types';

type NavigationProp = NativeStackNavigationProp<RootStackParamList>;
import { Button, Text, Input, Spacing, Card } from '../components';
import { theme } from '../theme';
import { useAuth } from '../hooks';

export function SignupScreen() {
  const insets = useSafeAreaInsets();
  const navigation = useNavigation<NavigationProp>();
  const { signup, isLoading, error: authError } = useAuth();
  
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [errors, setErrors] = useState<Record<string, string>>({});

  const validate = () => {
    const newErrors: Record<string, string> = {};
    
    if (!name.trim()) {
      newErrors.name = 'Name is required';
    }
    
    if (!email.trim()) {
      newErrors.email = 'Email is required';
    } else if (!/\S+@\S+\.\S+/.test(email)) {
      newErrors.email = 'Invalid email format';
    }
    
    if (!password) {
      newErrors.password = 'Password is required';
    } else if (password.length < 8) {
      newErrors.password = 'Password must be at least 8 characters';
    }
    
    if (password !== confirmPassword) {
      newErrors.confirmPassword = 'Passwords do not match';
    }
    
    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSignup = async () => {
    if (!validate()) return;
    
    const success = await signup(email, password, name);
    if (success) {
      // New users go through onboarding
      navigation.reset({
        index: 0,
        routes: [{ name: 'Framing' }],
      });
    }
  };

  const handleLogin = () => {
    navigation.navigate('Login');
  };

  return (
    <KeyboardAvoidingView 
      style={[styles.container, { paddingTop: insets.top, paddingBottom: insets.bottom }]}
      behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
    >
      <ScrollView 
        contentContainerStyle={styles.scrollContent}
        keyboardShouldPersistTaps="handled"
      >
        {/* Header */}
        <View style={styles.header}>
          <Text variant="title1" color="primary" align="center">
            Create Account
          </Text>
          <Spacing size={8} />
          <Text variant="body" color="secondary" align="center">
            Join HustleXP and start earning
          </Text>
        </View>

        <Spacing size={32} />

        {/* Signup Form */}
        <Card variant="default" padding="lg">
          <Input
            label="Full Name"
            placeholder="John Doe"
            value={name}
            onChangeText={setName}
            autoCapitalize="words"
            error={errors.name}
          />
          
          <Spacing size={16} />
          
          <Input
            label="Email"
            placeholder="you@example.com"
            value={email}
            onChangeText={setEmail}
            keyboardType="email-address"
            autoCapitalize="none"
            autoCorrect={false}
            error={errors.email}
          />
          
          <Spacing size={16} />
          
          <Input
            label="Password"
            placeholder="At least 8 characters"
            value={password}
            onChangeText={setPassword}
            secureTextEntry
            error={errors.password}
          />
          
          <Spacing size={16} />
          
          <Input
            label="Confirm Password"
            placeholder="Re-enter your password"
            value={confirmPassword}
            onChangeText={setConfirmPassword}
            secureTextEntry
            error={errors.confirmPassword}
          />

          <Spacing size={24} />

          <Button
            variant="primary"
            size="lg"
            onPress={handleSignup}
            loading={isLoading}
          >
            Create Account
          </Button>
          
          {authError && (
            <>
              <Spacing size={12} />
              <Text variant="caption" color="error" align="center">{authError}</Text>
            </>
          )}
          
          <Spacing size={16} />
          
          <Text variant="footnote" color="tertiary" align="center">
            By signing up, you agree to our Terms of Service and Privacy Policy
          </Text>
        </Card>

        <Spacing size={24} />

        {/* Login Link */}
        <View style={styles.footer}>
          <Text variant="body" color="secondary">
            Already have an account?
          </Text>
          <Spacing size={8} />
          <Button
            variant="ghost"
            size="md"
            onPress={handleLogin}
          >
            Sign In
          </Button>
        </View>
      </ScrollView>
    </KeyboardAvoidingView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: theme.colors.surface.primary,
  },
  scrollContent: {
    flexGrow: 1,
    paddingHorizontal: theme.spacing[4],
    paddingVertical: theme.spacing[6],
    justifyContent: 'center',
  },
  header: {
    alignItems: 'center',
  },
  footer: {
    alignItems: 'center',
  },
});

export default SignupScreen;
