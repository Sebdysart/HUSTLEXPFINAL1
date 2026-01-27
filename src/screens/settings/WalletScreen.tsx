/**
 * WalletScreen - Payment methods and balance
 * 
 * Archetype: Interrupt
 * Emotion: "The system has this under control"
 * - Balance prominent
 * - Transaction history clean
 * - Add/withdraw obvious
 * - Security feels solid
 * - Calm, trustworthy, professional
 */

import React, { useState } from 'react';
import { View, StyleSheet, ScrollView, Alert } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { useNavigation } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import type { RootStackParamList } from '../../navigation/types';

import { HScreen, HCard, HText, HButton } from '../../components/atoms';
import { MoneyDisplay } from '../../components';
import { hustleColors, hustleSpacing, hustleRadii } from '../../theme/hustle-tokens';

type NavigationProp = NativeStackNavigationProp<RootStackParamList>;

interface Transaction {
  id: string;
  title: string;
  amount: number;
  type: 'earned' | 'withdrawn' | 'pending';
  date: string;
}

const MOCK_TRANSACTIONS: Transaction[] = [
  { id: '1', title: 'Moving help', amount: 90, type: 'earned', date: 'Jan 20' },
  { id: '2', title: 'Withdrawal to Chase', amount: 200, type: 'withdrawn', date: 'Jan 19' },
  { id: '3', title: 'Furniture assembly', amount: 65, type: 'earned', date: 'Jan 18' },
  { id: '4', title: 'Yard work', amount: 45, type: 'earned', date: 'Jan 17' },
];

export function WalletScreen() {
  const insets = useSafeAreaInsets();
  const navigation = useNavigation<NavigationProp>();
  const [balance] = useState(347.50);
  const [pending] = useState(150);

  const handleBack = () => navigation.goBack();
  
  const handleWithdraw = () => {
    Alert.alert(
      'Withdraw Funds',
      `Transfer $${balance.toFixed(2)} to your default payment method?`,
      [
        { text: 'Cancel', style: 'cancel' },
        { text: 'Confirm', onPress: () => Alert.alert('On its way', 'Your withdrawal has been initiated.') },
      ]
    );
  };

  const handleAddFunds = () => {
    Alert.alert('Add Funds', 'Add funds to your account for posting tasks.');
  };

  const handleAddPayment = () => {
    Alert.alert('Add Payment Method', 'Connect your bank or card to receive payments securely.');
  };

  return (
    <HScreen ambient={false}>
      {/* Header */}
      <View style={[styles.header, { paddingTop: insets.top + hustleSpacing.sm }]}>
        <HButton variant="ghost" size="sm" onPress={handleBack}>
          ← Back
        </HButton>
        <HText variant="title2" color="primary">Your Wallet</HText>
        <View style={styles.headerSpacer} />
      </View>

      <ScrollView 
        style={styles.scrollContainer}
        contentContainerStyle={styles.scroll}
      >
        {/* Balance Card - prominent, secure feeling */}
        <HCard variant="elevated" padding="lg" style={styles.balanceCard}>
          <HText variant="footnote" color="secondary">Available Balance</HText>
          <View style={styles.balanceDisplay}>
            <MoneyDisplay amount={balance} size="lg" />
          </View>
          <View style={styles.balanceActions}>
            <HButton 
              variant="primary" 
              size="md" 
              onPress={handleWithdraw} 
              style={styles.balanceBtn}
            >
              Withdraw
            </HButton>
            <View style={styles.spacer} />
            <HButton 
              variant="secondary" 
              size="md" 
              onPress={handleAddFunds} 
              style={styles.balanceBtn}
            >
              Add Funds
            </HButton>
          </View>
        </HCard>

        {/* Pending balance */}
        <HCard variant="default" padding="md" style={styles.pendingCard}>
          <View style={styles.pendingRow}>
            <View style={styles.pendingInfo}>
              <HText variant="body" color="secondary">Pending</HText>
              <HText variant="caption" color="tertiary">
                Released after task completion
              </HText>
            </View>
            <MoneyDisplay amount={pending} size="sm" />
          </View>
        </HCard>

        {/* Payment Methods - security feels solid */}
        <HText variant="footnote" color="tertiary" style={styles.sectionLabel}>
          PAYMENT METHODS
        </HText>
        
        <PaymentMethod 
          type="bank" 
          name="Chase ••••4521" 
          isDefault 
        />
        <PaymentMethod 
          type="card" 
          name="Visa ••••8834" 
          isDefault={false} 
        />

        <HButton 
          variant="ghost" 
          size="sm" 
          onPress={handleAddPayment}
          style={styles.addPaymentBtn}
        >
          + Add Payment Method
        </HButton>

        {/* Transaction History - clean, organized */}
        <View style={styles.sectionHeader}>
          <HText variant="footnote" color="tertiary">RECENT ACTIVITY</HText>
          <HButton variant="ghost" size="sm" onPress={() => {}}>
            See all
          </HButton>
        </View>

        {MOCK_TRANSACTIONS.map(tx => (
          <TransactionRow key={tx.id} transaction={tx} />
        ))}

        {/* Security note */}
        <HCard variant="default" padding="md" style={styles.securityNote}>
          <View style={styles.securityRow}>
            <HText variant="body">🔒</HText>
            <HText variant="caption" color="secondary" style={styles.securityText}>
              Your payment information is encrypted and secure. We never store your full card or bank details.
            </HText>
          </View>
        </HCard>
      </ScrollView>
    </HScreen>
  );
}

