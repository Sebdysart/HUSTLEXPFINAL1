/**
 * EarningsScreen - Progress Archetype
 * 
 * EMOTIONAL CONTRACT: "Value is accumulating"
 * - Hero number at top
 * - "You've earned" not "Total earnings"
 * - Quiet power, not dashboard overload
 */

import React, { useState } from 'react';
import { View, StyleSheet, ScrollView, TouchableOpacity } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { useNavigation } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import type { RootStackParamList } from '../../navigation/types';

import { HScreen, HText, HCard, HButton, HMoney, HStatCard, HBadge } from '../../components/atoms';
import { hustleColors, hustleSpacing } from '../../theme/hustle-tokens';

type NavigationProp = NativeStackNavigationProp<RootStackParamList>;

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
  const [period, setPeriod] = useState('Week');
  
  const data = EARNINGS_DATA[period];

  const handleWithdraw = () => {
    navigation.navigate('Wallet');
  };

  return (
    <HScreen ambient>
      <ScrollView 
        contentContainerStyle={[styles.scroll, { paddingTop: insets.top + hustleSpacing.lg }]}
        showsVerticalScrollIndicator={false}
      >
        {/* Hero Earnings - "You've earned" */}
        <View style={styles.hero}>
          <HMoney 
            amount={data.total} 
            size="hero" 
            label={`You've earned this ${period.toLowerCase()}`}
            glow
            align="center"
          />
        </View>

        {/* Period Selector - Subtle */}
        <View style={styles.periods}>
          {PERIODS.map(p => (
            <TouchableOpacity
              key={p}
              style={[styles.periodBtn, period === p && styles.periodBtnActive]}
              onPress={() => setPeriod(p)}
            >
              <HText variant="caption" color={period === p ? 'primary' : 'muted'}>
                {p}
              </HText>
            </TouchableOpacity>
          ))}
        </View>

        {/* Stats - Clean, not overloaded */}
        <View style={styles.statsRow}>
          <HStatCard 
            label="Tasks" 
            value={String(data.tasks)} 
            color={hustleColors.text.primary}
          />
          <HStatCard 
            label="Hours" 
            value={String(data.hours)} 
            color={hustleColors.text.primary}
          />
          <HStatCard 
            label="Per task" 
            value={`$${Math.round(data.total / data.tasks)}`} 
            color={hustleColors.money.primary}
          />
        </View>

        {/* Balance Card */}
        <HCard variant="elevated" padding="lg">
          <View style={styles.balanceRow}>
            <View>
              <HText variant="footnote" color="secondary">Ready to withdraw</HText>
              <HMoney amount={347.50} size="md" />
            </View>
            <HButton variant="primary" size="sm" onPress={handleWithdraw}>
              Withdraw
            </HButton>
          </View>
          <View style={styles.pendingRow}>
            <HBadge variant="default" size="sm">
              $500.00 pending
            </HBadge>
          </View>
        </HCard>

        {/* Recent Activity - Expandable hint */}
        <View style={styles.section}>
          <HText variant="headline" color="primary">Recent Activity</HText>
        </View>

        <TransactionCard 
          title="Moving help" 
          amount={90} 
          date="Jan 20" 
          type="earned" 
        />
        <TransactionCard 
          title="Withdrawal" 
          amount={200} 
          date="Jan 19" 
          type="withdrawn" 
        />
        <TransactionCard 
          title="Furniture assembly" 
          amount={65} 
          date="Jan 18" 
          type="earned" 
        />
        <TransactionCard 
          title="Dog walking" 
          amount={35} 
          date="Jan 17" 
          type="earned" 
        />
      </ScrollView>
    </HScreen>
  );
}

interface TransactionCardProps {
  title: string;
  amount: number;
  date: string;
  type: 'earned' | 'withdrawn';
}

function TransactionCard({ title, amount, date, type }: TransactionCardProps) {
  return (
    <HCard variant="default" padding="md" style={styles.transaction}>
      <View style={styles.transactionInfo}>
        <HText variant="body" color="primary">{title}</HText>
        <HText variant="caption" color="tertiary">{date}</HText>
      </View>
      <HText 
        variant="headline" 
        color={type === 'earned' ? hustleColors.money.primary : hustleColors.text.secondary}
        bold
      >
        {type === 'earned' ? '+' : '-'}${amount}
      </HText>
    </HCard>
  );
}

const styles = StyleSheet.create({
  scroll: { 
    padding: hustleSpacing.lg,
    paddingBottom: hustleSpacing['4xl'],
  },
  hero: {
    alignItems: 'center',
    marginBottom: hustleSpacing['2xl'],
  },
  periods: { 
    flexDirection: 'row', 
    justifyContent: 'center',
    gap: hustleSpacing.sm,
    marginBottom: hustleSpacing.xl,
  },
  periodBtn: { 
    paddingVertical: hustleSpacing.sm, 
    paddingHorizontal: hustleSpacing.lg, 
    backgroundColor: hustleColors.glass.subtle, 
    borderRadius: 999,
  },
  periodBtnActive: { 
    backgroundColor: hustleColors.purple.core,
  },
  statsRow: { 
    flexDirection: 'row', 
    justifyContent: 'space-between',
    gap: hustleSpacing.md,
    marginBottom: hustleSpacing.xl,
  },
  balanceRow: { 
    flexDirection: 'row', 
    justifyContent: 'space-between', 
    alignItems: 'center',
  },
  pendingRow: {
    marginTop: hustleSpacing.md,
  },
  section: {
    marginTop: hustleSpacing.xl,
    marginBottom: hustleSpacing.md,
  },
  transaction: { 
    marginBottom: hustleSpacing.sm, 
    flexDirection: 'row', 
    justifyContent: 'space-between', 
    alignItems: 'center',
  },
  transactionInfo: { 
    flex: 1,
  },
});

export default EarningsScreen;
