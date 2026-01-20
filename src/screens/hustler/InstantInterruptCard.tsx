import React, { useState, useEffect } from 'react';
import { View, Text, StyleSheet, Button, TouchableOpacity } from 'react-native';
import { NEUTRAL, SPACING, FONT_SIZE, FONT_WEIGHT, RADIUS } from '../../constants';

export function InstantInterruptCard() {
  const [countdown, setCountdown] = useState(30);

  useEffect(() => {
    if (countdown > 0) {
      const timer = setTimeout(() => setCountdown(countdown - 1), 1000);
      return () => clearTimeout(timer);
    }
  }, [countdown]);

  const handleAccept = () => {
    console.log('Accept button pressed');
  };

  const handleDecline = () => {
    console.log('Decline button pressed');
  };

  return (
    <View style={styles.container}>
      <View style={styles.card}>
        <Text style={styles.title}>New Task Available</Text>
        <Text style={styles.taskSummary}>Task: Sample Task</Text>
        <Text style={styles.payAmount}>Pay: $50.00</Text>
        <Text style={styles.distance}>Distance: 2.5 miles</Text>
        <Text style={styles.countdown}>Time: {countdown}s</Text>
        <Button title="Accept" onPress={handleAccept} />
        <TouchableOpacity onPress={handleDecline} style={styles.declineButton}>
          <Text style={styles.declineText}>Decline</Text>
        </TouchableOpacity>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    backgroundColor: 'rgba(0, 0, 0, 0.5)',
    justifyContent: 'center',
    alignItems: 'center',
  },
  card: {
    backgroundColor: NEUTRAL.BACKGROUND,
    padding: SPACING[5],
    borderRadius: RADIUS.xl,
    width: '90%',
    maxWidth: 400,
  },
  title: {
    fontSize: FONT_SIZE.xl,
    fontWeight: FONT_WEIGHT.bold,
    color: NEUTRAL.TEXT,
    marginBottom: SPACING[4],
    textAlign: 'center',
  },
  taskSummary: {
    fontSize: FONT_SIZE.base,
    color: NEUTRAL.TEXT,
    marginBottom: SPACING[2],
  },
  payAmount: {
    fontSize: FONT_SIZE.lg,
    fontWeight: FONT_WEIGHT.bold,
    color: NEUTRAL.TEXT,
    marginBottom: SPACING[2],
  },
  distance: {
    fontSize: FONT_SIZE.base,
    color: NEUTRAL.TEXT_SECONDARY,
    marginBottom: SPACING[2],
  },
  countdown: {
    fontSize: FONT_SIZE.base,
    fontWeight: FONT_WEIGHT.bold,
    color: NEUTRAL.TEXT,
    marginBottom: SPACING[4],
    textAlign: 'center',
  },
  declineButton: {
    marginTop: SPACING[3],
    alignItems: 'center',
  },
  declineText: {
    fontSize: FONT_SIZE.base,
    color: NEUTRAL.TEXT_SECONDARY,
    textDecorationLine: 'underline',
  },
});
