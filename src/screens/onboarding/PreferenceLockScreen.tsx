import React from 'react';
import { View, Text, Button, StyleSheet, TouchableOpacity, ScrollView } from 'react-native';
import { NEUTRAL, SPACING, FONT_SIZE, FONT_WEIGHT } from '../../constants';

export function PreferenceLockScreen() {
  const handleConfirm = () => {
    console.log('Confirm button pressed - preferences locked');
  };

  return (
    <ScrollView style={styles.container} contentContainerStyle={styles.contentContainer}>
      <Text style={styles.title}>Confirm Your Preferences</Text>
      
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Role Selection</Text>
        <Text style={styles.sectionValue}>Hustler</Text>
        <TouchableOpacity>
          <Text style={styles.editLink}>Edit</Text>
        </TouchableOpacity>
      </View>

      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Location</Text>
        <Text style={styles.sectionValue}>California</Text>
        <TouchableOpacity>
          <Text style={styles.editLink}>Edit</Text>
        </TouchableOpacity>
      </View>

      <Text style={styles.warning}>These can be changed in Settings</Text>
      
      <Button title="Confirm" onPress={handleConfirm} />
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
    marginBottom: SPACING[5],
    paddingBottom: SPACING[4],
    borderBottomWidth: 1,
    borderBottomColor: NEUTRAL.BORDER,
  },
  sectionTitle: {
    fontSize: FONT_SIZE.base,
    fontWeight: FONT_WEIGHT.semibold,
    color: NEUTRAL.TEXT,
    marginBottom: SPACING[1],
  },
  sectionValue: {
    fontSize: FONT_SIZE.base,
    color: NEUTRAL.TEXT_SECONDARY,
    marginBottom: SPACING[2],
  },
  editLink: {
    fontSize: FONT_SIZE.sm,
    color: NEUTRAL.TEXT_SECONDARY,
    textDecorationLine: 'underline',
  },
  warning: {
    fontSize: FONT_SIZE.sm,
    color: NEUTRAL.TEXT_SECONDARY,
    fontStyle: 'italic',
    marginBottom: SPACING[6],
    textAlign: 'center',
  },
});
