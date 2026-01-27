/**
 * WalletScreen - Payment methods and balance
 */

import React from 'react';
import { View, StyleSheet, ScrollView } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { useNavigation } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import type { RootStackParamList } from '../../navigation/types';

type NavigationProp = NativeStackNavigationProp<RootStackParamList>;
import { Text, Spacing, Card, Button, MoneyDisplay } from '../../components';
import { theme } from '../../theme';

export function WalletScreen() {
  const insets = useSafeAreaInsets();
  const navigation = useNavigation<NavigationProp>();

  return (
    <View style={[styles.container, { paddingTop: insets.top }]}>
      <ScrollView contentContainerStyle={styles.scroll}>
        <Text variant="title1" color="primary">Wallet</Text>

        <Spacing size={24} />

        {/* Balance Card */}
        <Card variant="elevated" padding="lg">
          <Text variant="footnote" color="secondary">Available Balance</Text>
          <Spacing size={4} />
          <MoneyDisplay amount={347.50} size="lg" />
          <Spacing size={16} />
          <View style={styles.balanceActions}>
            <Button variant="primary" size="md" onPress={() => {}} style={styles.balanceBtn}>
              Withdraw
            </Button>
            <View style={styles.spacer} />
            <Button variant="secondary" size="md" onPress={() => {}} style={styles.balanceBtn}>
              Add Funds
            </Button>
          </View>
        </Card>

        <Spacing size={12} />

        <Card variant="default" padding="sm">
          <View style={styles.pendingRow}>
            <Text variant="body" color="secondary">Pending</Text>
            <MoneyDisplay amount={150} size="sm" />
          </View>
        </Card>

        <Spacing size={24} />

        {/* Payment Methods */}
        <Text variant="headline" color="primary">Payment Methods</Text>
        <Spacing size={12} />

        <PaymentMethod type="bank" name="Chase ••••4521" isDefault />
        <Spacing size={8} />
        <PaymentMethod type="card" name="Visa ••••8834" isDefault={false} />

        <Spacing size={12} />
        <Button variant="ghost" size="sm" onPress={() => {}}>
          + Add Payment Method
        </Button>

        <Spacing size={24} />

        {/* Transaction History */}
        <View style={styles.sectionHeader}>
          <Text variant="headline" color="primary">Recent Activity</Text>
          <Button variant="ghost" size="sm" onPress={() => {}}>See all</Button>
        </View>
        <Spacing size={12} />

        <Transaction title="Moving help" amount={90} type="earned" date="Jan 20" />
        <Transaction title="Withdrawal to Chase" amount={200} type="withdrawn" date="Jan 19" />
        <Transaction title="Furniture assembly" amount={65} type="earned" date="Jan 18" />
      </ScrollView>
    </View>
  );
}

function PaymentMethod({ type, name, isDefault }: { type: 'bank' | 'card'; name: string; isDefault: boolean }) {
  return (
    <Card variant="default" padding="md">
      <View style={styles.paymentRow}>
        <Text variant="title2">{type === 'bank' ? '🏦' : '💳'}</Text>
        <View style={styles.paymentInfo}>
          <Text variant="body" color="primary">{name}</Text>
          {isDefault && <Text variant="caption" color="secondary">Default</Text>}
        </View>
        <Button variant="ghost" size="sm" onPress={() => {}}>Edit</Button>
      </View>
    </Card>
  );
}

function Transaction({ title, amount, type, date }: { title: string; amount: number; type: 'earned' | 'withdrawn'; date: string }) {
  return (
    <Card variant="default" padding="sm" style={styles.transaction}>
      <View style={styles.transactionRow}>
        <View>
          <Text variant="body" color="primary">{title}</Text>
          <Text variant="caption" color="secondary">{date}</Text>
        </View>
        <Text variant="headline" color={type === 'earned' ? 'success' : 'secondary'}>
          {type === 'earned' ? '+' : '-'}${amount}
        </Text>
      </View>
    </Card>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: theme.colors.surface.primary },
  scroll: { padding: theme.spacing[4] },
  balanceActions: { flexDirection: 'row' },
  balanceBtn: { flex: 1 },
  spacer: { width: theme.spacing[3] },
  pendingRow: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center' },
  sectionHeader: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center' },
  paymentRow: { flexDirection: 'row', alignItems: 'center' },
  paymentInfo: { flex: 1, marginLeft: theme.spacing[3] },
  transaction: { marginBottom: theme.spacing[2] },
  transactionRow: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center' },
});

export default WalletScreen;