interface PaymentMethodProps {
  type: 'bank' | 'card';
  name: string;
  isDefault: boolean;
}

function PaymentMethod({ type, name, isDefault }: PaymentMethodProps) {
  return (
    <HCard variant="default" padding="md" style={styles.paymentCard}>
      <View style={styles.paymentRow}>
        <View style={styles.paymentIcon}>
          <HText variant="title3">{type === 'bank' ? '🏦' : '💳'}</HText>
        </View>
        <View style={styles.paymentInfo}>
          <HText variant="body" color="primary">{name}</HText>
          {isDefault && (
            <HText variant="caption" color="tertiary">Default</HText>
          )}
        </View>
        <HButton variant="ghost" size="sm" onPress={() => {}}>
          Edit
        </HButton>
      </View>
    </HCard>
  );
}

interface TransactionRowProps {
  transaction: Transaction;
}

function TransactionRow({ transaction }: TransactionRowProps) {
  const { title, amount, type, date } = transaction;
  
  const getAmountDisplay = () => {
    switch (type) {
      case 'earned':
        return { prefix: '+', color: 'success' as const };
      case 'withdrawn':
        return { prefix: '−', color: 'secondary' as const };
      case 'pending':
        return { prefix: '', color: 'tertiary' as const };
    }
  };
  
  const { prefix, color } = getAmountDisplay();

  return (
    <HCard variant="default" padding="md" style={styles.transactionCard}>
      <View style={styles.transactionRow}>
        <View style={styles.transactionInfo}>
          <HText variant="body" color="primary">{title}</HText>
          <HText variant="caption" color="tertiary">{date}</HText>
        </View>
        <HText variant="headline" color={color}>
          {prefix}${amount}
        </HText>
      </View>
    </HCard>
  );
}

const styles = StyleSheet.create({
  header: { 
    flexDirection: 'row', 
    justifyContent: 'space-between', 
    alignItems: 'center',
    paddingHorizontal: hustleSpacing.lg,
    paddingBottom: hustleSpacing.md,
  },
  headerSpacer: { width: 60 },
  scrollContainer: {
    flex: 1,
  },
  scroll: { 
    padding: hustleSpacing.lg,
    paddingTop: 0,
    paddingBottom: hustleSpacing['3xl'],
  },
  balanceCard: {
    marginBottom: hustleSpacing.md,
  },
  balanceDisplay: {
    marginVertical: hustleSpacing.md,
  },
  balanceActions: { 
    flexDirection: 'row',
    marginTop: hustleSpacing.sm,
  },
  balanceBtn: { 
    flex: 1,
  },
  spacer: { 
    width: hustleSpacing.md,
  },
  pendingCard: {
    marginBottom: hustleSpacing.xl,
  },
  pendingRow: { 
    flexDirection: 'row', 
    justifyContent: 'space-between', 
    alignItems: 'center',
  },
  pendingInfo: {
    flex: 1,
  },
  sectionLabel: {
    marginBottom: hustleSpacing.sm,
    paddingLeft: hustleSpacing.sm,
  },
  paymentCard: {
    marginBottom: hustleSpacing.sm,
  },
  paymentRow: { 
    flexDirection: 'row', 
    alignItems: 'center',
  },
  paymentIcon: {
    width: 40,
    height: 40,
    borderRadius: 20,
    backgroundColor: hustleColors.dark.surface,
    justifyContent: 'center',
    alignItems: 'center',
  },
  paymentInfo: { 
    flex: 1, 
    marginLeft: hustleSpacing.md,
  },
  addPaymentBtn: {
    marginTop: hustleSpacing.sm,
    marginBottom: hustleSpacing.xl,
  },
  sectionHeader: { 
    flexDirection: 'row', 
    justifyContent: 'space-between', 
    alignItems: 'center',
    marginBottom: hustleSpacing.sm,
    paddingLeft: hustleSpacing.sm,
  },
  transactionCard: { 
    marginBottom: hustleSpacing.sm,
  },
  transactionRow: { 
    flexDirection: 'row', 
    justifyContent: 'space-between', 
    alignItems: 'center',
  },
  transactionInfo: {
    flex: 1,
  },
  securityNote: {
    marginTop: hustleSpacing.xl,
  },
  securityRow: {
    flexDirection: 'row',
    alignItems: 'flex-start',
  },
  securityText: {
    flex: 1,
    marginLeft: hustleSpacing.sm,
  },
});

export default WalletScreen;
