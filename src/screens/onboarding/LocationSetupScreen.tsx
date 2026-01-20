import React, { useState } from 'react';
import { Text, TextInput, Button, StyleSheet, ScrollView } from 'react-native';
import { NEUTRAL, SPACING, RADIUS, FONT_SIZE, FONT_WEIGHT } from '../../constants';

export function LocationSetupScreen() {
  const [state, setState] = useState('');
  const [radius, setRadius] = useState('');

  const handleContinue = () => {
    console.log('Continue button pressed', { state, radius });
  };

  return (
    <ScrollView style={styles.container} contentContainerStyle={styles.contentContainer}>
      <Text style={styles.title}>Set Your Work Location</Text>
      <Text style={styles.description}>Where would you like to work?</Text>
      
      <TextInput
        style={styles.input}
        placeholder="State/Region"
        value={state}
        onChangeText={setState}
      />
      
      <TextInput
        style={styles.input}
        placeholder="Work Radius (miles)"
        value={radius}
        onChangeText={setRadius}
        keyboardType="numeric"
      />
      
      <Button title="Continue" onPress={handleContinue} />
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
  input: {
    height: 48,
    borderWidth: 1,
    borderColor: NEUTRAL.BORDER,
    borderRadius: RADIUS.md,
    paddingHorizontal: SPACING[3],
    marginBottom: SPACING[4],
    fontSize: FONT_SIZE.base,
    color: NEUTRAL.TEXT,
  },
});
