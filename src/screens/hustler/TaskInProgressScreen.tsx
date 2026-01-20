import React, { useState, useEffect } from 'react';
import { View, Text, StyleSheet, ScrollView, Button, TouchableOpacity, Alert } from 'react-native';
import { NEUTRAL, SPACING, FONT_SIZE, FONT_WEIGHT, RADIUS } from '../../constants';

export function TaskInProgressScreen() {
  const [timeElapsed, setTimeElapsed] = useState(0);

  useEffect(() => {
    const interval = setInterval(() => {
      setTimeElapsed((prev) => prev + 1);
    }, 1000);
    return () => clearInterval(interval);
  }, []);

  const formatTime = (seconds: number) => {
    const mins = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return `${mins}:${secs.toString().padStart(2, '0')}`;
  };

  const handleContact = () => {
    console.log('Contact poster button pressed');
  };

  const handleSubmitProof = () => {
    console.log('Submit proof button pressed');
  };

  const handleCancel = () => {
    Alert.alert('Cancel Task', 'Are you sure you want to cancel this task?', [
      { text: 'No', style: 'cancel' },
      { text: 'Yes', onPress: () => console.log('Task cancelled') },
    ]);
  };

  return (
    <ScrollView style={styles.container} contentContainerStyle={styles.contentContainer}>
      <View style={styles.taskCard}>
        <Text style={styles.taskTitle}>Task Title</Text>
        <Text style={styles.taskDescription}>Task description goes here</Text>
      </View>

      <View style={styles.timerContainer}>
        <Text style={styles.timerLabel}>Time on Task</Text>
        <Text style={styles.timerValue}>{formatTime(timeElapsed)}</Text>
      </View>

      <Button title="Contact Poster" onPress={handleContact} />
      <View style={styles.buttonSpacing} />
      <Button title="Submit Proof" onPress={handleSubmitProof} />
      <View style={styles.buttonSpacing} />
      <TouchableOpacity onPress={handleCancel}>
        <Text style={styles.cancelText}>Cancel Task</Text>
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
  taskCard: {
    padding: SPACING[4],
    backgroundColor: NEUTRAL.BACKGROUND_SECONDARY,
    borderRadius: RADIUS.lg,
    marginBottom: SPACING[6],
  },
  taskTitle: {
    fontSize: FONT_SIZE.xl,
    fontWeight: FONT_WEIGHT.bold,
    color: NEUTRAL.TEXT,
    marginBottom: SPACING[2],
  },
  taskDescription: {
    fontSize: FONT_SIZE.base,
    color: NEUTRAL.TEXT_SECONDARY,
  },
  timerContainer: {
    padding: SPACING[5],
    backgroundColor: NEUTRAL.BACKGROUND_SECONDARY,
    borderRadius: RADIUS.lg,
    alignItems: 'center',
    marginBottom: SPACING[6],
  },
  timerLabel: {
    fontSize: FONT_SIZE.base,
    color: NEUTRAL.TEXT_SECONDARY,
    marginBottom: SPACING[1],
  },
  timerValue: {
    fontSize: FONT_SIZE['2xl'],
    fontWeight: FONT_WEIGHT.bold,
    color: NEUTRAL.TEXT,
  },
  buttonSpacing: {
    height: SPACING[3],
  },
  cancelText: {
    fontSize: FONT_SIZE.base,
    color: NEUTRAL.TEXT_SECONDARY,
    textAlign: 'center',
    textDecorationLine: 'underline',
    marginTop: SPACING[2],
  },
});
