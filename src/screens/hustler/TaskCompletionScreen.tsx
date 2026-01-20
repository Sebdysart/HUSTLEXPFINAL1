import React from 'react';
import { View, Text, StyleSheet, ScrollView, Button } from 'react-native';
import { NEUTRAL, SPACING, FONT_SIZE, FONT_WEIGHT, RADIUS } from '../../constants';

export function TaskCompletionScreen() {
  const handleSubmit = () => {
    console.log('Submit proof button pressed');
  };

  return (
    <ScrollView style={styles.container} contentContainerStyle={styles.contentContainer}>
      <Text style={styles.title}>Complete Task</Text>
      
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Task Details</Text>
        <Text style={styles.taskInfo}>Task: Sample Task</Text>
        <Text style={styles.taskInfo}>Pay: $50.00</Text>
      </View>

      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Submit Proof</Text>
        <Text style={styles.description}>Upload photos or documents as proof of completion</Text>
        <Button title="Upload Proof" onPress={handleSubmit} />
      </View>

      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Mark as Complete</Text>
        <Button title="Mark Complete" onPress={handleSubmit} />
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
    padding: SPACING[4],
    backgroundColor: NEUTRAL.BACKGROUND_SECONDARY,
    borderRadius: RADIUS.lg,
  },
  sectionTitle: {
    fontSize: FONT_SIZE.lg,
    fontWeight: FONT_WEIGHT.semibold,
    color: NEUTRAL.TEXT,
    marginBottom: SPACING[3],
  },
  taskInfo: {
    fontSize: FONT_SIZE.base,
    color: NEUTRAL.TEXT_SECONDARY,
    marginBottom: SPACING[1],
  },
  description: {
    fontSize: FONT_SIZE.base,
    color: NEUTRAL.TEXT_SECONDARY,
    marginBottom: SPACING[4],
  },
});
