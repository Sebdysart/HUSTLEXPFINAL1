import React from 'react';
import { View, Text, StyleSheet, ScrollView, TouchableOpacity } from 'react-native';
import { useNavigation } from '@react-navigation/native';
import { NEUTRAL, SPACING, FONT_SIZE, FONT_WEIGHT, RADIUS } from '../../constants';

export function HustlerOnWayScreen() {
  const navigation = useNavigation();

  // Stub data
  const task = {
    title: 'Fix Leaky Faucet',
    location: '123 Main St, Anytown',
  };
  const hustler = {
    name: 'John Doe',
    rating: 4.8,
    photo: 'https://via.placeholder.com/150',
  };
  const eta = 15; // minutes

  const handleChat = () => {
    console.log('Chat button pressed');
    navigation.navigate('TaskConversation' as never);
  };

  const handleCancel = () => {
    console.log('Cancel button pressed');
    // In real app, would show confirmation
  };

  return (
    <ScrollView style={styles.container} contentContainerStyle={styles.contentContainer}>
      <Text style={styles.title}>Hustler On The Way</Text>

      <View style={styles.mapPlaceholder}>
        <Text style={styles.mapText}>Map Placeholder</Text>
        <Text style={styles.mapText}>Live location tracking</Text>
      </View>

      <View style={styles.hustlerCard}>
        <View style={styles.photoPlaceholder}>
          <Text style={styles.photoText}>Photo</Text>
        </View>
        <Text style={styles.hustlerName}>{hustler.name}</Text>
        <Text style={styles.rating}>⭐ {hustler.rating}</Text>
      </View>

      <View style={styles.taskCard}>
        <Text style={styles.taskTitle}>{task.title}</Text>
        <Text style={styles.taskLocation}>📍 {task.location}</Text>
      </View>

      <View style={styles.etaCard}>
        <Text style={styles.etaLabel}>Estimated Arrival</Text>
        <Text style={styles.etaValue}>{eta} minutes</Text>
      </View>

      <TouchableOpacity style={styles.chatButton} onPress={handleChat}>
        <Text style={styles.chatButtonText}>Chat with Hustler</Text>
      </TouchableOpacity>

      <TouchableOpacity style={styles.cancelButton} onPress={handleCancel}>
        <Text style={styles.cancelButtonText}>Cancel Task</Text>
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
    textAlign: 'center',
  },
  mapPlaceholder: {
    width: '100%',
    height: 300,
    backgroundColor: NEUTRAL.BACKGROUND_SECONDARY,
    borderRadius: RADIUS.lg,
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: SPACING[6],
    borderWidth: 1,
    borderColor: NEUTRAL.BORDER,
  },
  mapText: {
    color: NEUTRAL.TEXT_SECONDARY,
    fontSize: FONT_SIZE.base,
    marginBottom: SPACING[1],
  },
  hustlerCard: {
    backgroundColor: NEUTRAL.BACKGROUND_SECONDARY,
    padding: SPACING[4],
    borderRadius: RADIUS.lg,
    alignItems: 'center',
    marginBottom: SPACING[4],
  },
  photoPlaceholder: {
    width: 80,
    height: 80,
    borderRadius: 40,
    backgroundColor: NEUTRAL.BACKGROUND_TERTIARY,
    alignItems: 'center',
    justifyContent: 'center',
    marginBottom: SPACING[2],
  },
  photoText: {
    fontSize: FONT_SIZE.sm,
    color: NEUTRAL.TEXT_SECONDARY,
  },
  hustlerName: {
    fontSize: FONT_SIZE.lg,
    fontWeight: FONT_WEIGHT.bold,
    color: NEUTRAL.TEXT,
    marginBottom: SPACING[1],
  },
  rating: {
    fontSize: FONT_SIZE.base,
    color: NEUTRAL.TEXT_SECONDARY,
  },
  taskCard: {
    backgroundColor: NEUTRAL.BACKGROUND_SECONDARY,
    padding: SPACING[4],
    borderRadius: RADIUS.lg,
    marginBottom: SPACING[4],
  },
  taskTitle: {
    fontSize: FONT_SIZE.lg,
    fontWeight: FONT_WEIGHT.semibold,
    color: NEUTRAL.TEXT,
    marginBottom: SPACING[1],
  },
  taskLocation: {
    fontSize: FONT_SIZE.base,
    color: NEUTRAL.TEXT_SECONDARY,
  },
  etaCard: {
    backgroundColor: '#D1FAE5',
    padding: SPACING[4],
    borderRadius: RADIUS.lg,
    alignItems: 'center',
    marginBottom: SPACING[6],
    borderWidth: 1,
    borderColor: '#10B981',
  },
  etaLabel: {
    fontSize: FONT_SIZE.base,
    color: NEUTRAL.TEXT_SECONDARY,
    marginBottom: SPACING[1],
  },
  etaValue: {
    fontSize: FONT_SIZE['2xl'],
    fontWeight: FONT_WEIGHT.bold,
    color: NEUTRAL.TEXT,
  },
  chatButton: {
    width: '100%',
    padding: SPACING[3],
    backgroundColor: '#3B82F6',
    borderRadius: RADIUS.md,
    alignItems: 'center',
    marginBottom: SPACING[3],
  },
  chatButtonText: {
    color: NEUTRAL.TEXT_INVERSE,
    fontSize: FONT_SIZE.lg,
    fontWeight: FONT_WEIGHT.semibold,
  },
  cancelButton: {
    width: '100%',
    padding: SPACING[3],
    backgroundColor: NEUTRAL.BACKGROUND_SECONDARY,
    borderRadius: RADIUS.md,
    alignItems: 'center',
    borderWidth: 1,
    borderColor: NEUTRAL.BORDER,
  },
  cancelButtonText: {
    color: '#EF4444',
    fontSize: FONT_SIZE.lg,
    fontWeight: FONT_WEIGHT.semibold,
  },
});
