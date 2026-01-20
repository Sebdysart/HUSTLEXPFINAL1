import React, { useState } from 'react';
import { View, Text, StyleSheet, ScrollView, TouchableOpacity, TextInput } from 'react-native';
import { NEUTRAL, SPACING, FONT_SIZE, FONT_WEIGHT, RADIUS } from '../../constants';

export function DisputeScreen() {
  const [disputeReason, setDisputeReason] = useState<string | null>(null);
  const [description, setDescription] = useState('');
  const [evidenceImages, setEvidenceImages] = useState<string[]>([]);

  // Stub data
  const task = {
    title: 'Fix Leaky Faucet',
  };

  const disputeReasons = [
    'Work not completed',
    'Work quality issues',
    'Worker didn\'t show up',
    'Payment issue',
    'Safety concern',
    'Other',
  ];

  const handleSelectReason = (reason: string) => {
    setDisputeReason(reason);
  };

  const handleUploadEvidence = () => {
    console.log('Upload evidence button pressed');
    // In real app, would open camera/gallery
    setEvidenceImages([...evidenceImages, 'https://via.placeholder.com/300']);
  };

  const handleSubmit = () => {
    if (disputeReason && description) {
      console.log('Submit dispute:', { disputeReason, description, evidenceImages });
      // In real app, would submit dispute
    }
  };

  return (
    <ScrollView style={styles.container} contentContainerStyle={styles.contentContainer}>
      <Text style={styles.title}>File a Dispute</Text>
      <Text style={styles.subtitle}>Task: {task.title}</Text>

      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Dispute Reason *</Text>
        {disputeReasons.map((reason) => (
          <TouchableOpacity
            key={reason}
            style={[
              styles.reasonButton,
              disputeReason === reason && styles.reasonButtonSelected,
            ]}
            onPress={() => handleSelectReason(reason)}
          >
            <Text
              style={[
                styles.reasonText,
                disputeReason === reason && styles.reasonTextSelected,
              ]}
            >
              {reason}
            </Text>
          </TouchableOpacity>
        ))}
      </View>

      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Description *</Text>
        <TextInput
          style={styles.descriptionInput}
          placeholder="Describe the issue in detail..."
          value={description}
          onChangeText={setDescription}
          multiline
          numberOfLines={6}
          placeholderTextColor={NEUTRAL.TEXT_TERTIARY}
        />
      </View>

      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Evidence (Optional)</Text>
        <TouchableOpacity style={styles.uploadButton} onPress={handleUploadEvidence}>
          <Text style={styles.uploadButtonText}>Upload Photo Evidence</Text>
        </TouchableOpacity>
        {evidenceImages.length > 0 && (
          <Text style={styles.evidenceCount}>{evidenceImages.length} photo(s) uploaded</Text>
        )}
      </View>

      <View style={styles.infoCard}>
        <Text style={styles.infoTitle}>What happens next?</Text>
        <Text style={styles.infoText}>
          Your dispute will be reviewed by our support team. We'll contact you within 24-48 hours to resolve the issue.
        </Text>
      </View>

      <TouchableOpacity
        style={[
          styles.submitButton,
          (!disputeReason || !description) && styles.submitButtonDisabled,
        ]}
        onPress={handleSubmit}
        disabled={!disputeReason || !description}
      >
        <Text style={styles.submitButtonText}>Submit Dispute</Text>
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
  section: {
    marginBottom: SPACING[6],
  },
  sectionTitle: {
    fontSize: FONT_SIZE.lg,
    fontWeight: FONT_WEIGHT.semibold,
    color: NEUTRAL.TEXT,
    marginBottom: SPACING[3],
  },
  reasonButton: {
    padding: SPACING[3],
    backgroundColor: NEUTRAL.BACKGROUND_SECONDARY,
    borderRadius: RADIUS.md,
    marginBottom: SPACING[2],
    borderWidth: 1,
    borderColor: NEUTRAL.BORDER,
  },
  reasonButtonSelected: {
    backgroundColor: '#D1FAE5',
    borderColor: '#10B981',
    borderWidth: 2,
  },
  reasonText: {
    fontSize: FONT_SIZE.base,
    color: NEUTRAL.TEXT,
  },
  reasonTextSelected: {
    color: '#10B981',
    fontWeight: FONT_WEIGHT.semibold,
  },
  descriptionInput: {
    minHeight: 150,
    padding: SPACING[3],
    backgroundColor: NEUTRAL.BACKGROUND_SECONDARY,
    borderRadius: RADIUS.md,
    fontSize: FONT_SIZE.base,
    color: NEUTRAL.TEXT,
    textAlignVertical: 'top',
  },
  uploadButton: {
    padding: SPACING[3],
    backgroundColor: NEUTRAL.BACKGROUND_SECONDARY,
    borderRadius: RADIUS.md,
    alignItems: 'center',
    borderWidth: 1,
    borderColor: NEUTRAL.BORDER,
  },
  uploadButtonText: {
    fontSize: FONT_SIZE.base,
    color: NEUTRAL.TEXT_SECONDARY,
  },
  evidenceCount: {
    fontSize: FONT_SIZE.sm,
    color: NEUTRAL.TEXT_SECONDARY,
    marginTop: SPACING[2],
  },
  infoCard: {
    backgroundColor: '#D1FAE5',
    padding: SPACING[4],
    borderRadius: RADIUS.lg,
    marginBottom: SPACING[6],
    borderWidth: 1,
    borderColor: '#10B981',
  },
  infoTitle: {
    fontSize: FONT_SIZE.lg,
    fontWeight: FONT_WEIGHT.semibold,
    color: NEUTRAL.TEXT,
    marginBottom: SPACING[2],
  },
  infoText: {
    fontSize: FONT_SIZE.base,
    color: NEUTRAL.TEXT,
  },
  submitButton: {
    width: '100%',
    padding: SPACING[3],
    backgroundColor: '#EF4444',
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
