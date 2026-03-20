import React from 'react';
import { ScrollView, StyleSheet, Text, TouchableOpacity, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { GRAY, MONEY, STATUS, BRAND } from '../../../constants/colors';
import { SPACING } from '../../../constants';

export default function PaymentSettingsScreen() {
  return (
    <SafeAreaView style={styles.root} edges={['top']}>
      <ScrollView contentContainerStyle={styles.scrollContent} showsVerticalScrollIndicator={false}>
        <Text style={styles.title}>Payments</Text>

        <View style={styles.balanceCard}>
          <Text style={styles.balanceLabel}>Available Balance</Text>
          <Text style={styles.balanceValue}>$325.00</Text>

          <View style={styles.divider} />

          <View style={styles.balanceRow}>
            <View style={styles.balanceMini}>
              <Text style={styles.miniLabel}>Pending</Text>
              <Text style={styles.miniValue}>$50.00</Text>
            </View>
            <View style={styles.balanceMini}>
              <Text style={styles.miniLabel}>This Month</Text>
              <Text style={styles.miniValue}>$475.00</Text>
            </View>
          </View>

          <TouchableOpacity style={styles.primaryButton} onPress={() => {}} activeOpacity={0.85}>
            <Text style={styles.primaryButtonText}>Cash Out</Text>
          </TouchableOpacity>
        </View>

        <View style={styles.section}>
          <SectionTitle title="Payment Methods" />
          <TouchableOpacity style={styles.row} onPress={() => {}} activeOpacity={0.85}>
            <Text style={styles.rowTitle}>Add Payment Method</Text>
            <Text style={styles.rowSubtitle}>Add a card to pay for tasks</Text>
          </TouchableOpacity>
        </View>

        <View style={styles.section}>
          <SectionTitle title="Payout" />
          <TouchableOpacity style={styles.row} onPress={() => {}} activeOpacity={0.85}>
            <Text style={styles.rowTitle}>Add Bank Account</Text>
            <Text style={styles.rowSubtitle}>Connect a bank to receive payouts</Text>
          </TouchableOpacity>
        </View>

        <View style={styles.section}>
          <SectionTitle title="History" />
          <TouchableOpacity style={styles.row} onPress={() => {}} activeOpacity={0.85}>
            <Text style={styles.rowTitle}>Transaction History</Text>
            <Text style={styles.rowSubtitle}>View all payments and payouts</Text>
          </TouchableOpacity>
        </View>

        <View style={styles.note}>
          <Text style={styles.noteText}>Your payment information is encrypted and securely stored.</Text>
        </View>

        <View style={{ height: SPACING[8] }} />
      </ScrollView>
    </SafeAreaView>
  );
}

function SectionTitle({ title }: { title: string }) {
  return <Text style={styles.sectionTitle}>{title}</Text>;
}

const styles = StyleSheet.create({
  root: { flex: 1, backgroundColor: GRAY[50] },
  scrollContent: { paddingHorizontal: SPACING[4], paddingTop: SPACING[3], paddingBottom: 32 },
  title: { fontSize: 22, fontWeight: '900', color: GRAY[900], marginBottom: SPACING[4] },
  balanceCard: {
    backgroundColor: '#fff',
    borderRadius: 16,
    borderWidth: 1,
    borderColor: GRAY[200],
    padding: SPACING[4],
    marginBottom: SPACING[4],
  },
  balanceLabel: { color: GRAY[600], fontSize: 13, fontWeight: '800' },
  balanceValue: { color: MONEY.POSITIVE, fontSize: 26, fontWeight: '900', marginTop: 6 },
  divider: { height: 1, backgroundColor: GRAY[200], marginVertical: SPACING[3] },
  balanceRow: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center' },
  balanceMini: { flex: 1 },
  miniLabel: { color: GRAY[600], fontSize: 12, fontWeight: '800' },
  miniValue: { color: GRAY[900], fontSize: 18, fontWeight: '900', marginTop: 4 },
  primaryButton: { marginTop: SPACING[3], height: 48, borderRadius: 14, backgroundColor: BRAND.PRIMARY, alignItems: 'center', justifyContent: 'center' },
  primaryButtonText: { color: '#fff', fontWeight: '900', fontSize: 16 },
  section: { backgroundColor: '#fff', borderRadius: 16, borderWidth: 1, borderColor: GRAY[200], padding: SPACING[4], marginBottom: SPACING[4] },
  sectionTitle: { color: GRAY[600], fontSize: 13, fontWeight: '900', marginBottom: SPACING[3] },
  row: { paddingVertical: SPACING[2] },
  rowTitle: { fontSize: 14, fontWeight: '900', color: GRAY[900] },
  rowSubtitle: { marginTop: 4, fontSize: 12, color: GRAY[600], fontWeight: '600' },
  note: { padding: SPACING[4], borderRadius: 16, backgroundColor: '#fff', borderWidth: 1, borderColor: GRAY[200], marginBottom: SPACING[4] },
  noteText: { color: GRAY[600], fontSize: 12, fontWeight: '700' },
});
