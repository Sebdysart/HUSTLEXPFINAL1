/**
 * EarningsScreen - Earnings dashboard
 */

import React, { useState } from 'react';
import { View, StyleSheet, ScrollView, TouchableOpacity } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { useNavigation } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import type { RootStackParamList } from '../../navigation/types';

type NavigationProp = NativeStackNavigationProp<RootStackParamList>;
import { Text, Spacing, Card, MoneyDisplay, Button } from '../../components';
import { theme } from '../../theme';
import { useAuthStore, useTaskStore } from '../../store';

const PERIODS = ['Week', 'Month', 'Year', 'All'];

// Mock earnings data by period
const EARNINGS_DATA: Record<string, { total: number; tasks: number; hours: number }> = {
  Week: { total: 347.50, tasks: 5, hours: 12 },
  Month: { total: 1247.50, tasks: 18, hours: 42 },
  Year: { total: 8450.00, tasks: 124, hours: 310 },
  All: { total: 12847.50, tasks: 186, hours: 465 },
};

export function EarningsScreen() {
  const insets = useSafeAreaInsets();
  const navigation = useNavigation<NavigationProp>();
  const { user } = useAuthStore();
  const { tasks } = useTaskStore();
  const [period, setPeriod] = useState('Week');
  
  const data = EARNINGS_DATA[period];
  const completedTasks = tasks.filter(t => t.status === 'completed');

  const handleWithdraw = () => {
    navigation.navigate('Wallet');
  };

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
          <Text variant="footnote" color="secondary">{`Total Earnings (${period})`}</Text>
          <Spacing size={4} />
          <MoneyDisplay amount={data.total} size="lg" />
          <Spacing size={16} />
          <View style={styles.statsRow}>
            <StatBox label="Tasks" value={String(data.tasks)} />
            <StatBox label="Hours" value={String(data.hours)} />
            <StatBox label="Avg/Task" value={`$${Math.round(data.total / data.tasks)}`} />
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
            <Button variant="primary" size="sm" onPress={handleWithdraw}>Withdraw</Button>
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
