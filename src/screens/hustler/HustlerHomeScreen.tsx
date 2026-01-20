import React from 'react';
import { View, Text, StyleSheet, ScrollView } from 'react-native';
import { NEUTRAL, SPACING, FONT_SIZE, FONT_WEIGHT, RADIUS } from '../../constants';

export function HustlerHomeScreen() {
  return (
    <ScrollView style={styles.container} contentContainerStyle={styles.contentContainer}>
      <Text style={styles.welcomeHeader}>Welcome, User</Text>
      
      <View style={styles.statsContainer}>
        <View style={styles.statCard}>
          <Text style={styles.statLabel}>XP</Text>
          <Text style={styles.statValue}>0</Text>
        </View>
        <View style={styles.statCard}>
          <Text style={styles.statLabel}>Trust Tier</Text>
          <Text style={styles.statValue}>Rookie</Text>
        </View>
      </View>

      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Active Task</Text>
        <View style={styles.emptyCard}>
          <Text style={styles.emptyText}>No active tasks</Text>
        </View>
      </View>

      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Recent Activity</Text>
        <View style={styles.emptyCard}>
          <Text style={styles.emptyText}>No recent activity</Text>
        </View>
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
  welcomeHeader: {
    fontSize: FONT_SIZE['2xl'],
    fontWeight: FONT_WEIGHT.bold,
    color: NEUTRAL.TEXT,
    marginBottom: SPACING[6],
  },
  statsContainer: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginBottom: SPACING[6],
  },
  statCard: {
    flex: 1,
    padding: SPACING[4],
    backgroundColor: NEUTRAL.BACKGROUND_SECONDARY,
    borderRadius: RADIUS.lg,
    marginHorizontal: SPACING[1],
    alignItems: 'center',
  },
  statLabel: {
    fontSize: FONT_SIZE.sm,
    color: NEUTRAL.TEXT_SECONDARY,
    marginBottom: SPACING[1],
  },
  statValue: {
    fontSize: FONT_SIZE.xl,
    fontWeight: FONT_WEIGHT.bold,
    color: NEUTRAL.TEXT,
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
  emptyCard: {
    padding: SPACING[6],
    backgroundColor: NEUTRAL.BACKGROUND_SECONDARY,
    borderRadius: RADIUS.lg,
    alignItems: 'center',
    justifyContent: 'center',
    minHeight: 100,
  },
  emptyText: {
    fontSize: FONT_SIZE.base,
    color: NEUTRAL.TEXT_SECONDARY,
  },
});
