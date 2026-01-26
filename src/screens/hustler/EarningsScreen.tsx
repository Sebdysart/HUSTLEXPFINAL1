/**
 * EarningsScreen - Earnings dashboard
 */

import React, { useState } from 'react';
import { View, StyleSheet, ScrollView, TouchableOpacity } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { Text, Spacing, Card, MoneyDisplay, Button } from '../../components';
import { theme } from '../../theme';

const PERIODS = ['Week', 'Month', 'Year', 'All'];

export function EarningsScreen() {
  const insets = useSafeAreaInsets();
  const [period, setPeriod] = useState('Week');

  return (
    <View style={[styles.container, { paddingTop: insets.top }]}>
      <ScrollView contentContainerStyle={styles.scroll}>
        <Text variant="title1" color="primary">Earnings</Text>
        
        <Spacing size={16} />

        {/* Period Selector */}
        <View style={styles.periods}>
          {PERIODS.map(p => (
            <TouchableOpacity
              key={p}
              style={[styles.periodBtn, period === p && styles.periodBtnActive]}
              onPress={() => setPeriod(p)}
            >
              <Text variant="caption" color={period === p ? 'inverse' : 'primary'}>{p}</Text>
            </TouchableOpacity>
          ))}
        </View>

        <Spacing size={20} />

        {/* Total Earnings */}
        <Card variant="elevated" padding="lg">
          <Text variant="footnote" color="secondary">Total Earnings ({period})</Text>
          <Spacing size={4} />
          <MoneyDisplay amount={847.50} size="lg" />
          <Spacing size={16} />
          <View style={styles.statsRow}>
            <StatBox label="Tasks" value="12" />
            <StatBox label="Hours" value="28" />
            <StatBox label="Avg/Task" value="$71" />
          </View>
        </Card>

        <Spacing size={20} />

        {/* Balance */}
        <Card variant="default" padding="md">
          <View style={styles.balanceRow}>
            <View>
              <Text variant="footnote" color="secondary">Available Balance</Text>
              <MoneyDisplay amount={347.50} size="md" />
            </View>
            <Button variant="primary" size="sm" onPress={() => {}}>Withdraw</Button>
          </View>
          <Spacing size={8} />
          <Text variant="caption" color="tertiary">$500.00 pending approval</Text>
        </Card>

        <Spacing size={20} />

        {/* Recent Transactions */}
        <Text variant="headline" color="primary">Recent Transactions</Text>
        <Spacing size={12} />
        <TransactionRow title="Moving help" amount={90} date="Jan 20" type="earned" />
        <TransactionRow title="Withdrawal" amount={200} date="Jan 19" type="withdrawn" />
        <TransactionRow title="Furniture assembly" amount={65} date="Jan 18" type="earned" />
        <TransactionRow title="Dog walking" amount={35} date="Jan 17" type="earned" />
      </ScrollView>
    </View>
  );
}

function StatBox({ label, value }: { label: string; value: string }) {
  return (
    <View style={styles.statBox}>
      <Text variant="title2" color="primary">{value}</Text>
      <Text variant="caption" color="secondary">{label}</Text>
    </View>
  );
}

function TransactionRow({ title, amount, date, type }: { title: string; amount: number; date: string; type: 'earned' | 'withdrawn' }) {
  return (
    <Card variant="default" padding="sm" style={styles.transaction}>
      <View style={styles.transactionInfo}>
        <Text variant="body" color="primary">{title}</Text>
        <Text variant="caption" color="secondary">{date}</Text>
      </View>
      <Text variant="headline" color={type === 'earned' ? 'success' : 'secondary'}>
        {type === 'earned' ? '+' : '-'}${amount}
      </Text>
    </Card>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: theme.colors.surface.primary },
  scroll: { padding: theme.spacing[4] },
  periods: { flexDirection: 'row', gap: theme.spacing[2] },
  periodBtn: { paddingVertical: theme.spacing[2], paddingHorizontal: theme.spacing[4], backgroundColor: theme.colors.surface.secondary, borderRadius: theme.radii.full },
  periodBtnActive: { backgroundColor: theme.colors.brand.primary },
  statsRow: { flexDirection: 'row', justifyContent: 'space-around' },
  statBox: { alignItems: 'center' },
  balanceRow: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center' },
  transaction: { marginBottom: theme.spacing[2], flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center' },
  transactionInfo: { flex: 1 },
});

export default EarningsScreen;
