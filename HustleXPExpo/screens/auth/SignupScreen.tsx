import React, { useMemo, useState } from 'react';
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

function Label({ children }: { children: React.ReactNode }) {
  return <Text style={styles.label}>{children}</Text>;
}

function Field(props: {
  label: string;
  placeholder: string;
  value: string;
  onChangeText: (v: string) => void;
  secure?: boolean;
  error?: string | null;
}) {
  return (
    <View style={styles.field}>
      <Label>{props.label}</Label>
      <View
        style={[
          styles.inputShell,
          props.error ? { borderColor: COLORS.errorRed } : null,
        ]}
      >
        <TextInput
          placeholder={props.placeholder}
          placeholderTextColor="rgba(255,255,255,0.35)"
          value={props.value}
          onChangeText={props.onChangeText}
          secureTextEntry={props.secure}
          autoCapitalize="none"
          style={styles.input}
        />
      </View>
      {props.error ? <Text style={styles.errorText}>{props.error}</Text> : null}
    </View>
  );
}

export function SignupScreen() {
  const navigation = useNavigation<any>();
  const auth = useAuth();

  const [fullName, setFullName] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [signupError, setSignupError] = useState<string | null>(null);
  const [emailError, setEmailError] = useState<string | null>(null);
  const [passwordError, setPasswordError] = useState<string | null>(null);

  const isValid = useMemo(() => {
    return (
      fullName.trim().length >= 2 &&
      email.length > 0 &&
      password.length > 0 &&
      !emailError &&
      !passwordError
    );
  }, [email, emailError, fullName, password, passwordError]);

  const validateEmail = (v: string) => {
    if (!v) {
      setEmailError(null);
      return;
    }
    if (!v.includes('@') || !v.includes('.')) {
      setEmailError('Please enter a valid email');
    } else {
      setEmailError(null);
    }
  };

  const validatePassword = (v: string) => {
    if (!v) {
      setPasswordError(null);
      return;
    }
    if (v.length < 6) {
      setPasswordError('Password must be at least 6 characters');
    } else {
      setPasswordError(null);
    }
  };

  const handleSignup = async () => {
    if (!isValid || isLoading) return;

    Vibration.vibrate(10);
    setIsLoading(true);
    setSignupError(null);

    try {
      await auth.signUp({
        email,
        password,
        fullName: fullName.trim(),
        defaultMode: 'hustler',
      });
      // RootNavigator will switch to onboarding/auth when appState changes.
    } catch (e) {
      setSignupError(e instanceof Error ? e.message : 'Sign up failed');
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
          <View style={styles.logo} />
          <Text style={styles.title}>Create account</Text>
          <Text style={styles.subtitle}>Start your HustleXP journey</Text>
        </View>

        <View style={styles.card}>
          {signupError ? <Text style={styles.errorBanner}>{signupError}</Text> : null}

          <Field
            label="Full name"
            placeholder="Your name"
            value={fullName}
            onChangeText={(v) => {
              setFullName(v);
              setSignupError(null);
            }}
          />

          <Field
            label="Email"
            placeholder="your@email.com"
            value={email}
            onChangeText={(v) => {
              setEmail(v);
              validateEmail(v);
              setSignupError(null);
            }}
            error={emailError}
          />

          <Field
            label="Password"
            placeholder="Enter password"
            value={password}
            secure
            onChangeText={(v) => {
              setPassword(v);
              validatePassword(v);
              setSignupError(null);
            }}
            error={passwordError}
          />

          <TouchableOpacity
            style={[
              styles.primaryButton,
              (!isValid || isLoading) ? { opacity: 0.6 } : null,
            ]}
            activeOpacity={0.85}
            disabled={!isValid || isLoading}
            onPress={handleSignup}
          >
            <Text style={styles.primaryButtonText}>
              {isLoading ? 'Creating...' : 'Create Account'}
            </Text>
          </TouchableOpacity>

          <View style={styles.loginRow}>
            <Text style={styles.signupMuted}>Already have an account?</Text>
            <TouchableOpacity disabled={isLoading} onPress={() => navigation.navigate('Login')}>
              <Text style={styles.loginLink}>Sign in</Text>
            </TouchableOpacity>
          </View>
        </View>
      </KeyboardAvoidingView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  root: { flex: 1, backgroundColor: COLORS.black },
  container: { flex: 1, paddingHorizontal: 20, justifyContent: 'center' },
  header: { marginBottom: 18 },
  logo: { width: 76, height: 76, borderRadius: 22, backgroundColor: COLORS.purple },
  title: { color: COLORS.textPrimary, fontSize: 28, fontWeight: '700', marginTop: 14 },
  subtitle: { color: COLORS.textSecondary, fontSize: 14, marginTop: 4, lineHeight: 18 },
  card: {
    backgroundColor: COLORS.surfaceElevated,
    borderRadius: 16,
    padding: 16,
    borderWidth: 1,
    borderColor: 'rgba(255,255,255,0.08)',
  },
  label: { color: COLORS.textSecondary, fontSize: 13, fontWeight: '600', marginBottom: 6 },
  field: { marginBottom: 12 },
  inputShell: {
    borderRadius: 12,
    borderWidth: 1,
    borderColor: COLORS.borderSubtle,
    paddingHorizontal: 12,
    paddingVertical: 10,
    backgroundColor: 'rgba(0,0,0,0.18)',
  },
  input: { color: COLORS.textPrimary, fontSize: 16, paddingVertical: 0 },
  errorText: { marginTop: 6, color: COLORS.errorRed, fontSize: 12 },
  errorBanner: { color: COLORS.errorRed, fontSize: 13, marginBottom: 12 },
  primaryButton: {
    marginTop: 10,
    height: 52,
    borderRadius: 14,
    backgroundColor: COLORS.purple,
    justifyContent: 'center',
    alignItems: 'center',
  },
  primaryButtonText: { color: COLORS.textPrimary, fontWeight: '800', fontSize: 16 },
  loginRow: { flexDirection: 'row', justifyContent: 'center', alignItems: 'center', marginTop: 10 },
  signupMuted: { color: COLORS.textSecondary, fontSize: 13, marginRight: 6 },
  loginLink: { color: COLORS.purpleBright, fontWeight: '800', fontSize: 13 },
});

