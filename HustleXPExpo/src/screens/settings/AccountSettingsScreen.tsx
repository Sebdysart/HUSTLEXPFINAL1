import React from 'react';
import { ScrollView, StyleSheet, Text, TouchableOpacity, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useAuth } from '../../auth/AuthProvider';
import { GRAY } from '../../../constants/colors';
import { SPACING } from '../../../constants';

export default function AccountSettingsScreen() {
  const { currentUser } = useAuth();

  return (
    <SafeAreaView style={styles.root} edges={['top']}>
      <ScrollView contentContainerStyle={styles.scrollContent} showsVerticalScrollIndicator={false}>
        <Text style={styles.title}>Account</Text>

        <View style={styles.card}>
          <Text style={styles.cardLabel}>Profile</Text>
          <InfoRow label="Name" value={currentUser?.name ?? '—'} />
          <InfoRow label="Email" value={currentUser?.email ?? '—'} />
          <InfoRow label="Role" value={currentUser?.role ?? '—'} />
          <InfoRow label="Trust Tier" value={typeof currentUser?.trustTier === 'number' ? String(currentUser.trustTier) : '—'} />
        </View>

        <View style={styles.card}>
          <Text style={styles.cardLabel}>Actions</Text>
          <TouchableOpacity style={styles.actionRow} onPress={() => {}} activeOpacity={0.8}>
            <Text style={styles.actionText}>Edit Profile</Text>
          </TouchableOpacity>
          <TouchableOpacity style={styles.actionRow} onPress={() => {}} activeOpacity={0.8}>
            <Text style={styles.actionText}>Change Password</Text>
          </TouchableOpacity>
        </View>

        <View style={{ height: SPACING[8] }} />
      </ScrollView>
    </SafeAreaView>
  );
}

function InfoRow({ label, value }: { label: string; value: string }) {
  return (
    <View style={styles.infoRow}>
      <Text style={styles.infoLabel}>{label}</Text>
      <Text style={styles.infoValue}>{value}</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  root: {
    flex: 1,
    backgroundColor: GRAY[50],
  },
  scrollContent: {
    paddingHorizontal: SPACING[4],
    paddingTop: SPACING[3],
    paddingBottom: 32,
  },
  title: {
    fontSize: 22,
    fontWeight: '900',
    color: GRAY[900],
    marginBottom: SPACING[3],
  },
  card: {
    backgroundColor: '#fff',
    borderRadius: 16,
    borderWidth: 1,
    borderColor: GRAY[200],
    padding: SPACING[4],
    marginBottom: SPACING[4],
  },
  cardLabel: {
    color: GRAY[600],
    fontSize: 13,
    fontWeight: '900',
    marginBottom: SPACING[2],
  },
  infoRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingVertical: SPACING[2],
    borderTopWidth: 1,
    borderTopColor: GRAY[200],
  },
  infoLabel: {
    color: GRAY[600],
    fontSize: 13,
    fontWeight: '700',
  },
  infoValue: {
    color: GRAY[900],
    fontSize: 13,
    fontWeight: '800',
    maxWidth: '60%',
    textAlign: 'right',
  },
  actionRow: {
    paddingVertical: SPACING[2],
    borderTopWidth: 1,
    borderTopColor: GRAY[200],
  },
  actionText: {
    fontSize: 14,
    fontWeight: '900',
    color: GRAY[900],
  },
});
