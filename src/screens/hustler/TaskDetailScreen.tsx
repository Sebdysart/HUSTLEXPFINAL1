import React from 'react';
import { View, Text, StyleSheet, ScrollView, Button } from 'react-native';
import { NEUTRAL, SPACING, FONT_SIZE, FONT_WEIGHT, RADIUS } from '../../constants';

export function TaskDetailScreen() {
  const handleAccept = () => {
    console.log('Accept button pressed');
  };

  return (
    <ScrollView style={styles.container} contentContainerStyle={styles.contentContainer}>
      <Text style={styles.title}>Task Title</Text>
      <Text style={styles.description}>Task description goes here</Text>
      
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Pay Amount</Text>
        <Text style={styles.payAmount}>$50.00</Text>
      </View>

      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Required Trust Tier</Text>
        <Text style={styles.requirement}>Tier 2</Text>
      </View>

      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Required Capabilities</Text>
        <Text style={styles.requirement}>• Valid Driver's License</Text>
        <Text style={styles.requirement}>• Vehicle</Text>
      </View>

      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Location</Text>
        <View style={styles.mapPlaceholder}>
          <Text style={styles.mapText}>Map Preview</Text>
        </View>
      </View>

      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Poster Info</Text>
        <Text style={styles.posterInfo}>Rating: 4.5 ⭐</Text>
        <Text style={styles.posterInfo}>Tasks Completed: 25</Text>
      </View>

      <Button title="Accept Task" onPress={handleAccept} />
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
  description: {
    fontSize: FONT_SIZE.base,
    color: NEUTRAL.TEXT_SECONDARY,
    marginBottom: SPACING[6],
  },
  section: {
    marginBottom: SPACING[5],
    padding: SPACING[4],
    backgroundColor: NEUTRAL.BACKGROUND_SECONDARY,
    borderRadius: RADIUS.lg,
  },
  sectionTitle: {
    fontSize: FONT_SIZE.base,
    fontWeight: FONT_WEIGHT.semibold,
    color: NEUTRAL.TEXT,
    marginBottom: SPACING[2],
  },
  payAmount: {
    fontSize: FONT_SIZE.xl,
    fontWeight: FONT_WEIGHT.bold,
    color: NEUTRAL.TEXT,
  },
  requirement: {
    fontSize: FONT_SIZE.base,
    color: NEUTRAL.TEXT_SECONDARY,
    marginBottom: SPACING[1],
  },
  mapPlaceholder: {
    height: 150,
    backgroundColor: NEUTRAL.BACKGROUND_TERTIARY,
    borderRadius: RADIUS.md,
    alignItems: 'center',
    justifyContent: 'center',
    marginTop: SPACING[2],
  },
  mapText: {
    fontSize: FONT_SIZE.base,
    color: NEUTRAL.TEXT_SECONDARY,
  },
  posterInfo: {
    fontSize: FONT_SIZE.base,
    color: NEUTRAL.TEXT_SECONDARY,
    marginBottom: SPACING[1],
  },
});
