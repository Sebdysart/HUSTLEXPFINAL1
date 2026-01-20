import React, { useState } from 'react';
import { Text, TextInput, StyleSheet, ScrollView, Button, TouchableOpacity } from 'react-native';
import { NEUTRAL, SPACING, RADIUS, FONT_SIZE, FONT_WEIGHT } from '../../constants';

export function TaskCreationScreen() {
  const [title, setTitle] = useState('');
  const [description, setDescription] = useState('');
  const [category] = useState('');
  const [location, setLocation] = useState('');
  const [price, setPrice] = useState('');

  const handlePost = () => {
    console.log('Post button pressed', { title, description, category, location, price });
  };

  const isFormValid = title.length >= 5 && description.length >= 20 && category && location && price;

  return (
    <ScrollView style={styles.container} contentContainerStyle={styles.contentContainer}>
      <Text style={styles.title}>Create Task</Text>
      
      <TextInput
        style={styles.input}
        placeholder="Task Title"
        value={title}
        onChangeText={setTitle}
      />
      
      <TextInput
        style={[styles.input, styles.textArea]}
        placeholder="Description"
        value={description}
        onChangeText={setDescription}
        multiline
        numberOfLines={4}
      />
      
      <TouchableOpacity style={styles.selector}>
        <Text style={styles.selectorText}>{category || 'Select Category'}</Text>
      </TouchableOpacity>
      
      <TextInput
        style={styles.input}
        placeholder="Location (placeholder)"
        value={location}
        onChangeText={setLocation}
      />
      
      <TextInput
        style={styles.input}
        placeholder="Price"
        value={price}
        onChangeText={setPrice}
        keyboardType="decimal-pad"
      />
      
      <Text style={styles.aiIndicator}>AI Assist: Available (placeholder)</Text>
      
      <Button title="Post Task" onPress={handlePost} disabled={!isFormValid} />
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
  input: {
    height: 48,
    borderWidth: 1,
    borderColor: NEUTRAL.BORDER,
    borderRadius: RADIUS.md,
    paddingHorizontal: SPACING[3],
    marginBottom: SPACING[4],
    fontSize: FONT_SIZE.base,
    color: NEUTRAL.TEXT,
  },
  textArea: {
    height: 120,
    paddingTop: SPACING[3],
    textAlignVertical: 'top',
  },
  selector: {
    height: 48,
    borderWidth: 1,
    borderColor: NEUTRAL.BORDER,
    borderRadius: RADIUS.md,
    paddingHorizontal: SPACING[3],
    marginBottom: SPACING[4],
    justifyContent: 'center',
    backgroundColor: NEUTRAL.BACKGROUND,
  },
  selectorText: {
    fontSize: FONT_SIZE.base,
    color: NEUTRAL.TEXT_SECONDARY,
  },
  aiIndicator: {
    fontSize: FONT_SIZE.sm,
    color: NEUTRAL.TEXT_SECONDARY,
    fontStyle: 'italic',
    marginBottom: SPACING[4],
  },
});
