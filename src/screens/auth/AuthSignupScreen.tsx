import React, { useState } from 'react';
import { Text, TextInput, Button, StyleSheet, TouchableOpacity, ScrollView, ActivityIndicator } from 'react-native';
import { useNavigation } from '@react-navigation/native';
import { NEUTRAL, SPACING, RADIUS, FONT_SIZE } from '../../constants';
import { signup } from '../../services/dataService';
import { useCurrentUser, User } from '../../contexts/UserContext';

export function AuthSignupScreen() {
  const navigation = useNavigation();
  const { setUser } = useCurrentUser();
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [nameError, setNameError] = useState<string | null>(null);
  const [emailError, setEmailError] = useState<string | null>(null);
  const [passwordError, setPasswordError] = useState<string | null>(null);
  const [confirmPasswordError, setConfirmPasswordError] = useState<string | null>(null);

  const validateName = (nameValue: string): boolean => {
    if (!nameValue) {
      setNameError('Full name is required');
      return false;
    }
    if (nameValue.length < 2) {
      setNameError('Full name must be at least 2 characters');
      return false;
    }
    setNameError(null);
    return true;
  };

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

  const validatePassword = (passwordValue: string): boolean => {
    if (!passwordValue) {
      setPasswordError('Password is required');
      return false;
    }
    if (passwordValue.length < 8) {
      setPasswordError('Password must be at least 8 characters');
      return false;
    }
    if (!/[A-Z]/.test(passwordValue)) {
      setPasswordError('Password must contain at least one uppercase letter');
      return false;
    }
    if (!/[0-9]/.test(passwordValue)) {
      setPasswordError('Password must contain at least one number');
      return false;
    }
    setPasswordError(null);
    return true;
  };

  const validateConfirmPassword = (confirmPasswordValue: string): boolean => {
    if (!confirmPasswordValue) {
      setConfirmPasswordError('Please confirm your password');
      return false;
    }
    if (confirmPasswordValue !== password) {
      setConfirmPasswordError('Passwords do not match');
      return false;
    }
    setConfirmPasswordError(null);
    return true;
  };

  const handleSignUp = async () => {
    setError(null);
    
    // Validate all fields
    const isNameValid = validateName(name);
    const isEmailValid = validateEmail(email);
    const isPasswordValid = validatePassword(password);
    const isConfirmPasswordValid = validateConfirmPassword(confirmPassword);
    
    if (!isNameValid || !isEmailValid || !isPasswordValid || !isConfirmPasswordValid) {
      return;
    }

    setIsLoading(true);
    try {
      const response = await signup({
        email,
        fullName: name,
        defaultMode: 'worker', // Default to worker mode
      }) as { success: boolean; data: User | null; error: string | null };
      
      if (response.success && response.data) {
        // Set user in context
        // RootNavigator will automatically route to OnboardingStack (new users always need onboarding)
        setUser(response.data);
      } else {
        setError(response.error || 'Signup failed. Please try again.');
      }
    } catch (err) {
      setError(err instanceof Error ? err.message : 'An unexpected error occurred');
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <ScrollView style={styles.container} contentContainerStyle={styles.contentContainer}>
      <TextInput
        style={[styles.input, nameError && styles.inputError]}
        placeholder="Full Name"
        value={name}
        onChangeText={(text) => {
          setName(text);
          if (nameError) {
            validateName(text);
          }
        }}
        onBlur={() => validateName(name)}
        autoCapitalize="words"
        editable={!isLoading}
      />
      {nameError && <Text style={styles.errorText}>{nameError}</Text>}
      
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
      
      <TextInput
        style={[styles.input, passwordError && styles.inputError]}
        placeholder="Password (8+ chars, 1 uppercase, 1 number)"
        value={password}
        onChangeText={(text) => {
          setPassword(text);
          if (passwordError) {
            validatePassword(text);
          }
          // Re-validate confirm password if it's been entered
          if (confirmPassword) {
            validateConfirmPassword(confirmPassword);
          }
        }}
        onBlur={() => validatePassword(password)}
        secureTextEntry
        autoCapitalize="none"
        editable={!isLoading}
      />
      {passwordError && <Text style={styles.errorText}>{passwordError}</Text>}
      
      <TextInput
        style={[styles.input, confirmPasswordError && styles.inputError]}
        placeholder="Confirm Password"
        value={confirmPassword}
        onChangeText={(text) => {
          setConfirmPassword(text);
          if (confirmPasswordError) {
            validateConfirmPassword(text);
          }
        }}
        onBlur={() => validateConfirmPassword(confirmPassword)}
        secureTextEntry
        autoCapitalize="none"
        editable={!isLoading}
      />
      {confirmPasswordError && <Text style={styles.errorText}>{confirmPasswordError}</Text>}
      
      {error && <Text style={styles.errorText}>{error}</Text>}
      
      {isLoading ? (
        <ActivityIndicator size="large" color={NEUTRAL.TEXT} style={styles.loader} />
      ) : (
        <Button title="Sign Up" onPress={handleSignUp} disabled={isLoading} />
      )}
      
      <TouchableOpacity onPress={() => navigation.navigate('A1' as never)} disabled={isLoading}>
        <Text style={[styles.link, isLoading && styles.linkDisabled]}>Already have account</Text>
      </TouchableOpacity>
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: NEUTRAL.BACKGROUND,
  },
  contentContainer: {
    padding: SPACING[4],
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
});
