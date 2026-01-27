/**
 * DisputeEntryScreen - Open a dispute
 * 
 * Archetype: Interrupt
 * Emotion: "We'll help sort this out"
 * - Calm, factual tone
 * - Step by step guidance
 * - Never feels adversarial
 * - Never blame user
 * - Clear next steps
 */

import React, { useState } from 'react';
import { View, StyleSheet, ScrollView, TouchableOpacity } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { useNavigation } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import type { RootStackParamList } from '../../navigation/types';

import { HScreen, HCard, HText, HButton, HInput } from '../../components/atoms';
import { hustleColors, hustleSpacing, hustleRadii } from '../../theme/hustle-tokens';

type NavigationProp = NativeStackNavigationProp<RootStackParamList>;

const REASONS = [
  { id: 'incomplete', label: 'Task wasn\'t fully completed' },
  { id: 'quality', label: 'Quality didn\'t match expectations' },
  { id: 'no_show', label: 'Didn\'t arrive as scheduled' },
  { id: 'different', label: 'Different from the description' },
  { id: 'damage', label: 'Something was damaged' },
  { id: 'other', label: 'Something else' },
];

export function DisputeEntryScreen() {
  const insets = useSafeAreaInsets();
  const navigation = useNavigation<NavigationProp>();
  const [reason, setReason] = useState<string | null>(null);
  const [details, setDetails] = useState('');

  const handleBack = () => navigation.goBack();

  const handleSubmit = () => {
    console.log('Submit dispute:', { reason, details });
    // Navigate to confirmation or back
  };

  const canSubmit = reason && details.trim().length > 10;

  return (
    <HScreen ambient={false}>
      {/* Header */}
      <View style={[styles.header, { paddingTop: insets.top + hustleSpacing.sm }]}>
        <HButton variant="ghost" size="sm" onPress={handleBack}>
          ← Back
        </HButton>
      </View>

      <ScrollView 
        style={styles.scrollContainer}
        contentContainerStyle={styles.scroll}
      >
        {/* Title - calm, supportive */}
        <HText variant="title1" color="primary">Let us know what happened</HText>
        <HText variant="body" color="secondary" style={styles.subtitle}>
          We'll review this and get back to you within 24 hours.
        </HText>

        {/* Info card - neutral, informative */}
        <HCard variant="default" padding="md" style={styles.infoCard}>
          <HText variant="footnote" color="secondary">
            Payment is paused while we look into this. We'll work with both parties to find a fair resolution.
          </HText>
        </HCard>

        {/* Reason selection */}
        <HText variant="headline" color="primary" style={styles.sectionTitle}>
          What happened?
        </HText>
        
        {REASONS.map(r => (
          <TouchableOpacity
            key={r.id}
            style={[
              styles.reasonOption, 
              reason === r.id && styles.reasonOptionSelected
            ]}
            onPress={() => setReason(r.id)}
            activeOpacity={0.7}
          >
            <HText 
              variant="body" 
              color={reason === r.id ? 'primary' : 'secondary'}
            >
              {r.label}
            </HText>
            {reason === r.id && (
              <HText variant="body" color="primary">✓</HText>
            )}
          </TouchableOpacity>
        ))}

        {/* Details input */}
        <HText variant="headline" color="primary" style={styles.sectionTitle}>
          Tell us more
        </HText>
        <HInput
          placeholder="Please share the details so we can help..."
          value={details}
          onChangeText={setDetails}
          multiline
          numberOfLines={4}
          style={styles.detailsInput}
        />

        <HText variant="caption" color="tertiary" style={styles.hint}>
          The more context you provide, the faster we can help.
        </HText>
      </ScrollView>

      {/* Footer - calm actions */}
      <View style={[styles.footer, { paddingBottom: insets.bottom + hustleSpacing.lg }]}>
        <HButton
          variant="primary"
          size="lg"
          onPress={handleSubmit}
          disabled={!canSubmit}
          style={styles.submitBtn}
        >
          Submit for Review
        </HButton>
        <HButton 
          variant="ghost" 
          size="sm" 
          onPress={handleBack}
          style={styles.cancelBtn}
        >
          Cancel
        </HButton>
      </View>
    </HScreen>
  );
}

const styles = StyleSheet.create({
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: hustleSpacing.lg,
    paddingBottom: hustleSpacing.md,
  },
  scrollContainer: {
    flex: 1,
  },
  scroll: { 
    padding: hustleSpacing.lg,
    paddingTop: 0,
  },
  subtitle: {
    marginTop: hustleSpacing.sm,
    marginBottom: hustleSpacing.xl,
  },
  infoCard: {
    marginBottom: hustleSpacing.xl,
  },
  sectionTitle: {
    marginBottom: hustleSpacing.md,
  },
  reasonOption: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    padding: hustleSpacing.lg,
    backgroundColor: hustleColors.dark.elevated,
    borderRadius: hustleRadii.md,
    marginBottom: hustleSpacing.sm,
    borderWidth: 1,
    borderColor: hustleColors.dark.border,
  },
  reasonOptionSelected: {
    borderColor: hustleColors.purple.soft,
    backgroundColor: hustleColors.dark.surface,
  },
  detailsInput: {
    minHeight: 120,
    textAlignVertical: 'top',
  },
  hint: {
    marginTop: hustleSpacing.sm,
  },
  footer: { 
    padding: hustleSpacing.lg,
    borderTopWidth: 1,
    borderTopColor: hustleColors.dark.border,
  },
  submitBtn: {
    marginBottom: hustleSpacing.sm,
  },
  cancelBtn: {
    alignSelf: 'center',
  },
});

export default DisputeEntryScreen;
