import React from 'react';
import { View, Text, StyleSheet, ScrollView, TouchableOpacity } from 'react-native';
import { NEUTRAL, SPACING, FONT_SIZE, FONT_WEIGHT, RADIUS } from '../../constants';

export function HustlerProfileScreen() {
  return (
    <ScrollView style={styles.container} contentContainerStyle={styles.contentContainer}>
      <View style={styles.profileHeader}>
        <View style={styles.photoPlaceholder}>
          <Text style={styles.photoText}>Photo</Text>
        </View>
        <Text style={styles.displayName}>User Name</Text>
      </View>

      <View style={styles.badgeContainer}>
        <View style={styles.badge}>
          <Text style={styles.badgeLabel}>Trust Tier</Text>
          <Text style={styles.badgeValue}>Rookie</Text>
        </View>
      </View>

      <View style={styles.progressContainer}>
        <Text style={styles.progressLabel}>XP Progress</Text>
        <View style={styles.progressBar}>
          <View style={styles.progressFillZero} />
        </View>
        <Text style={styles.progressText}>0 / 100 XP</Text>
      </View>

      <View style={styles.ratingContainer}>
        <Text style={styles.ratingLabel}>Rating</Text>
        <Text style={styles.ratingValue}>—</Text>
      </View>

      <TouchableOpacity style={styles.settingsLink}>
        <Text style={styles.settingsText}>Settings</Text>
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
  profileHeader: {
    alignItems: 'center',
    marginBottom: SPACING[6],
  },
  photoPlaceholder: {
    width: 100,
    height: 100,
    borderRadius: 50,
    backgroundColor: NEUTRAL.BACKGROUND_SECONDARY,
    alignItems: 'center',
    justifyContent: 'center',
    marginBottom: SPACING[3],
  },
  photoText: {
    fontSize: FONT_SIZE.sm,
    color: NEUTRAL.TEXT_SECONDARY,
  },
  displayName: {
    fontSize: FONT_SIZE.xl,
    fontWeight: FONT_WEIGHT.bold,
    color: NEUTRAL.TEXT,
  },
  badgeContainer: {
    marginBottom: SPACING[6],
  },
  badge: {
    padding: SPACING[4],
    backgroundColor: NEUTRAL.BACKGROUND_SECONDARY,
    borderRadius: RADIUS.lg,
    alignItems: 'center',
  },
  badgeLabel: {
    fontSize: FONT_SIZE.sm,
    color: NEUTRAL.TEXT_SECONDARY,
    marginBottom: SPACING[1],
  },
  badgeValue: {
    fontSize: FONT_SIZE.lg,
    fontWeight: FONT_WEIGHT.bold,
    color: NEUTRAL.TEXT,
  },
  progressContainer: {
    marginBottom: SPACING[6],
  },
  progressLabel: {
    fontSize: FONT_SIZE.base,
    fontWeight: FONT_WEIGHT.semibold,
    color: NEUTRAL.TEXT,
    marginBottom: SPACING[2],
  },
  progressBar: {
    height: 8,
    backgroundColor: NEUTRAL.BACKGROUND_SECONDARY,
    borderRadius: RADIUS.sm,
    marginBottom: SPACING[1],
    overflow: 'hidden',
  },
  progressFill: {
    height: '100%',
    backgroundColor: NEUTRAL.TEXT,
  },
  progressFillZero: {
    height: '100%',
    backgroundColor: NEUTRAL.TEXT,
    width: '0%',
  },
  progressText: {
    fontSize: FONT_SIZE.sm,
    color: NEUTRAL.TEXT_SECONDARY,
  },
  ratingContainer: {
    marginBottom: SPACING[6],
    padding: SPACING[4],
    backgroundColor: NEUTRAL.BACKGROUND_SECONDARY,
    borderRadius: RADIUS.lg,
    alignItems: 'center',
  },
  ratingLabel: {
    fontSize: FONT_SIZE.sm,
    color: NEUTRAL.TEXT_SECONDARY,
    marginBottom: SPACING[1],
  },
  ratingValue: {
    fontSize: FONT_SIZE['2xl'],
    fontWeight: FONT_WEIGHT.bold,
    color: NEUTRAL.TEXT,
  },
  settingsLink: {
    padding: SPACING[4],
    alignItems: 'center',
  },
  settingsText: {
    fontSize: FONT_SIZE.base,
    color: NEUTRAL.TEXT_SECONDARY,
    textDecorationLine: 'underline',
  },
});
