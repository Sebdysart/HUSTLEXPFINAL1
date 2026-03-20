import React from 'react';
import { StyleSheet, Text, TouchableOpacity, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useNavigation } from '@react-navigation/native';

const COLORS = {
  black: '#050507',
  purple: '#5B2DFF',
  textPrimary: '#FFFFFF',
  textSecondary: '#8E8E93',
  surfaceElevated: 'rgba(255,255,255,0.06)',
  borderSubtle: 'rgba(255,255,255,0.12)',
} as const;

export function PreferenceLockScreen() {
  const navigation = useNavigation<any>();

  return (
    <SafeAreaView style={styles.root} edges={['top', 'bottom']}>
      <View style={styles.container}>
        <Text style={styles.title}>Set preferences</Text>
        <Text style={styles.subtitle}>We’ll use these to tailor task matching.</Text>

        <View style={styles.card}>
          <Text style={styles.cardText}>
            Location + skill calibration helps us find the best nearby opportunities.
          </Text>
        </View>

        <View style={{ flex: 1 }} />

        <TouchableOpacity
          style={styles.continueButton}
          onPress={() => navigation.navigate('CapabilityIntro')}
        >
          <Text style={styles.continueText}>Continue</Text>
          <Text style={styles.chevron}>{'›'}</Text>
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
  chevron: { color: COLORS.textPrimary, fontWeight: '800', fontSize: 18 },
});
