import React from 'react';
import { View, Text, StyleSheet, ScrollView, TouchableOpacity } from 'react-native';
import { useNavigation } from '@react-navigation/native';
import { NEUTRAL, SPACING, FONT_SIZE, FONT_WEIGHT, RADIUS } from '../../constants';

export function NoTasksAvailableScreen() {
  const navigation = useNavigation();

  const handleRefresh = () => {
    console.log('Refresh button pressed');
    // In real app, would refresh task feed
  };

  const handleExpandRadius = () => {
    console.log('Expand radius button pressed');
    // In real app, would navigate to location settings
  };

  const handleAddCapabilities = () => {
    console.log('Add capabilities button pressed');
    // In real app, would navigate to capabilities screen
  };

  const handleViewEligibility = () => {
    console.log('View eligibility button pressed');
    navigation.navigate('S3' as never); // Navigate to WorkEligibilityScreen (or Settings)
  };

  return (
    <ScrollView style={styles.container} contentContainerStyle={styles.contentContainer}>
      <View style={styles.illustrationPlaceholder}>
        <Text style={styles.illustrationText}>📭</Text>
      </View>

      <Text style={styles.title}>No Tasks Available</Text>
      <Text style={styles.subtitle}>
        We couldn't find any tasks matching your criteria right now.
      </Text>

      <View style={styles.reasonsCard}>
        <Text style={styles.reasonsTitle}>Possible reasons:</Text>
        <Text style={styles.reasonItem}>• No tasks in your area</Text>
        <Text style={styles.reasonItem}>• No tasks match your capabilities</Text>
        <Text style={styles.reasonItem}>• All available tasks are taken</Text>
      </View>

      <View style={styles.suggestionsCard}>
        <Text style={styles.suggestionsTitle}>Try these suggestions:</Text>
        <TouchableOpacity style={styles.suggestionButton} onPress={handleExpandRadius}>
          <Text style={styles.suggestionButtonText}>Expand Work Radius</Text>
        </TouchableOpacity>
        <TouchableOpacity style={styles.suggestionButton} onPress={handleAddCapabilities}>
          <Text style={styles.suggestionButtonText}>Add More Capabilities</Text>
        </TouchableOpacity>
        <TouchableOpacity style={styles.suggestionButton} onPress={handleViewEligibility}>
          <Text style={styles.suggestionButtonText}>View Work Eligibility</Text>
        </TouchableOpacity>
      </View>

      <TouchableOpacity style={styles.refreshButton} onPress={handleRefresh}>
        <Text style={styles.refreshButtonText}>Refresh Feed</Text>
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
    alignItems: 'center',
  },
  illustrationPlaceholder: {
    width: 120,
    height: 120,
    borderRadius: 60,
    backgroundColor: NEUTRAL.BACKGROUND_SECONDARY,
    alignItems: 'center',
    justifyContent: 'center',
    marginBottom: SPACING[6],
  },
  illustrationText: {
    fontSize: FONT_SIZE['4xl'],
  },
  title: {
    fontSize: FONT_SIZE['2xl'],
    fontWeight: FONT_WEIGHT.bold,
    color: NEUTRAL.TEXT,
    marginBottom: SPACING[2],
    textAlign: 'center',
  },
  subtitle: {
    fontSize: FONT_SIZE.base,
    color: NEUTRAL.TEXT_SECONDARY,
    textAlign: 'center',
    marginBottom: SPACING[6],
  },
  reasonsCard: {
    width: '100%',
    backgroundColor: NEUTRAL.BACKGROUND_SECONDARY,
    padding: SPACING[4],
    borderRadius: RADIUS.lg,
    marginBottom: SPACING[4],
  },
  reasonsTitle: {
    fontSize: FONT_SIZE.lg,
    fontWeight: FONT_WEIGHT.semibold,
    color: NEUTRAL.TEXT,
    marginBottom: SPACING[2],
  },
  reasonItem: {
    fontSize: FONT_SIZE.base,
    color: NEUTRAL.TEXT_SECONDARY,
    marginBottom: SPACING[1],
  },
  suggestionsCard: {
    width: '100%',
    backgroundColor: '#D1FAE5',
    padding: SPACING[4],
    borderRadius: RADIUS.lg,
    marginBottom: SPACING[6],
    borderWidth: 1,
    borderColor: '#10B981',
  },
  suggestionsTitle: {
    fontSize: FONT_SIZE.lg,
    fontWeight: FONT_WEIGHT.semibold,
    color: NEUTRAL.TEXT,
    marginBottom: SPACING[3],
  },
  suggestionButton: {
    padding: SPACING[3],
    backgroundColor: NEUTRAL.BACKGROUND,
    borderRadius: RADIUS.md,
    marginBottom: SPACING[2],
    alignItems: 'center',
  },
  suggestionButtonText: {
    fontSize: FONT_SIZE.base,
    color: NEUTRAL.TEXT,
    fontWeight: FONT_WEIGHT.semibold,
  },
  refreshButton: {
    width: '100%',
    padding: SPACING[3],
    backgroundColor: '#3B82F6',
    borderRadius: RADIUS.md,
    alignItems: 'center',
  },
  refreshButtonText: {
    color: NEUTRAL.TEXT_INVERSE,
    fontSize: FONT_SIZE.lg,
    fontWeight: FONT_WEIGHT.semibold,
  },
});
