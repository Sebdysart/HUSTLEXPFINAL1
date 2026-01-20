import React from 'react';
import { View, Text, StyleSheet, ScrollView } from 'react-native';
import { NEUTRAL, SPACING, FONT_SIZE, FONT_WEIGHT } from '../../constants';

export function ActiveTasksScreen() {
  return (
    <ScrollView style={styles.container} contentContainerStyle={styles.contentContainer}>
      <Text style={styles.title}>Active Tasks</Text>
      
      <View style={styles.emptyState}>
        <Text style={styles.emptyText}>No active tasks</Text>
        <Text style={styles.emptySubtext}>Create a task to get started</Text>
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
  emptyState: {
    flex: 1,
    padding: SPACING[8],
    alignItems: 'center',
    justifyContent: 'center',
    minHeight: 300,
  },
  emptyText: {
    fontSize: FONT_SIZE.xl,
    fontWeight: FONT_WEIGHT.semibold,
    color: NEUTRAL.TEXT,
    marginBottom: SPACING[2],
  },
  emptySubtext: {
    fontSize: FONT_SIZE.base,
    color: NEUTRAL.TEXT_SECONDARY,
  },
});
