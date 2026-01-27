/**
 * SignupScreen - Chosen-State Edition
 * 
 * "Let's get you set up" — an invitation, not a form.
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

export function SignupScreen() {
  const navigation = useNavigation<NavigationProp>();
  const { signup, isLoading, error: authError } = useAuth();
  
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [errors, setErrors] = useState<Record<string, string>>({});

  const clearError = (field: string) => {
    setErrors((prev) => {
      const next = { ...prev };
      delete next[field];
      return next;
    });
  };

  const validate = () => {
    const newErrors: Record<string, string> = {};
    
    if (!name.trim()) {
      newErrors.name = "What should we call you?";
    }
    
    if (!email.trim()) {
      newErrors.email = "We'll need your email";
    } else if (!/\S+@\S+\.\S+/.test(email)) {
      newErrors.email = "That doesn't look quite right";
    }
    
    if (!password) {
      newErrors.password = "Pick something secure";
    } else if (password.length < 8) {
      newErrors.password = "A bit longer — 8 characters minimum";
    }
    
    if (password !== confirmPassword) {
      newErrors.confirmPassword = "These don't match yet";
    }
    
    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSignup = async () => {
    if (!validate()) return;
    
    const success = await signup(email, password, name);
    if (success) {
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
    <HScreen ambient>
      <KeyboardAvoidingView 
        style={styles.container}
        behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
        keyboardVerticalOffset={20}
      >
        {/* Header - Inviting, personal */}
        <View style={styles.header}>
          <HText variant="title1" color="primary" center>
            Let's get you set up
          </HText>
          <View style={styles.spacerSm} />
          <HText variant="body" color="secondary" center>
            This only takes a minute
          </HText>
        </View>

        <View style={styles.spacerLg} />

        {/* Signup Form */}
        <HCard variant="default" padding="lg">
          <HInput
            label="Your name"
            placeholder="What should we call you?"
            value={name}
            onChangeText={(text) => {
              setName(text);
              clearError('name');
            }}
            autoCapitalize="words"
            error={errors.name}
          />
          
          <View style={styles.spacerMd} />
          
          <HInput
            label="Email"
            placeholder="you@example.com"
            value={email}
            onChangeText={(text) => {
              setEmail(text);
              clearError('email');
            }}
            keyboardType="email-address"
            autoCapitalize="none"
            autoCorrect={false}
            error={errors.email}
          />
          
          <View style={styles.spacerMd} />
          
          <HInput
            label="Password"
            placeholder="Something secure"
            value={password}
            onChangeText={(text) => {
              setPassword(text);
              clearError('password');
            }}
            secureTextEntry
            error={errors.password}
          />
          
          <View style={styles.spacerMd} />
          
          <HInput
            label="Confirm password"
            placeholder="One more time"
            value={confirmPassword}
            onChangeText={(text) => {
              setConfirmPassword(text);
              clearError('confirmPassword');
            }}
            secureTextEntry
            error={errors.confirmPassword}
          />

          <View style={styles.spacerLg} />

          <HButton
            variant="primary"
            size="lg"
            onPress={handleSignup}
            loading={isLoading}
            fullWidth
          >
            Get Started
          </HButton>
          
          {authError && (
            <>
              <View style={styles.spacerSm} />
              <HText variant="caption" color="error" center>
                {authError}
              </HText>
            </>
          )}
          
          <View style={styles.spacerMd} />
          
          <HText variant="footnote" color="tertiary" center>
            By continuing, you agree to our Terms and Privacy Policy
          </HText>
        </HCard>

        <View style={styles.spacerLg} />

        {/* Login Link */}
        <View style={styles.footer}>
          <HText variant="body" color="secondary" center>
            Already have an account?
          </HText>
          <View style={styles.spacerSm} />
          <HTextButton onPress={handleLogin}>
            Sign in
          </HTextButton>
        </View>
      </KeyboardAvoidingView>
    </HScreen>
  );
}

const styles = StyleSheet.create({
  container: {
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
});

export default SignupScreen;
