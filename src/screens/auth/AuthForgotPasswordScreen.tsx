import React, { useState } from 'react';
import { View, Text, TextInput, Button, StyleSheet, TouchableOpacity, ActivityIndicator } from 'react-native';
import { useNavigation } from '@react-navigation/native';
import { NEUTRAL, SPACING, RADIUS, FONT_SIZE, FONT_WEIGHT } from '../../constants';
import { requestPasswordReset } from '../../services/dataService';

export function AuthForgotPasswordScreen() {
  const navigation = useNavigation();
  const [email, setEmail] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [emailError, setEmailError] = useState<string | null>(null);
  const [success, setSuccess] = useState(false);

  const validateEmail = (emailValue: string): boolean => {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailValue) {
      setEmailError('Email is required');
      return false;
    }
    if (!emailRegex.test(emailValue)) {
      setEmailError('Please enter a valid email address');
      return false;
    }
    setEmailError(null);
    return true;
  };

  const handleSubmit = async () => {
    setError(null);
    setSuccess(false);
    
    // Validate email
    if (!validateEmail(email)) {
      return;
    }

    setIsLoading(true);
    try {
      const response = await requestPasswordReset(email) as { success: boolean; data: any; error: string | null };
      
      if (response.success) {
        setSuccess(true);
      } else {
        setError(response.error || 'Failed to send reset link. Please try again.');
      }
    } catch (err) {
      setError(err instanceof Error ? err.message : 'An unexpected error occurred');
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <View style={styles.container}>
      {success ? (
        <View style={styles.successContainer}>
          <Text style={styles.successTitle}>Check your email</Text>
          <Text style={styles.successMessage}>
            We've sent a password reset link to {email}
          </Text>
          <Button title="Back to Login" onPress={() => navigation.navigate('A1' as never)} />
        </View>
      ) : (
        <>
          <TextInput
            style={[styles.input, emailError && styles.inputError]}
            placeholder="Email"
            value={email}
            onChangeText={(text) => {
              setEmail(text);
              if (emailError) {
                validateEmail(text);
              }
            }}
            onBlur={() => validateEmail(email)}
            keyboardType="email-address"
            autoCapitalize="none"
            editable={!isLoading}
          />
          {emailError && <Text style={styles.errorText}>{emailError}</Text>}
          
          {error && <Text style={styles.errorText}>{error}</Text>}
          
          {isLoading ? (
            <ActivityIndicator size="large" color={NEUTRAL.TEXT} style={styles.loader} />
          ) : (
            <Button title="Send Reset Link" onPress={handleSubmit} disabled={isLoading} />
          )}
          
          <TouchableOpacity onPress={() => navigation.navigate('A1' as never)} disabled={isLoading}>
            <Text style={[styles.link, isLoading && styles.linkDisabled]}>Back to login</Text>
          </TouchableOpacity>
        </>
      )}
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    padding: SPACING[4],
    backgroundColor: NEUTRAL.BACKGROUND,
  },
  input: {
    height: 48,
    borderWidth: 1,
    borderColor: NEUTRAL.BORDER,
    borderRadius: RADIUS.md,
    paddingHorizontal: SPACING[3],
    marginBottom: SPACING[2],
    fontSize: FONT_SIZE.base,
    color: NEUTRAL.TEXT,
  },
  inputError: {
    borderColor: '#EF4444',
  },
  errorText: {
    color: '#EF4444',
    fontSize: FONT_SIZE.sm,
    marginBottom: SPACING[2],
    marginTop: -SPACING[2],
  },
  loader: {
    marginVertical: SPACING[4],
  },
  link: {
    marginTop: SPACING[4],
    color: NEUTRAL.TEXT_SECONDARY,
    fontSize: FONT_SIZE.sm,
    textDecorationLine: 'underline',
  },
  linkDisabled: {
    opacity: 0.5,
  },
  successContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  successTitle: {
    fontSize: FONT_SIZE['2xl'],
    fontWeight: FONT_WEIGHT.bold,
    color: NEUTRAL.TEXT,
    marginBottom: SPACING[4],
    textAlign: 'center',
  },
  successMessage: {
    fontSize: FONT_SIZE.base,
    color: NEUTRAL.TEXT_SECONDARY,
    marginBottom: SPACING[6],
    textAlign: 'center',
    paddingHorizontal: SPACING[4],
  },
});
