import React from 'react';
import { View, Text, StyleSheet, ScrollView, TouchableOpacity } from 'react-native';
import { NEUTRAL, SPACING, FONT_SIZE, FONT_WEIGHT, RADIUS } from '../../constants';

export function SupportScreen() {
  const handleContactSupport = () => {
    console.log('Contact Support button pressed');
    // In real app, would open email or chat
  };

  const handleFAQ = () => {
    console.log('FAQ button pressed');
    // In real app, would navigate to FAQ
  };

  return (
    <ScrollView style={styles.container} contentContainerStyle={styles.contentContainer}>
      <Text style={styles.title}>Support</Text>

      <View style={styles.section}>
        <TouchableOpacity style={styles.supportOption} onPress={handleContactSupport}>
          <Text style={styles.supportOptionTitle}>Contact Support</Text>
          <Text style={styles.supportOptionDescription}>
            Get help from our support team
          </Text>
        </TouchableOpacity>

        <TouchableOpacity style={styles.supportOption} onPress={handleFAQ}>
          <Text style={styles.supportOptionTitle}>FAQ</Text>
          <Text style={styles.supportOptionDescription}>
            Frequently asked questions
          </Text>
        </TouchableOpacity>
      </View>

      <View style={styles.infoCard}>
        <Text style={styles.infoTitle}>App Information</Text>
        <Text style={styles.infoText}>Version: 1.0.0</Text>
        <Text style={styles.infoText}>Build: 2025.01.19</Text>
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
    gap: SPACING[3],
  },
  supportOption: {
    padding: SPACING[4],
    backgroundColor: NEUTRAL.BACKGROUND_SECONDARY,
    borderRadius: RADIUS.lg,
  },
  supportOptionTitle: {
    fontSize: FONT_SIZE.lg,
    fontWeight: FONT_WEIGHT.semibold,
    color: NEUTRAL.TEXT,
    marginBottom: SPACING[1],
  },
  supportOptionDescription: {
    fontSize: FONT_SIZE.base,
    color: NEUTRAL.TEXT_SECONDARY,
  },
  infoCard: {
    backgroundColor: NEUTRAL.BACKGROUND_SECONDARY,
    padding: SPACING[4],
    borderRadius: RADIUS.lg,
  },
  infoTitle: {
    fontSize: FONT_SIZE.lg,
    fontWeight: FONT_WEIGHT.semibold,
    color: NEUTRAL.TEXT,
    marginBottom: SPACING[2],
  },
  infoText: {
    fontSize: FONT_SIZE.base,
    color: NEUTRAL.TEXT_SECONDARY,
    marginBottom: SPACING[1],
  },
});
