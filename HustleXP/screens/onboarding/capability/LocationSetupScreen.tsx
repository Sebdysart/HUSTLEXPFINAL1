import React, { useState } from 'react';
import { StyleSheet, Text, TouchableOpacity, View, Vibration } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useNavigation } from '@react-navigation/native';
import { TRPCClient } from '../../../src/network/trpcClient';
import { useAppState } from '../../../src/app/state';
import type { UserRole } from '../../../src/app/types';

const COLORS = {
  black: '#050507',
  purple: '#5B2DFF',
  textPrimary: '#FFFFFF',
  textSecondary: '#8E8E93',
  surfaceElevated: 'rgba(255,255,255,0.06)',
  borderSubtle: 'rgba(255,255,255,0.12)',
  errorRed: '#FF4D4D',
} as const;

function roleConfidence(role: UserRole) {
  // SwiftUI onboarding calls: roleConfidenceWorker, roleConfidencePoster
  if (role === 'poster') {
    return { roleConfidenceWorker: 0.2, roleConfidencePoster: 0.8 };
  }
  return { roleConfidenceWorker: 0.8, roleConfidencePoster: 0.2 };
}

export function LocationSetupScreen() {
  const navigation = useNavigation<any>();
  const appState = useAppState();
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const currentRole = appState.userRole ?? 'hustler';

  const handleFinish = async () => {
    if (isSubmitting) return;
    setError(null);
    setIsSubmitting(true);
    Vibration.vibrate(10);

    try {
      const conf = roleConfidence(currentRole);
      await TRPCClient.shared.call<
        {
          version: string;
          roleConfidenceWorker: number;
          roleConfidencePoster: number;
          roleCertaintyTier: string;
          inconsistencyFlags?: string[] | null;
        },
        {}
      >('user', 'completeOnboarding', 'mutation', {
        version: '1.0',
        roleConfidenceWorker: conf.roleConfidenceWorker,
        roleConfidencePoster: conf.roleConfidencePoster,
        roleCertaintyTier: 'MODERATE',
        inconsistencyFlags: null,
      });

      // Switch RootNavigator to authenticated state.
      appState.completeOnboarding();
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Failed to complete onboarding');
      Vibration.vibrate(30);
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <SafeAreaView style={styles.root} edges={['top', 'bottom']}>
      <View style={styles.container}>
        <Text style={styles.title}>Almost there</Text>
        <Text style={styles.subtitle}>Finishing onboarding lets us start matching tasks for you.</Text>

        <View style={styles.card}>
          <Text style={styles.cardText}>
            Role: {currentRole === 'poster' ? 'Poster' : 'Hustler'}
          </Text>
          {error ? <Text style={styles.errorText}>{error}</Text> : null}
        </View>

        <View style={{ flex: 1 }} />

        <TouchableOpacity
          style={[styles.continueButton, isSubmitting ? { opacity: 0.7 } : null]}
          disabled={isSubmitting}
          onPress={handleFinish}
        >
          <Text style={styles.continueText}>{isSubmitting ? 'Submitting...' : 'Finish'}</Text>
        </TouchableOpacity>

        <TouchableOpacity disabled={isSubmitting} onPress={() => navigation.goBack()}>
          <Text style={styles.backText}>Back</Text>
        </TouchableOpacity>
      </View>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  root: { flex: 1, backgroundColor: COLORS.black },
  container: { flex: 1, paddingHorizontal: 20, paddingTop: 10 },
  title: { color: COLORS.textPrimary, fontSize: 26, fontWeight: '800', marginTop: 10 },
  subtitle: { color: COLORS.textSecondary, fontSize: 14, marginTop: 12, lineHeight: 20 },
  card: {
    marginTop: 18,
    backgroundColor: COLORS.surfaceElevated,
    borderRadius: 14,
    padding: 16,
    borderWidth: 1,
    borderColor: COLORS.borderSubtle,
  },
  cardText: { color: COLORS.textSecondary, fontSize: 14, lineHeight: 20 },
  errorText: { color: COLORS.errorRed, fontSize: 13, marginTop: 10 },
  continueButton: {
    height: 50,
    borderRadius: 12,
    backgroundColor: COLORS.purple,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    gap: 10,
    marginBottom: 12,
  },
  continueText: { color: COLORS.textPrimary, fontWeight: '800', fontSize: 16 },
  backText: { color: COLORS.textSecondary, fontSize: 14, textAlign: 'center' },
});
