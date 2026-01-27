/**
 * TaskCreationScreen - Post a new task
 */

import React, { useState } from 'react';
import { View, StyleSheet, ScrollView, TouchableOpacity, Alert } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { useNavigation } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import { Text, Spacing, Card, Button, Input } from '../../components';
import { theme } from '../../theme';
import { useTaskStore, useAuthStore, Task, TaskCategory } from '../../store';
import type { RootStackParamList } from '../../navigation/types';

type NavigationProp = NativeStackNavigationProp<RootStackParamList>;

const CATEGORIES: { id: TaskCategory; label: string; emoji: string }[] = [
  { id: 'moving', label: 'Moving', emoji: '📦' },
  { id: 'cleaning', label: 'Cleaning', emoji: '🧹' },
  { id: 'delivery', label: 'Delivery', emoji: '🚚' },
  { id: 'assembly', label: 'Assembly', emoji: '🔧' },
  { id: 'handyman', label: 'Handyman', emoji: '🔨' },
  { id: 'yard_work', label: 'Yard', emoji: '🌱' },
  { id: 'pet_care', label: 'Pet Care', emoji: '🐕' },
  { id: 'errands', label: 'Errands', emoji: '🏃' },
  { id: 'tech_help', label: 'Tech', emoji: '💻' },
  { id: 'other', label: 'Other', emoji: '📋' },
];

