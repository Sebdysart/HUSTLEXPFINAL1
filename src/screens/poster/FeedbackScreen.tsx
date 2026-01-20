import React, { useState } from 'react';
import { View, Text, StyleSheet, ScrollView, TouchableOpacity } from 'react-native';
import { useNavigation } from '@react-navigation/native';
import { NEUTRAL, SPACING, FONT_SIZE, FONT_WEIGHT, RADIUS } from '../../constants';

export function FeedbackScreen() {
  const navigation = useNavigation();
  const [rating, setRating] = useState<number | null>(null);
  const [comment] = useState('');

  // Stub data
  const hustler = {
    name: 'John Doe',
    taskTitle: 'Fix Leaky Faucet',
  };

  const handleSubmit = () => {
    if (rating) {
      console.log('Feedback submitted', { rating, comment });
      // In real app, would submit and navigate back
      navigation.goBack();
    }
  };

  return (
    <ScrollView style={styles.container} contentContainerStyle={styles.contentContainer}>
      <Text style={styles.title}>Rate Your Experience</Text>
      <Text style={styles.subtitle}>
        How was your experience with {hustler.name}?
      </Text>

      <View style={styles.taskCard}>
        <Text style={styles.taskTitle}>{hustler.taskTitle}</Text>
      </View>

      <View style={styles.ratingSection}>
        <Text style={styles.ratingLabel}>Rating</Text>
        <View style={styles.starsContainer}>
          {[1, 2, 3, 4, 5].map((star) => (
            <TouchableOpacity
              key={star}
              onPress={() => setRating(star)}
              style={styles.starButton}
            >
              <Text style={[styles.star, star <= (rating || 0) && styles.starFilled]}>
                ⭐
              </Text>
            </TouchableOpacity>
          ))}
        </View>
      </View>

      <View style={styles.commentSection}>
        <Text style={styles.commentLabel}>Comments (Optional)</Text>
        <View style={styles.commentInput}>
          <Text style={styles.commentPlaceholder}>
            {comment || 'Share your feedback...'}
          </Text>
        </View>
      </View>

      <TouchableOpacity
        style={[styles.submitButton, !rating && styles.submitButtonDisabled]}
        onPress={handleSubmit}
        disabled={!rating}
      >
        <Text style={styles.submitButtonText}>Submit Feedback</Text>
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
    marginBottom: SPACING[2],
    textAlign: 'center',
  },
  subtitle: {
    fontSize: FONT_SIZE.base,
    color: NEUTRAL.TEXT_SECONDARY,
    textAlign: 'center',
    marginBottom: SPACING[6],
  },
  taskCard: {
    backgroundColor: NEUTRAL.BACKGROUND_SECONDARY,
    padding: SPACING[4],
    borderRadius: RADIUS.lg,
    marginBottom: SPACING[6],
  },
  taskTitle: {
    fontSize: FONT_SIZE.lg,
    fontWeight: FONT_WEIGHT.semibold,
    color: NEUTRAL.TEXT,
  },
  ratingSection: {
    marginBottom: SPACING[6],
    alignItems: 'center',
  },
  ratingLabel: {
    fontSize: FONT_SIZE.base,
    fontWeight: FONT_WEIGHT.semibold,
    color: NEUTRAL.TEXT,
    marginBottom: SPACING[3],
  },
  starsContainer: {
    flexDirection: 'row',
    justifyContent: 'center',
  },
  starButton: {
    padding: SPACING[2],
  },
  star: {
    fontSize: FONT_SIZE['3xl'],
    color: NEUTRAL.BORDER,
  },
  starFilled: {
    color: '#FCD34D',
  },
  commentSection: {
    marginBottom: SPACING[6],
  },
  commentLabel: {
    fontSize: FONT_SIZE.base,
    fontWeight: FONT_WEIGHT.semibold,
    color: NEUTRAL.TEXT,
    marginBottom: SPACING[2],
  },
  commentInput: {
    minHeight: 120,
    backgroundColor: NEUTRAL.BACKGROUND_SECONDARY,
    borderRadius: RADIUS.md,
    padding: SPACING[3],
    borderWidth: 1,
    borderColor: NEUTRAL.BORDER,
  },
  commentPlaceholder: {
    fontSize: FONT_SIZE.base,
    color: NEUTRAL.TEXT_TERTIARY,
  },
  submitButton: {
    width: '100%',
    padding: SPACING[3],
    backgroundColor: '#10B981',
    borderRadius: RADIUS.md,
    alignItems: 'center',
  },
  submitButtonDisabled: {
    backgroundColor: NEUTRAL.DISABLED,
  },
  submitButtonText: {
    color: NEUTRAL.TEXT_INVERSE,
    fontSize: FONT_SIZE.lg,
    fontWeight: FONT_WEIGHT.semibold,
  },
});
