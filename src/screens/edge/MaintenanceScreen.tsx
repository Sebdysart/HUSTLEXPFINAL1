import React from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { NEUTRAL, SPACING, FONT_SIZE, FONT_WEIGHT } from '../../constants';

export function MaintenanceScreen() {
  return (
    <View style={styles.container}>
      <View style={styles.content}>
        <Text style={styles.icon}>🔧</Text>
        <Text style={styles.title}>Under Maintenance</Text>
        <Text style={styles.message}>
          HustleXP is currently undergoing maintenance. We'll be back shortly.
        </Text>
        <Text style={styles.estimatedTime}>
          Estimated time: 30 minutes
        </Text>
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
    marginBottom: SPACING[2],
  },
  estimatedTime: {
    fontSize: FONT_SIZE.sm,
    color: NEUTRAL.TEXT_TERTIARY,
    textAlign: 'center',
  },
});
