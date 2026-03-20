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

function FieldLabel({ children }: { children: React.ReactNode }) {
  return <Text style={styles.label}>{children}</Text>;
}

function TextField(props: {
  label: string;
  placeholder: string;
  value: string;
  onChangeText: (v: string) => void;
  keyboardType?: 'default' | 'email-address';
  secureTextEntry?: boolean;
  error?: string | null;
}) {
  return (
    <View style={styles.field}>
      <FieldLabel>{props.label}</FieldLabel>
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
          keyboardType={props.keyboardType ?? 'default'}
          secureTextEntry={props.secureTextEntry}
          autoCapitalize="none"
          style={styles.input}
        />
      </View>
      {props.error ? <Text style={styles.errorText}>{props.error}</Text> : null}
    </View>
  );
}

export function LoginScreen() {
  const navigation = useNavigation<any>();
  const auth = useAuth();

  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [loginError, setLoginError] = useState<string | null>(null);
  const [emailError, setEmailError] = useState<string | null>(null);
  const [passwordError, setPasswordError] = useState<string | null>(null);

  const isValid = useMemo(() => {
    return (
      email.length > 0 &&
      password.length > 0 &&
      !emailError &&
      !passwordError
    );
  }, [email, password, emailError, passwordError]);

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

  const handleLogin = async () => {
    if (!isValid || isLoading) return;

    Vibration.vibrate(10);
    setIsLoading(true);
    setLoginError(null);

    try {
      await auth.signIn({ email, password });
      // Navigation is handled by RootNavigator when authState changes.
    } catch (e) {
      setLoginError(e instanceof Error ? e.message : 'Sign in failed');
      Vibration.vibrate(30);
    } finally {
      setIsLoading(false);
    }
  };

  const handleApple = () => {
    // Apple Sign-In needs platform-specific native integration; keep UX parity for now.
    setLoginError('Apple sign-in is not implemented in this React Native port yet.');
  };

  const handleGoogle = async () => {
    setIsLoading(true);
    setLoginError(null);
    try {
      await auth.signInWithGoogle();
    } catch (e) {
      setLoginError(e instanceof Error ? e.message : 'Google sign-in failed');
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
          <Text style={styles.title}>Welcome back</Text>
          <Text style={styles.subtitle}>Sign in to continue your hustle</Text>
        </View>

        <View style={styles.card}>
          {loginError ? (
            <Text style={[styles.errorBanner]}>{loginError}</Text>
          ) : null}

          <TextField
            label="Email"
            placeholder="your@email.com"
            value={email}
            keyboardType="email-address"
            onChangeText={(v) => {
              setEmail(v);
              validateEmail(v);
              setLoginError(null);
            }}
            error={emailError}
          />

          <TextField
            label="Password"
            placeholder="Enter password"
            value={password}
            secureTextEntry
            onChangeText={(v) => {
              setPassword(v);
              validatePassword(v);
              setLoginError(null);
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
            onPress={handleLogin}
          >
            <Text style={styles.primaryButtonText}>
              {isLoading ? 'Signing in...' : 'Sign In'}
            </Text>
          </TouchableOpacity>

          <TouchableOpacity
            onPress={() => navigation.navigate('ForgotPassword')}
            disabled={isLoading}
          >
            <Text style={styles.linkText}>Forgot Password?</Text>
          </TouchableOpacity>

          <View style={styles.dividerRow}>
            <View style={styles.dividerLine} />
            <Text style={styles.dividerText}>or continue with</Text>
            <View style={styles.dividerLine} />
          </View>

          <TouchableOpacity
            style={styles.socialButton}
            disabled={isLoading}
            onPress={handleApple}
          >
            <Text style={styles.socialButtonText}>Apple</Text>
          </TouchableOpacity>

          <TouchableOpacity
            style={styles.socialButton}
            disabled={isLoading}
            onPress={handleGoogle}
          >
            <Text style={styles.socialButtonText}>Google</Text>
          </TouchableOpacity>

          <View style={styles.signupRow}>
            <Text style={styles.signupMuted}>New to HustleXP?</Text>
            <TouchableOpacity disabled={isLoading} onPress={() => navigation.navigate('Signup')}>
              <Text style={styles.signupLink}>Create Account</Text>
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
  linkText: { color: COLORS.purpleBright, fontWeight: '700', marginTop: 12, textAlign: 'right' },
  dividerRow: { flexDirection: 'row', alignItems: 'center', marginVertical: 14 },
  dividerLine: { flex: 1, height: 1, backgroundColor: 'rgba(255,255,255,0.12)' },
  dividerText: { color: COLORS.textSecondary, fontSize: 12, paddingHorizontal: 10 },
  socialButton: {
    height: 48,
    borderRadius: 12,
    backgroundColor: 'rgba(255,255,255,0.06)',
    borderWidth: 1,
    borderColor: 'rgba(255,255,255,0.12)',
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 10,
  },
  socialButtonText: { color: COLORS.textPrimary, fontWeight: '700' },
  signupRow: { flexDirection: 'row', justifyContent: 'center', alignItems: 'center', marginTop: 6 },
  signupMuted: { color: COLORS.textSecondary, marginRight: 6, fontSize: 13 },
  signupLink: { color: COLORS.purpleBright, fontWeight: '800', fontSize: 13 },
});
