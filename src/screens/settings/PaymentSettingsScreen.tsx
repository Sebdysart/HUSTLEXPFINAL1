import React from 'react';
import { View, Text, StyleSheet, ScrollView, TouchableOpacity } from 'react-native';
import { NEUTRAL, SPACING, FONT_SIZE, FONT_WEIGHT, RADIUS } from '../../constants';

export function PaymentSettingsScreen() {
  // Stub data
  const balance = 125.50;
  const pendingEarnings = 45.00;
  const paymentMethods = [
    { id: '1', type: 'Bank Account', last4: '1234', isDefault: true },
    { id: '2', type: 'Debit Card', last4: '5678', isDefault: false },
  ];

  const handleAddPaymentMethod = () => {
    console.log('Add payment method button pressed');
    // In real app, would navigate to add payment method screen
    // USER MUST ENTER DETAILS THEMSELVES - no auto-fill
  };

  const handleWithdraw = () => {
    console.log('Withdraw button pressed');
    // In real app, would navigate to withdrawal screen
  };

  return (
    <ScrollView style={styles.container} contentContainerStyle={styles.contentContainer}>
      <Text style={styles.title}>Payment Settings</Text>

      <View style={styles.balanceCard}>
        <Text style={styles.balanceLabel}>Current Balance</Text>
        <Text style={styles.balanceAmount}>${balance.toFixed(2)}</Text>
        <Text style={styles.pendingText}>Pending: ${pendingEarnings.toFixed(2)}</Text>
      </View>

      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Payment Methods</Text>
        {paymentMethods.map((method) => (
          <View key={method.id} style={styles.paymentMethodCard}>
            <View style={styles.paymentMethodInfo}>
              <Text style={styles.paymentMethodType}>{method.type}</Text>
              <Text style={styles.paymentMethodDetails}>•••• {method.last4}</Text>
              {method.isDefault && (
                <Text style={styles.defaultBadge}>Default</Text>
              )}
            </View>
          </View>
        ))}
        <TouchableOpacity style={styles.addButton} onPress={handleAddPaymentMethod}>
          <Text style={styles.addButtonText}>+ Add Payment Method</Text>
        </TouchableOpacity>
      </View>

      <TouchableOpacity style={styles.withdrawButton} onPress={handleWithdraw}>
        <Text style={styles.withdrawButtonText}>Withdraw Funds</Text>
      </TouchableOpacity>
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: NEUTRAL.BACKGROUND,
  },
  contentContainer: {
    padding: SPACING[4],
  },
  title: {
    fontSize: FONT_SIZE['2xl'],
    fontWeight: FONT_WEIGHT.bold,
    color: NEUTRAL.TEXT,
    marginBottom: SPACING[6],
  },
  balanceCard: {
    backgroundColor: '#D1FAE5',
    padding: SPACING[6],
    borderRadius: RADIUS.lg,
    alignItems: 'center',
    marginBottom: SPACING[6],
    borderWidth: 1,
    borderColor: '#10B981',
  },
  balanceLabel: {
    fontSize: FONT_SIZE.base,
    color: NEUTRAL.TEXT_SECONDARY,
    marginBottom: SPACING[1],
  },
  balanceAmount: {
    fontSize: FONT_SIZE['4xl'],
    fontWeight: FONT_WEIGHT.bold,
    color: NEUTRAL.TEXT,
    marginBottom: SPACING[1],
  },
  pendingText: {
    fontSize: FONT_SIZE.sm,
    color: NEUTRAL.TEXT_SECONDARY,
  },
  section: {
    marginBottom: SPACING[6],
  },
  sectionTitle: {
    fontSize: FONT_SIZE.lg,
    fontWeight: FONT_WEIGHT.semibold,
    color: NEUTRAL.TEXT,
    marginBottom: SPACING[3],
  },
  paymentMethodCard: {
    padding: SPACING[4],
    backgroundColor: NEUTRAL.BACKGROUND_SECONDARY,
    borderRadius: RADIUS.md,
    marginBottom: SPACING[2],
  },
  paymentMethodInfo: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: SPACING[2],
  },
  paymentMethodType: {
    fontSize: FONT_SIZE.base,
    fontWeight: FONT_WEIGHT.semibold,
    color: NEUTRAL.TEXT,
  },
  paymentMethodDetails: {
    fontSize: FONT_SIZE.base,
    color: NEUTRAL.TEXT_SECONDARY,
  },
  defaultBadge: {
    fontSize: FONT_SIZE.xs,
    color: '#10B981',
    backgroundColor: '#D1FAE5',
    paddingHorizontal: SPACING[2],
    paddingVertical: SPACING[1],
    borderRadius: RADIUS.sm,
  },
  addButton: {
    padding: SPACING[3],
    backgroundColor: NEUTRAL.BACKGROUND_SECONDARY,
    borderRadius: RADIUS.md,
    alignItems: 'center',
    borderWidth: 1,
    borderColor: NEUTRAL.BORDER,
    borderStyle: 'dashed',
    marginTop: SPACING[2],
  },
  addButtonText: {
    fontSize: FONT_SIZE.base,
    color: NEUTRAL.TEXT_SECONDARY,
  },
  withdrawButton: {
    width: '100%',
    padding: SPACING[3],
    backgroundColor: '#10B981',
    borderRadius: RADIUS.md,
    alignItems: 'center',
  },
  withdrawButtonText: {
    color: NEUTRAL.TEXT_INVERSE,
    fontSize: FONT_SIZE.lg,
    fontWeight: FONT_WEIGHT.semibold,
  },
});
