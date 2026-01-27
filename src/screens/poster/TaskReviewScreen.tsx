/**
 * TaskReviewScreen - Review and approve completed task
 */

import React, { useState } from 'react';
import { View, StyleSheet, ScrollView, TouchableOpacity } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { useNavigation } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import type { RootStackParamList } from '../../navigation/types';

type NavigationProp = NativeStackNavigationProp<RootStackParamList>;
import { Text, Spacing, Card, Button, MoneyDisplay, Input } from '../../components';
import { theme } from '../../theme';

export function TaskReviewScreen() {
  const insets = useSafeAreaInsets();
  // Navigation available via useNavigation<NavigationProp>() when needed
  const [rating, setRating] = useState(0);
  const [review, setReview] = useState('');

  const handleApprove = () => {
    console.log('Approve task:', { rating, review });
  };

  const handleDispute = () => {
    console.log('Open dispute');
  };

  return (
    <View style={[styles.container, { paddingTop: insets.top, paddingBottom: insets.bottom }]}>
      <ScrollView contentContainerStyle={styles.scroll}>
        <Text variant="title1" color="primary">Review Task</Text>
        <Spacing size={8} />
        <Text variant="body" color="secondary">
          John has marked this task as complete
        </Text>

        <Spacing size={24} />

        {/* Task Summary */}
        <Card variant="default" padding="md">
          <Text variant="headline" color="primary">Help moving furniture</Text>
          <Spacing size={8} />
          <View style={styles.row}>
            <Text variant="body" color="secondary">Payment:</Text>
            <MoneyDisplay amount={75} size="sm" />
          </View>
          <View style={styles.row}>
            <Text variant="body" color="secondary">Hustler:</Text>
            <Text variant="body" color="primary">John D.</Text>
          </View>
          <View style={styles.row}>
            <Text variant="body" color="secondary">Duration:</Text>
            <Text variant="body" color="primary">1h 45m</Text>
          </View>
        </Card>

        <Spacing size={24} />

        {/* Proof of Completion */}
        <Text variant="headline" color="primary">Proof of Completion</Text>
        <Spacing size={12} />
        <Card variant="default" padding="md">
          <View style={styles.proofPlaceholder}>
            <Text variant="body" color="secondary">📷 Photo evidence</Text>
            <Text variant="caption" color="tertiary">(Image placeholder)</Text>
          </View>
        </Card>

        <Spacing size={24} />

        {/* Rating */}
        <Text variant="headline" color="primary">Rate John's Work</Text>
        <Spacing size={12} />
        <View style={styles.stars}>
          {[1, 2, 3, 4, 5].map(star => (
            <TouchableOpacity key={star} onPress={() => setRating(star)}>
              <Text variant="hero">{star <= rating ? '⭐' : '☆'}</Text>
            </TouchableOpacity>
          ))}
        </View>

        <Spacing size={20} />

        {/* Review */}
        <Input
          label="Leave a review (optional)"
          placeholder="How was your experience?"
          value={review}
          onChangeText={setReview}
          multiline
          numberOfLines={3}
        />
      </ScrollView>

      <View style={styles.footer}>
        <Button variant="ghost" size="sm" onPress={handleDispute}>
          Report an Issue
        </Button>
        <Spacing size={12} />
        <Button
          variant="primary"
          size="lg"
          onPress={handleApprove}
          disabled={rating === 0}
        >
          Approve & Release Payment
        </Button>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: theme.colors.surface.primary },
  scroll: { padding: theme.spacing[4] },
  row: { flexDirection: 'row', justifyContent: 'space-between', marginBottom: theme.spacing[2] },
  proofPlaceholder: { 
    height: 150, 
    backgroundColor: theme.colors.surface.secondary, 
    borderRadius: theme.radii.md,
    justifyContent: 'center',
    alignItems: 'center',
  },
  stars: { flexDirection: 'row', justifyContent: 'center', gap: theme.spacing[2] },
  footer: { padding: theme.spacing[4], borderTopWidth: 1, borderTopColor: theme.colors.surface.secondary },
});

export default TaskReviewScreen;
