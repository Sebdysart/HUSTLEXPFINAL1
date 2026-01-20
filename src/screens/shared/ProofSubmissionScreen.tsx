import React, { useState } from 'react';
import { View, Text, StyleSheet, ScrollView, TouchableOpacity, Image, TextInput } from 'react-native';
import { NEUTRAL, SPACING, FONT_SIZE, FONT_WEIGHT, RADIUS } from '../../constants';

export function ProofSubmissionScreen() {
  const [proofImage, setProofImage] = useState<string | null>(null);
  const [description, setDescription] = useState('');

  // Stub data
  const task = {
    title: 'Fix Leaky Faucet',
  };

  const handleUploadPhoto = () => {
    console.log('Upload Photo button pressed');
    // In real app, would open camera/gallery
    setProofImage('https://via.placeholder.com/300');
  };

  const handleSubmit = () => {
    if (proofImage) {
      console.log('Submit proof:', { description });
      // In real app, would submit proof
    }
  };

  return (
    <ScrollView style={styles.container} contentContainerStyle={styles.contentContainer}>
      <Text style={styles.title}>Submit Proof of Completion</Text>
      <Text style={styles.subtitle}>Task: {task.title}</Text>

      <View style={styles.uploadSection}>
        <Text style={styles.sectionTitle}>Photo</Text>
        {proofImage ? (
          <View style={styles.imageContainer}>
            <Image source={{ uri: proofImage }} style={styles.proofImage} />
            <TouchableOpacity onPress={() => setProofImage(null)}>
              <Text style={styles.removeText}>Remove Photo</Text>
            </TouchableOpacity>
          </View>
        ) : (
          <TouchableOpacity style={styles.uploadButton} onPress={handleUploadPhoto}>
            <Text style={styles.uploadButtonText}>Upload Photo</Text>
          </TouchableOpacity>
        )}
      </View>

      <View style={styles.descriptionSection}>
        <Text style={styles.sectionTitle}>Description (Optional)</Text>
        <TextInput
          style={styles.descriptionInput}
          placeholder="Add any notes about the completion..."
          value={description}
          onChangeText={setDescription}
          multiline
          numberOfLines={4}
          placeholderTextColor={NEUTRAL.TEXT_TERTIARY}
        />
      </View>

      <TouchableOpacity
        style={[styles.submitButton, !proofImage && styles.submitButtonDisabled]}
        onPress={handleSubmit}
        disabled={!proofImage}
      >
        <Text style={styles.submitButtonText}>Submit Proof</Text>
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
  uploadSection: {
    marginBottom: SPACING[6],
  },
  sectionTitle: {
    fontSize: FONT_SIZE.lg,
    fontWeight: FONT_WEIGHT.semibold,
    color: NEUTRAL.TEXT,
    marginBottom: SPACING[3],
  },
  uploadButton: {
    padding: SPACING[6],
    backgroundColor: NEUTRAL.BACKGROUND_SECONDARY,
    borderRadius: RADIUS.lg,
    alignItems: 'center',
    borderWidth: 2,
    borderColor: NEUTRAL.BORDER,
    borderStyle: 'dashed',
  },
  uploadButtonText: {
    fontSize: FONT_SIZE.base,
    color: NEUTRAL.TEXT_SECONDARY,
  },
  imageContainer: {
    alignItems: 'center',
  },
  proofImage: {
    width: '100%',
    height: 300,
    borderRadius: RADIUS.md,
    marginBottom: SPACING[3],
    resizeMode: 'cover',
  },
  removeText: {
    fontSize: FONT_SIZE.sm,
    color: '#EF4444',
    textDecorationLine: 'underline',
  },
  descriptionSection: {
    marginBottom: SPACING[6],
  },
  descriptionInput: {
    minHeight: 120,
    padding: SPACING[3],
    backgroundColor: NEUTRAL.BACKGROUND_SECONDARY,
    borderRadius: RADIUS.md,
    fontSize: FONT_SIZE.base,
    color: NEUTRAL.TEXT,
    textAlignVertical: 'top',
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
