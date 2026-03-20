import React from 'react';
import { ScrollView, StyleSheet, Text, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { GRAY, BRAND, STATUS, DARK } from '../../../constants/colors';
import { SPACING } from '../../../constants';
import { useAppState } from '../../app/state';

export default function VerificationScreen() {
  const appState = useAppState();

  return (
    <SafeAreaView style={styles.root} edges={['top']}>
      <ScrollView contentContainerStyle={styles.scrollContent} showsVerticalScrollIndicator={false}>
        <View style={styles.headerCard}>
          <View style={styles.headerIcon}>
            <Text style={styles.headerIconText}>✓</Text>
          </View>
          <Text style={styles.headerTitle}>Get Verified</Text>
          <Text style={styles.headerSubtitle}>
            Verified users unlock premium tasks, earn trust faster, and get priority matching.
          </Text>
        </View>

        <View style={styles.card}>
          <Text style={styles.cardTitle}>Current Tier</Text>
          <Text style={styles.tierValue}>Tier {appState.trustTier} of 5</Text>
          <Text style={styles.cardSubtitle}>Complete verifications to unlock more opportunities.</Text>
        </View>

        <View style={styles.card}>
          <Text style={styles.cardTitle}>Verification Steps</Text>
          <StepRow title="Phone Number" subtitle="Verified" done />
          <StepRow title="Email Address" subtitle="Verified" done />
          <StepRow title="Identity Verification" subtitle="Upload your ID to verify" />
          <StepRow title="Background Check" subtitle="Complete after ID verification" />
        </View>

        <View style={{ height: SPACING[8] }} />
      </ScrollView>
    </SafeAreaView>
  );
}

function StepRow({ title, subtitle, done }: { title: string; subtitle: string; done?: boolean }) {
  return (
    <View style={styles.stepRow}>
      <View style={[styles.stepIcon, done ? styles.stepIconDone : styles.stepIconPending]}>
        <Text style={styles.stepIconText}>{done ? '✓' : '○'}</Text>
      </View>
      <View style={{ flex: 1, marginLeft: SPACING[3] }}>
        <Text style={styles.stepTitle}>{title}</Text>
        <Text style={styles.stepSubtitle}>{subtitle}</Text>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  root: { flex: 1, backgroundColor: GRAY[50] },
  scrollContent: { paddingHorizontal: SPACING[4], paddingTop: SPACING[3], paddingBottom: 32 },
  headerCard: {
    backgroundColor: '#fff',
    borderRadius: 16,
    borderWidth: 1,
    borderColor: GRAY[200],
    padding: SPACING[4],
    marginBottom: SPACING[4],
  },
  headerIcon: {
    width: 72,
    height: 72,
    borderRadius: 36,
    backgroundColor: `${BRAND.PRIMARY}22`,
    alignItems: 'center',
    justifyContent: 'center',
    marginBottom: SPACING[3],
  },
  headerIconText: { color: BRAND.PRIMARY, fontSize: 30, fontWeight: '900' },
  headerTitle: { fontSize: 22, fontWeight: '900', color: GRAY[900], marginBottom: 8 },
  headerSubtitle: { fontSize: 13, color: GRAY[600], fontWeight: '600', lineHeight: 18 },
  card: { backgroundColor: '#fff', borderRadius: 16, borderWidth: 1, borderColor: GRAY[200], padding: SPACING[4], marginBottom: SPACING[4] },
  cardTitle: { color: GRAY[600], fontSize: 13, fontWeight: '900', marginBottom: SPACING[3] },
  tierValue: { fontSize: 18, fontWeight: '900', color: GRAY[900] },
  cardSubtitle: { marginTop: SPACING[2], color: GRAY[600], fontSize: 12, fontWeight: '700' },
  stepRow: { flexDirection: 'row', alignItems: 'center', paddingVertical: SPACING[2], borderTopWidth: 1, borderTopColor: GRAY[200] },
  stepIcon: { width: 40, height: 40, borderRadius: 20, alignItems: 'center', justifyContent: 'center' },
  stepIconDone: { backgroundColor: '#dcfce7' },
  stepIconPending: { backgroundColor: '#f1f5f9' },
  stepIconText: { fontSize: 16, fontWeight: '900', color: GRAY[900] },
  stepTitle: { fontSize: 14, fontWeight: '900', color: GRAY[900] },
  stepSubtitle: { marginTop: 4, fontSize: 12, fontWeight: '600', color: GRAY[600] },
});
