import React from 'react';
import { View, Text, StyleSheet, TouchableOpacity, Linking } from 'react-native';
import { NEUTRAL, SPACING, FONT_SIZE, FONT_WEIGHT, RADIUS } from '../../constants';

export function ForceUpdateScreen() {
  const handleUpdate = () => {
    console.log('Update button pressed');
    // In real app, would open App Store / Play Store
    Linking.openURL('https://apps.apple.com/app/hustlexp');
  };

  return (
    <View style={styles.container}>
      <View style={styles.content}>
        <Text style={styles.icon}>⬆️</Text>
        <Text style={styles.title}>Update Required</Text>
        <Text style={styles.message}>
          A new version of HustleXP is available. Please update to continue using the app.
        </Text>
        <TouchableOpacity style={styles.updateButton} onPress={handleUpdate}>
          <Text style={styles.updateButtonText}>Update Now</Text>
        </TouchableOpacity>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: NEUTRAL.BACKGROUND,
    justifyContent: 'center',
    alignItems: 'center',
    padding: SPACING[4],
  },
  content: {
    alignItems: 'center',
    maxWidth: 300,
  },
  icon: {
    fontSize: FONT_SIZE['4xl'],
    marginBottom: SPACING[4],
  },
  title: {
    fontSize: FONT_SIZE['2xl'],
    fontWeight: FONT_WEIGHT.bold,
    color: NEUTRAL.TEXT,
    marginBottom: SPACING[3],
    textAlign: 'center',
  },
  message: {
    fontSize: FONT_SIZE.base,
    color: NEUTRAL.TEXT_SECONDARY,
    textAlign: 'center',
    marginBottom: SPACING[6],
  },
  updateButton: {
    paddingVertical: SPACING[3],
    paddingHorizontal: SPACING[6],
    backgroundColor: '#10B981',
    borderRadius: RADIUS.md,
  },
  updateButtonText: {
    color: NEUTRAL.TEXT_INVERSE,
    fontSize: FONT_SIZE.lg,
    fontWeight: FONT_WEIGHT.semibold,
  },
});
