import React from 'react';
import { View, Text, StyleSheet, TouchableOpacity } from 'react-native';
import { NEUTRAL, SPACING, FONT_SIZE, FONT_WEIGHT, RADIUS } from '../../constants';

export function NetworkErrorScreen() {
  const handleRetry = () => {
    console.log('Retry button pressed');
    // In real app, would retry network request
  };

  return (
    <View style={styles.container}>
      <View style={styles.content}>
        <Text style={styles.icon}>📡</Text>
        <Text style={styles.title}>Connection Error</Text>
        <Text style={styles.message}>
          We couldn't connect to the server. Please check your internet connection and try again.
        </Text>
        <TouchableOpacity style={styles.retryButton} onPress={handleRetry}>
          <Text style={styles.retryButtonText}>Retry</Text>
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
  retryButton: {
    paddingVertical: SPACING[3],
    paddingHorizontal: SPACING[6],
    backgroundColor: '#3B82F6',
    borderRadius: RADIUS.md,
  },
  retryButtonText: {
    color: NEUTRAL.TEXT_INVERSE,
    fontSize: FONT_SIZE.lg,
    fontWeight: FONT_WEIGHT.semibold,
  },
});
