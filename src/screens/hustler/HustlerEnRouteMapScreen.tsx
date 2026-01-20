import React from 'react';
import { View, Text, StyleSheet, Button } from 'react-native';
import { NEUTRAL, SPACING, FONT_SIZE, FONT_WEIGHT } from '../../constants';

export function HustlerEnRouteMapScreen() {
  const handleArrived = () => {
    console.log("I've arrived button pressed");
  };

  return (
    <View style={styles.container}>
      <View style={styles.mapPlaceholder}>
        <Text style={styles.mapText}>Map View</Text>
        <Text style={styles.markerText}>📍 Task Location</Text>
        <Text style={styles.etaText}>ETA: 15 minutes</Text>
      </View>
      <View style={styles.buttonContainer}>
        <Button title="I've Arrived" onPress={handleArrived} />
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: NEUTRAL.BACKGROUND,
  },
  mapPlaceholder: {
    flex: 1,
    backgroundColor: NEUTRAL.BACKGROUND_SECONDARY,
    alignItems: 'center',
    justifyContent: 'center',
  },
  mapText: {
    fontSize: FONT_SIZE.xl,
    fontWeight: FONT_WEIGHT.bold,
    color: NEUTRAL.TEXT,
    marginBottom: SPACING[4],
  },
  markerText: {
    fontSize: FONT_SIZE.lg,
    color: NEUTRAL.TEXT,
    marginBottom: SPACING[2],
  },
  etaText: {
    fontSize: FONT_SIZE.base,
    color: NEUTRAL.TEXT_SECONDARY,
  },
  buttonContainer: {
    padding: SPACING[4],
    backgroundColor: NEUTRAL.BACKGROUND,
  },
});
