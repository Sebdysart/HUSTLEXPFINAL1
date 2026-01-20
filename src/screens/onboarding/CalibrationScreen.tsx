import React from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { NEUTRAL, SPACING, FONT_SIZE } from '../../constants';

export function CalibrationScreen() {

  return (
    <View style={styles.container}>
      <Text style={styles.title}>Trust Calibration</Text>
      <Text style={styles.description}>Answer a few questions to set your initial trust tier</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    padding: SPACING[4],
    backgroundColor: NEUTRAL.BACKGROUND,
  },
  title: {
    fontSize: FONT_SIZE['2xl'],
    fontWeight: '600',
    color: NEUTRAL.TEXT,
    marginBottom: SPACING[4],
  },
  description: {
    fontSize: FONT_SIZE.base,
    color: NEUTRAL.TEXT_SECONDARY,
  },
});
