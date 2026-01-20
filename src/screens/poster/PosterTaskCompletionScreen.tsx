import React, { useState } from 'react';
import { View, Text, StyleSheet, ScrollView, TouchableOpacity, Image } from 'react-native';
import { NEUTRAL, SPACING, FONT_SIZE, FONT_WEIGHT, RADIUS } from '../../constants';

export function PosterTaskCompletionScreen() {
  const [proofImages] = useState<string[]>([
    'https://via.placeholder.com/300',
  ]);

  // Stub data
  const task = {
    title: 'Fix Leaky Faucet',
    pay: 75,
  };
  const hustler = {
    name: 'John Doe',
    rating: 4.8,
  };
  const proofNote = 'Task completed successfully. Faucet is now working properly.';

  const handleApprove = () => {
    console.log('Approve button pressed - release escrow');
    // In real app, would release escrow payment
  };

  const handleDispute = () => {
    console.log('Dispute button pressed');
    // In real app, would navigate to dispute screen
  };

  return (
    <ScrollView style={styles.container} contentContainerStyle={styles.contentContainer}>
      <Text style={styles.title}>Review Task Completion</Text>

      <View style={styles.taskCard}>
        <Text style={styles.taskTitle}>{task.title}</Text>
        <Text style={styles.taskPay}>Pay: ${task.pay}</Text>
      </View>

      <View style={styles.hustlerCard}>
        <Text style={styles.hustlerName}>{hustler.name}</Text>
        <Text style={styles.rating}>⭐ {hustler.rating}</Text>
      </View>

      <View style={styles.proofSection}>
        <Text style={styles.sectionTitle}>Proof of Completion</Text>
        {proofImages.map((imageUri, idx) => (
          <Image key={idx} source={{ uri: imageUri }} style={styles.proofImage} />
        ))}
        {proofNote && (
          <View style={styles.noteCard}>
            <Text style={styles.noteText}>{proofNote}</Text>
          </View>
        )}
      </View>

      <View style={styles.actionButtons}>
        <TouchableOpacity style={styles.approveButton} onPress={handleApprove}>
          <Text style={styles.approveButtonText}>Approve & Release Payment</Text>
        </TouchableOpacity>
        <TouchableOpacity style={styles.disputeButton} onPress={handleDispute}>
          <Text style={styles.disputeButtonText}>File Dispute</Text>
        </TouchableOpacity>
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
    textAlign: 'center',
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
  taskPay: {
    fontSize: FONT_SIZE.base,
    color: NEUTRAL.TEXT_SECONDARY,
  },
  hustlerCard: {
    backgroundColor: NEUTRAL.BACKGROUND_SECONDARY,
    padding: SPACING[4],
    borderRadius: RADIUS.lg,
    marginBottom: SPACING[6],
    alignItems: 'center',
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
  proofSection: {
    marginBottom: SPACING[6],
  },
  sectionTitle: {
    fontSize: FONT_SIZE.lg,
    fontWeight: FONT_WEIGHT.semibold,
    color: NEUTRAL.TEXT,
    marginBottom: SPACING[3],
  },
  proofImage: {
    width: '100%',
    height: 200,
    borderRadius: RADIUS.md,
    marginBottom: SPACING[3],
    resizeMode: 'cover',
  },
  noteCard: {
    backgroundColor: NEUTRAL.BACKGROUND_SECONDARY,
    padding: SPACING[3],
    borderRadius: RADIUS.md,
    marginTop: SPACING[2],
  },
  noteText: {
    fontSize: FONT_SIZE.base,
    color: NEUTRAL.TEXT,
  },
  actionButtons: {
    gap: SPACING[3],
  },
  approveButton: {
    width: '100%',
    padding: SPACING[3],
    backgroundColor: '#10B981',
    borderRadius: RADIUS.md,
    alignItems: 'center',
  },
  approveButtonText: {
    color: NEUTRAL.TEXT_INVERSE,
    fontSize: FONT_SIZE.lg,
    fontWeight: FONT_WEIGHT.semibold,
  },
  disputeButton: {
    width: '100%',
    padding: SPACING[3],
    backgroundColor: NEUTRAL.BACKGROUND_SECONDARY,
    borderRadius: RADIUS.md,
    alignItems: 'center',
    borderWidth: 1,
    borderColor: '#EF4444',
  },
  disputeButtonText: {
    color: '#EF4444',
    fontSize: FONT_SIZE.lg,
    fontWeight: FONT_WEIGHT.semibold,
  },
});
