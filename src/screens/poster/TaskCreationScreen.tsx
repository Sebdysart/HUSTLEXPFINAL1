/**
 * TaskCreationScreen - Post a new task
 */

import React, { useState } from 'react';
import { View, StyleSheet, ScrollView } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { Text, Spacing, Card, Button, Input } from '../../components';
import { theme } from '../../theme';

export function TaskCreationScreen() {
  const insets = useSafeAreaInsets();
  const [title, setTitle] = useState('');
  const [description, setDescription] = useState('');
  const [price, setPrice] = useState('');
  const [category, setCategory] = useState('');

  const handlePost = () => {
    console.log('Post task:', { title, description, price, category });
  };

  return (
    <View style={[styles.container, { paddingTop: insets.top, paddingBottom: insets.bottom }]}>
      <ScrollView contentContainerStyle={styles.scroll}>
        <Text variant="title1" color="primary">Post a Task</Text>
        <Spacing size={8} />
        <Text variant="body" color="secondary">
          Describe what you need help with
        </Text>

        <Spacing size={24} />

        <Card variant="default" padding="lg">
          <Input
            label="Task Title"
            placeholder="e.g., Help moving furniture"
            value={title}
            onChangeText={setTitle}
          />

          <Spacing size={16} />

          <Input
            label="Description"
            placeholder="Describe the task in detail..."
            value={description}
            onChangeText={setDescription}
            multiline
            numberOfLines={4}
          />

          <Spacing size={16} />

          <Input
            label="Your Budget ($)"
            placeholder="e.g., 50"
            value={price}
            onChangeText={setPrice}
            keyboardType="numeric"
          />

          <Spacing size={16} />

          <Text variant="headline" color="primary">Category</Text>
          <Spacing size={12} />
          <View style={styles.categories}>
            {['Moving', 'Cleaning', 'Delivery', 'Assembly', 'Tech', 'Other'].map(cat => (
              <Button
                key={cat}
                variant={category === cat ? 'primary' : 'secondary'}
                size="sm"
                onPress={() => setCategory(cat)}
                style={styles.categoryBtn}
              >
                {cat}
              </Button>
            ))}
          </View>
        </Card>

        <Spacing size={16} />

        <Card variant="default" padding="md">
          <Text variant="footnote" color="secondary">
            💡 Tip: Be specific about what you need. Tasks with clear descriptions get completed faster.
          </Text>
        </Card>
      </ScrollView>

      <View style={styles.footer}>
        <Button
          variant="primary"
          size="lg"
          onPress={handlePost}
          disabled={!title || !description || !price}
        >
          Post Task
        </Button>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: theme.colors.surface.primary },
  scroll: { padding: theme.spacing[4] },
  categories: { flexDirection: 'row', flexWrap: 'wrap', gap: theme.spacing[2] },
  categoryBtn: { marginBottom: theme.spacing[2] },
  footer: { padding: theme.spacing[4], borderTopWidth: 1, borderTopColor: theme.colors.surface.secondary },
});

export default TaskCreationScreen;
