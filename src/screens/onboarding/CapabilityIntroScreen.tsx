import React from 'react';
import { Text, Button, StyleSheet, ScrollView } from 'react-native';
import { useNavigation } from '@react-navigation/native';
import { NEUTRAL, SPACING, FONT_SIZE, FONT_WEIGHT } from '../../constants';

export function CapabilityIntroScreen() {
  const navigation = useNavigation();

  const handleContinue = () => {
    console.log('Continue button pressed');
    navigation.navigate('O6' as never);
  };

  return (
    <ScrollView style={styles.container} contentContainerStyle={styles.contentContainer}>
      <Text style={styles.title}>What Are Capabilities?</Text>
      <Text style={styles.description}>
        Capabilities are the skills, licenses, and qualifications that help you access more tasks on HustleXP.
      </Text>
      <Text style={styles.description}>
        By adding capabilities like professional licenses, insurance, or vehicle information, you can unlock higher-paying and more specialized tasks.
      </Text>
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
    marginBottom: SPACING[4],
  },
  description: {
    fontSize: FONT_SIZE.base,
    color: NEUTRAL.TEXT_SECONDARY,
    marginBottom: SPACING[4],
    lineHeight: 24,
  },
});
