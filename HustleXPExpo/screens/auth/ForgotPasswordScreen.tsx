import React, { useState } from 'react';
import {
  KeyboardAvoidingView,
  Platform,
  StyleSheet,
  Text,
  TextInput,
  TouchableOpacity,
  View,
  Vibration,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useNavigation } from '@react-navigation/native';
import { useAuth } from '../../src/auth/AuthProvider';

const COLORS = {
  black: '#050507',
  purple: '#5B2DFF',
  purpleBright: '#7B4DFF',
  textPrimary: '#FFFFFF',
  textSecondary: '#8E8E93',
  borderSubtle: 'rgba(255,255,255,0.12)',
  surfaceElevated: 'rgba(255,255,255,0.06)',
  errorRed: '#FF4D4D',
} as const;

export function ForgotPasswordScreen() {
  const navigation = useNavigation<any>();
  const auth = useAuth();

  const [email, setEmail] = useState('');
  const [error, setError] = useState<string | null>(null);
  const [sent, setSent] = useState(false);
  const [isLoading, setIsLoading] = useState(false);

  const isValid = email.includes('@') && email.includes('.');

  const handleReset = async () => {
    if (!isValid || isLoading) return;

    Vibration.vibrate(10);
    setIsLoading(true);
    setError(null);

    try {
      await auth.sendPasswordReset(email);
      setSent(true);
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Failed to send reset email');
      Vibration.vibrate(30);
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <SafeAreaView style={styles.root} edges={['top', 'bottom']}>
      <KeyboardAvoidingView
        behavior={Platform.OS === 'ios' ? 'padding' : undefined}
        style={styles.container}
      >
        <View style={styles.header}>
          <Text style={styles.title}>Reset password</Text>
          <Text style={styles.subtitle}>We'll email you a link to create a new password.</Text>
        </View>

        <View style={styles.card}>
          {error ? <Text style={styles.errorText}>{error}</Text> : null}
          {sent ? (
            <Text style={styles.successText}>Check your inbox for the reset link.</Text>
          ) : null}

          <View style={styles.field}>
            <Text style={styles.label}>Email</Text>
            <View style={styles.inputShell}>
              <TextInput
                placeholder="your@email.com"
                placeholderTextColor="rgba(255,255,255,0.35)"
                value={email}
                onChangeText={(v) => {
                  setEmail(v);
                  setError(null);
                  setSent(false);
                }}
                keyboardType="email-address"
                autoCapitalize="none"
                style={styles.input}
              />
            </View>
          </View>

          <TouchableOpacity
            style={[
              styles.primaryButton,
              (!isValid || isLoading) ? { opacity: 0.6 } : null,
            ]}
            disabled={!isValid || isLoading}
            onPress={handleReset}
          >
            <Text style={styles.primaryButtonText}>
              {isLoading ? 'Sending...' : 'Send reset email'}
            </Text>
          </TouchableOpacity>

          <TouchableOpacity onPress={() => navigation.navigate('Login')} disabled={isLoading}>
            <Text style={styles.linkText}>Back to Sign in</Text>
          </TouchableOpacity>
        </View>
      </KeyboardAvoidingView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  root: { flex: 1, backgroundColor: COLORS.black },
  container: { flex: 1, paddingHorizontal: 20, justifyContent: 'center' },
  header: { marginBottom: 18 },
  title: { color: COLORS.textPrimary, fontSize: 28, fontWeight: '800' },
  subtitle: { color: COLORS.textSecondary, fontSize: 14, marginTop: 6, lineHeight: 18 },
  card: {
    backgroundColor: COLORS.surfaceElevated,
    borderRadius: 16,
    padding: 16,
    borderWidth: 1,
    borderColor: 'rgba(255,255,255,0.08)',
  },
  field: { marginBottom: 14 },
  label: { color: COLORS.textSecondary, fontSize: 13, fontWeight: '600', marginBottom: 6 },
  inputShell: {
    borderRadius: 12,
    borderWidth: 1,
    borderColor: COLORS.borderSubtle,
    paddingHorizontal: 12,
    paddingVertical: 10,
    backgroundColor: 'rgba(0,0,0,0.18)',
  },
  input: { color: COLORS.textPrimary, fontSize: 16, paddingVertical: 0 },
  errorText: { color: COLORS.errorRed, marginBottom: 10, fontSize: 13 },
  successText: { color: COLORS.purpleBright, marginBottom: 10, fontSize: 13 },
  primaryButton: {
    marginTop: 8,
    height: 52,
    borderRadius: 14,
    backgroundColor: COLORS.purple,
    justifyContent: 'center',
    alignItems: 'center',
  },
  primaryButtonText: { color: COLORS.textPrimary, fontWeight: '800', fontSize: 16 },
  linkText: { color: COLORS.purpleBright, fontWeight: '800', marginTop: 12, textAlign: 'center' },
});

