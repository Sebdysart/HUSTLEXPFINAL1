import React from 'react';
import { View, Text, StyleSheet, ScrollView, TouchableOpacity } from 'react-native';
import { NEUTRAL, SPACING, FONT_SIZE, FONT_WEIGHT, RADIUS } from '../../constants';

export function AccountSettingsScreen() {
  // Stub data
  const user = {
    email: 'user@example.com',
    phone: '+1 (555) 123-4567',
  };

  const handleChangePassword = () => {
    console.log('Change password link pressed');
    // In real app, would navigate to change password screen
  };

  const handleDeleteAccount = () => {
    console.log('Delete account link pressed');
    // In real app, would show confirmation and delete account
  };

  return (
    <ScrollView style={styles.container} contentContainerStyle={styles.contentContainer}>
      <Text style={styles.title}>Account Settings</Text>

      <View style={styles.section}>
        <Text style={styles.label}>Email</Text>
        <Text style={styles.value}>{user.email}</Text>
        <Text style={styles.hint}>Email cannot be changed here. Contact support to change email.</Text>
      </View>

      <View style={styles.section}>
        <Text style={styles.label}>Phone</Text>
        <Text style={styles.value}>{user.phone}</Text>
        <TouchableOpacity>
          <Text style={styles.editLink}>Edit Phone Number</Text>
        </TouchableOpacity>
      </View>

      <View style={styles.section}>
        <TouchableOpacity style={styles.actionButton} onPress={handleChangePassword}>
          <Text style={styles.actionButtonText}>Change Password</Text>
        </TouchableOpacity>
      </View>

      <View style={styles.dangerSection}>
        <Text style={styles.dangerTitle}>Danger Zone</Text>
        <TouchableOpacity style={styles.dangerButton} onPress={handleDeleteAccount}>
          <Text style={styles.dangerButtonText}>Delete Account</Text>
        </TouchableOpacity>
        <Text style={styles.dangerHint}>
          This action cannot be undone. All your data will be permanently deleted.
        </Text>
      </View>
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
  section: {
    marginBottom: SPACING[6],
  },
  label: {
    fontSize: FONT_SIZE.sm,
    fontWeight: FONT_WEIGHT.semibold,
    color: NEUTRAL.TEXT_SECONDARY,
    marginBottom: SPACING[1],
    textTransform: 'uppercase',
  },
  value: {
    fontSize: FONT_SIZE.base,
    color: NEUTRAL.TEXT,
    marginBottom: SPACING[2],
  },
  hint: {
    fontSize: FONT_SIZE.sm,
    color: NEUTRAL.TEXT_TERTIARY,
    fontStyle: 'italic',
  },
  editLink: {
    fontSize: FONT_SIZE.base,
    color: '#3B82F6',
    textDecorationLine: 'underline',
  },
  actionButton: {
    padding: SPACING[3],
    backgroundColor: NEUTRAL.BACKGROUND_SECONDARY,
    borderRadius: RADIUS.md,
    alignItems: 'center',
  },
  actionButtonText: {
    fontSize: FONT_SIZE.base,
    color: NEUTRAL.TEXT,
    fontWeight: FONT_WEIGHT.semibold,
  },
  dangerSection: {
    marginTop: SPACING[8],
    padding: SPACING[4],
    backgroundColor: '#FEE2E2',
    borderRadius: RADIUS.lg,
    borderWidth: 1,
    borderColor: '#EF4444',
  },
  dangerTitle: {
    fontSize: FONT_SIZE.lg,
    fontWeight: FONT_WEIGHT.bold,
    color: '#EF4444',
    marginBottom: SPACING[3],
  },
  dangerButton: {
    padding: SPACING[3],
    backgroundColor: '#EF4444',
    borderRadius: RADIUS.md,
    alignItems: 'center',
    marginBottom: SPACING[2],
  },
  dangerButtonText: {
    color: NEUTRAL.TEXT_INVERSE,
    fontSize: FONT_SIZE.base,
    fontWeight: FONT_WEIGHT.semibold,
  },
  dangerHint: {
    fontSize: FONT_SIZE.sm,
    color: '#991B1B',
  },
});
