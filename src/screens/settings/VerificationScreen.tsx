import React from 'react';
import { View, Text, StyleSheet, ScrollView, TouchableOpacity } from 'react-native';
import { NEUTRAL, SPACING, FONT_SIZE, FONT_WEIGHT, RADIUS } from '../../constants';

export function VerificationScreen() {
  // Stub data
  const verifications = [
    { type: 'Email', status: 'Verified', icon: '✓' },
    { type: 'Phone', status: 'Verified', icon: '✓' },
    { type: 'Identity', status: 'Pending', icon: '⏳' },
    { type: 'Background Check', status: 'Not Started', icon: '○' },
  ];

  const handleVerify = (type: string) => {
    console.log(`Verify ${type} button pressed`);
    // In real app, would start verification process
  };

  return (
    <ScrollView style={styles.container} contentContainerStyle={styles.contentContainer}>
      <Text style={styles.title}>Verification</Text>
      <Text style={styles.subtitle}>
        Complete verifications to unlock more opportunities
      </Text>

      {verifications.map((verification) => (
        <View key={verification.type} style={styles.verificationCard}>
          <View style={styles.verificationHeader}>
            <Text style={styles.verificationIcon}>{verification.icon}</Text>
            <View style={styles.verificationInfo}>
              <Text style={styles.verificationType}>{verification.type}</Text>
              <Text
                style={[
                  styles.verificationStatus,
                  verification.status === 'Verified' && styles.statusVerified,
                  verification.status === 'Pending' && styles.statusPending,
                ]}
              >
                {verification.status}
              </Text>
            </View>
          </View>
          {verification.status !== 'Verified' && (
            <TouchableOpacity
              style={styles.verifyButton}
              onPress={() => handleVerify(verification.type)}
            >
              <Text style={styles.verifyButtonText}>
                {verification.status === 'Not Started' ? 'Start Verification' : 'Check Status'}
              </Text>
            </TouchableOpacity>
          )}
        </View>
      ))}
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
    marginBottom: SPACING[2],
  },
  subtitle: {
    fontSize: FONT_SIZE.base,
    color: NEUTRAL.TEXT_SECONDARY,
    marginBottom: SPACING[6],
  },
  verificationCard: {
    backgroundColor: NEUTRAL.BACKGROUND_SECONDARY,
    padding: SPACING[4],
    borderRadius: RADIUS.lg,
    marginBottom: SPACING[3],
  },
  verificationHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: SPACING[3],
  },
  verificationIcon: {
    fontSize: FONT_SIZE['2xl'],
    marginRight: SPACING[3],
  },
  verificationInfo: {
    flex: 1,
  },
  verificationType: {
    fontSize: FONT_SIZE.lg,
    fontWeight: FONT_WEIGHT.semibold,
    color: NEUTRAL.TEXT,
    marginBottom: SPACING[1],
  },
  verificationStatus: {
    fontSize: FONT_SIZE.sm,
    color: NEUTRAL.TEXT_SECONDARY,
  },
  statusVerified: {
    color: '#10B981',
    fontWeight: FONT_WEIGHT.semibold,
  },
  statusPending: {
    color: '#F59E0B',
    fontWeight: FONT_WEIGHT.semibold,
  },
  verifyButton: {
    padding: SPACING[2],
    backgroundColor: '#3B82F6',
    borderRadius: RADIUS.md,
    alignItems: 'center',
  },
  verifyButtonText: {
    color: NEUTRAL.TEXT_INVERSE,
    fontSize: FONT_SIZE.base,
    fontWeight: FONT_WEIGHT.semibold,
  },
});
