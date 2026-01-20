import React, { useState } from 'react';
import { View, Text, TextInput, Button, StyleSheet, TouchableOpacity, ActivityIndicator } from 'react-native';
import { useNavigation } from '@react-navigation/native';
import { NEUTRAL, SPACING, RADIUS, FONT_SIZE } from '../../constants';
import { login } from '../../services/dataService';
import { useCurrentUser, User } from '../../contexts/UserContext';

export function AuthLoginScreen() {
  const navigation = useNavigation();
  const { setUser } = useCurrentUser();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [emailError, setEmailError] = useState<string | null>(null);
  const [passwordError, setPasswordError] = useState<string | null>(null);

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
    setPasswordError(null);
    return true;
  };

  const handleLogin = async () => {
    setError(null);
    
    // Validate form
    const isEmailValid = validateEmail(email);
    const isPasswordValid = validatePassword(password);
    
    if (!isEmailValid || !isPasswordValid) {
      return;
    }

    setIsLoading(true);
    try {
      const response = await login(email, password) as { success: boolean; data: User | null; error: string | null };
      
      if (response.success && response.data) {
        // Set user in context
        // RootNavigator will automatically route to correct screen based on user state
        setUser(response.data);
      } else {
        setError(response.error || 'Login failed. Please try again.');
      }
    } catch (err) {
      setError(err instanceof Error ? err.message : 'An unexpected error occurred');
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <View style={styles.container}>
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
        placeholder="Password"
        value={password}
        onChangeText={(text) => {
          setPassword(text);
          if (passwordError) {
            validatePassword(text);
          }
        }}
        onBlur={() => validatePassword(password)}
        secureTextEntry
        autoCapitalize="none"
        editable={!isLoading}
      />
      {passwordError && <Text style={styles.errorText}>{passwordError}</Text>}
      
      {error && <Text style={styles.errorText}>{error}</Text>}
      
      {isLoading ? (
        <ActivityIndicator size="large" color={NEUTRAL.TEXT} style={styles.loader} />
      ) : (
        <Button title="Login" onPress={handleLogin} disabled={isLoading} />
      )}
      
      <TouchableOpacity onPress={() => navigation.navigate('A3' as never)} disabled={isLoading}>
        <Text style={[styles.link, isLoading && styles.linkDisabled]}>Forgot Password</Text>
      </TouchableOpacity>
      <TouchableOpacity onPress={() => navigation.navigate('A2' as never)} disabled={isLoading}>
        <Text style={[styles.link, isLoading && styles.linkDisabled]}>Sign Up</Text>
      </TouchableOpacity>
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
});
