import React from 'react';
import { View, Text, StyleSheet, ScrollView, TouchableOpacity } from 'react-native';
import { NEUTRAL, SPACING, FONT_SIZE, FONT_WEIGHT, RADIUS } from '../../constants';

export function TaskDetailScreen() {

  // Stub data
  const task = {
    title: 'Fix Leaky Faucet',
    description: 'Kitchen faucet dripping constantly. Needs new washer and seal. Should take about 30 minutes.',
    category: 'Plumbing',
    location: '123 Main St, Anytown, CA 12345',
    price: 75,
  };
  const poster = {
    name: 'Alice Smith',
    rating: 4.9,
  };

  const handleAccept = () => {
    console.log('Accept task button pressed');
    // In real app, would accept task and navigate to TaskInProgress
  };

  return (
    <ScrollView style={styles.container} contentContainerStyle={styles.contentContainer}>
      <Text style={styles.title}>{task.title}</Text>

      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Description</Text>
        <Text style={styles.description}>{task.description}</Text>
      </View>

      <View style={styles.infoCard}>
        <View style={styles.infoRow}>
          <Text style={styles.infoLabel}>Category:</Text>
          <Text style={styles.infoValue}>{task.category}</Text>
        </View>
        <View style={styles.infoRow}>
          <Text style={styles.infoLabel}>Location:</Text>
          <Text style={styles.infoValue}>{task.location}</Text>
        </View>
        <View style={styles.infoRow}>
          <Text style={styles.infoLabel}>Pay:</Text>
          <Text style={styles.priceValue}>${task.price}</Text>
        </View>
      </View>

      <View style={styles.posterCard}>
        <Text style={styles.posterLabel}>Posted by</Text>
        <Text style={styles.posterName}>{poster.name}</Text>
        <Text style={styles.posterRating}>⭐ {poster.rating}</Text>
      </View>

      <TouchableOpacity style={styles.acceptButton} onPress={handleAccept}>
        <Text style={styles.acceptButtonText}>Accept Task</Text>
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
  title: {
    fontSize: FONT_SIZE['2xl'],
    fontWeight: FONT_WEIGHT.bold,
    color: NEUTRAL.TEXT,
    marginBottom: SPACING[6],
  },
  section: {
    marginBottom: SPACING[6],
  },
  sectionTitle: {
    fontSize: FONT_SIZE.lg,
    fontWeight: FONT_WEIGHT.semibold,
    color: NEUTRAL.TEXT,
    marginBottom: SPACING[2],
  },
  description: {
    fontSize: FONT_SIZE.base,
    color: NEUTRAL.TEXT_SECONDARY,
    lineHeight: 24,
  },
  infoCard: {
    backgroundColor: NEUTRAL.BACKGROUND_SECONDARY,
    padding: SPACING[4],
    borderRadius: RADIUS.lg,
    marginBottom: SPACING[6],
  },
  infoRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginBottom: SPACING[2],
  },
  infoLabel: {
    fontSize: FONT_SIZE.base,
    color: NEUTRAL.TEXT_SECONDARY,
  },
  infoValue: {
    fontSize: FONT_SIZE.base,
    color: NEUTRAL.TEXT,
    fontWeight: FONT_WEIGHT.semibold,
  },
  priceValue: {
    fontSize: FONT_SIZE.xl,
    color: '#10B981',
    fontWeight: FONT_WEIGHT.bold,
  },
  posterCard: {
    backgroundColor: NEUTRAL.BACKGROUND_SECONDARY,
    padding: SPACING[4],
    borderRadius: RADIUS.lg,
    marginBottom: SPACING[6],
    alignItems: 'center',
  },
  posterLabel: {
    fontSize: FONT_SIZE.sm,
    color: NEUTRAL.TEXT_SECONDARY,
    marginBottom: SPACING[1],
  },
  posterName: {
    fontSize: FONT_SIZE.lg,
    fontWeight: FONT_WEIGHT.bold,
    color: NEUTRAL.TEXT,
    marginBottom: SPACING[1],
  },
  posterRating: {
    fontSize: FONT_SIZE.base,
    color: NEUTRAL.TEXT_SECONDARY,
  },
  acceptButton: {
    width: '100%',
    padding: SPACING[3],
    backgroundColor: '#10B981',
    borderRadius: RADIUS.md,
    alignItems: 'center',
  },
  acceptButtonText: {
    color: NEUTRAL.TEXT_INVERSE,
    fontSize: FONT_SIZE.lg,
    fontWeight: FONT_WEIGHT.semibold,
  },
});