export function TaskCreationScreen() {
  const insets = useSafeAreaInsets();
  const navigation = useNavigation<NavigationProp>();
  const { addTask } = useTaskStore();
  const { user } = useAuthStore();
  
  const [title, setTitle] = useState('');
  const [description, setDescription] = useState('');
  const [minPrice, setMinPrice] = useState('');
  const [maxPrice, setMaxPrice] = useState('');
  const [category, setCategory] = useState<TaskCategory | ''>('');
  const [address, setAddress] = useState('');
  const [duration, setDuration] = useState('60');
  const [posting, setPosting] = useState(false);

  const handleBack = () => navigation.goBack();

  const handlePost = async () => {
    if (!title || !description || !maxPrice || !category) {
      Alert.alert('Missing Info', 'Please fill in all required fields.');
      return;
    }

    setPosting(true);

    // Create new task
    const newTask: Task = {
      id: `task_${Date.now()}`,
      title,
      description,
      category: category as TaskCategory,
      status: 'open',
      posterId: user?.id || 'poster_1',
      posterName: user?.name || 'You',
      address: address || '123 Main St, Seattle, WA',
      latitude: 47.6062,
      longitude: -122.3321,
      minPay: parseInt(minPrice, 10) || parseInt(maxPrice, 10),
      maxPay: parseInt(maxPrice, 10),
      baseXP: Math.round(parseInt(maxPrice, 10) * 2),
      estimatedMinutes: parseInt(duration, 10),
      requiredTrustTier: 1,
      requiresVehicle: ['moving', 'delivery'].includes(category),
      requiresTools: [],
      requiresBackground: false,
    };

    // Add to store
    addTask(newTask);

    setPosting(false);

    // Navigate to review
    Alert.alert(
      'Task Posted! 🎉',
      'Your task is now live. Hustlers will be notified.',
      [
        {
          text: 'View My Tasks',
          onPress: () => navigation.navigate('PosterHome'),
        },
        {
          text: 'Post Another',
          onPress: () => {
            setTitle('');
            setDescription('');
            setMinPrice('');
            setMaxPrice('');
            setCategory('');
            setAddress('');
          },
        },
      ]
    );
  };

  return (
    <View style={[styles.container, { paddingTop: insets.top, paddingBottom: insets.bottom }]}>
      {/* Back button */}
      <TouchableOpacity style={styles.backButton} onPress={handleBack}>
        <Text variant="body" color="primary">← Back</Text>
      </TouchableOpacity>

      <ScrollView contentContainerStyle={styles.scroll} keyboardShouldPersistTaps="handled">
        <Text variant="title1" color="primary">Post a Task</Text>
        <Spacing size={8} />
        <Text variant="body" color="secondary">
          Describe what you need help with
        </Text>

        <Spacing size={24} />

        <Card variant="default" padding="lg">
          <Input
            label="Task Title *"
            placeholder="e.g., Help moving furniture"
            value={title}
            onChangeText={setTitle}
          />

          <Spacing size={16} />

          <Input
            label="Description *"
            placeholder="Describe the task in detail..."
            value={description}
            onChangeText={setDescription}
            multiline
            numberOfLines={4}
          />

          <Spacing size={16} />

          <Text variant="headline" color="primary">Category *</Text>
          <Spacing size={12} />
          <View style={styles.categories}>
            {CATEGORIES.map(cat => (
              <TouchableOpacity
                key={cat.id}
                style={[styles.categoryBtn, category === cat.id && styles.categoryBtnActive]}
                onPress={() => setCategory(cat.id)}
              >
                <Text variant="body">{cat.emoji}</Text>
                <Text variant="caption" color={category === cat.id ? 'inverse' : 'primary'}>
                  {cat.label}
                </Text>
              </TouchableOpacity>
            ))}
          </View>
        </Card>

        <Spacing size={16} />

        <Card variant="default" padding="lg">
          <Text variant="headline" color="primary">Budget *</Text>
          <Spacing size={12} />
          <View style={styles.priceRow}>
            <View style={styles.priceInput}>
              <Input
                label="Min ($)"
                placeholder="30"
                value={minPrice}
                onChangeText={setMinPrice}
                keyboardType="numeric"
              />
            </View>
            <Text variant="body" color="secondary" style={styles.priceDash}>—</Text>
            <View style={styles.priceInput}>
              <Input
                label="Max ($)"
                placeholder="50"
                value={maxPrice}
                onChangeText={setMaxPrice}
                keyboardType="numeric"
              />
            </View>
          </View>

          <Spacing size={16} />

          <Input
            label="Estimated Duration (minutes)"
            placeholder="60"
            value={duration}
            onChangeText={setDuration}
            keyboardType="numeric"
          />
        </Card>

        <Spacing size={16} />

        <Card variant="default" padding="lg">
          <Input
            label="Location"
            placeholder="Address or area"
            value={address}
            onChangeText={setAddress}
          />
        </Card>

        <Spacing size={16} />

        <Card variant="default" padding="md">
          <Text variant="footnote" color="secondary">
            💡 Tip: Be specific about what you need. Tasks with clear descriptions get completed faster.
          </Text>
        </Card>

        <Spacing size={80} />
      </ScrollView>

      <View style={styles.footer}>
        <Button
          variant="primary"
          size="lg"
          onPress={handlePost}
          disabled={!title || !description || !maxPrice || !category}
          loading={posting}
        >
          {`Post Task${maxPrice ? ` — $${maxPrice}` : ''}`}
        </Button>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: theme.colors.surface.primary },
  backButton: { padding: theme.spacing[4], paddingBottom: 0 },
  scroll: { padding: theme.spacing[4] },
  categories: { flexDirection: 'row', flexWrap: 'wrap', gap: theme.spacing[2] },
  categoryBtn: { 
    paddingHorizontal: theme.spacing[3],
    paddingVertical: theme.spacing[2],
    backgroundColor: theme.colors.surface.secondary,
    borderRadius: theme.radii.sm,
    alignItems: 'center',
    minWidth: 70,
  },
  categoryBtnActive: {
    backgroundColor: theme.colors.brand.primary,
  },
  priceRow: { flexDirection: 'row', alignItems: 'center' },
  priceInput: { flex: 1 },
  priceDash: { marginHorizontal: theme.spacing[2], marginTop: 20 },
  footer: { padding: theme.spacing[4], borderTopWidth: 1, borderTopColor: theme.colors.surface.secondary },
});

export default TaskCreationScreen;
