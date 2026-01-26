/**
 * DisputeEntryScreen - Open a dispute
 */

import React, { useState } from 'react';
import { View, StyleSheet, ScrollView, TouchableOpacity } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { Text, Spacing, Card, Button, Input } from '../../components';
import { theme } from '../../theme';

const REASONS = [
  { id: 'incomplete', label: 'Task not completed' },
  { id: 'quality', label: 'Quality issues' },
  { id: 'no_show', label: 'Hustler didn\'t show up' },
  { id: 'different', label: 'Different than described' },
  { id: 'damage', label: 'Property damage' },
  { id: 'other', label: 'Other' },
];

export function DisputeEntryScreen() {
  const insets = useSafeAreaInsets();
  const [reason, setReason] = useState<string | null>(null);
  const [details, setDetails] = useState('');

  const handleSubmit = () => {
    console.log('Submit dispute:', { reason, details });
  };

  return (
    <View style={[styles.container, { paddingTop: insets.top, paddingBottom: insets.bottom }]}>
      <ScrollView contentContainerStyle={styles.scroll}>
        <Text variant="title1" color="primary">Report an Issue</Text>
        <Spacing size={8} />
        <Text variant="body" color="secondary">
          We're sorry something went wrong. Let us know what happened.
        </Text>

        <Spacing size={24} />

        <Card variant="default" padding="md">
          <Text variant="footnote" color="secondary">
            ⚠️ Opening a dispute will pause the payment until resolved. Our team will review within 24-48 hours.
          </Text>
        </Card>

        <Spacing size={24} />

        <Text variant="headline" color="primary">What went wrong?</Text>
        <Spacing size={12} />
        
        {REASONS.map(r => (
          <TouchableOpacity
            key={r.id}
            style={[styles.reasonBtn, reason === r.id && styles.reasonBtnActive]}
            onPress={() => setReason(r.id)}
          >
            <Text variant="body" color={reason === r.id ? 'primary' : 'secondary'}>{r.label}</Text>
            {reason === r.id && <Text variant="body" color="brand">✓</Text>}
          </TouchableOpacity>
        ))}

        <Spacing size={24} />

        <Input
          label="Tell us more"
          placeholder="Please describe the issue in detail..."
          value={details}
          onChangeText={setDetails}
          multiline
          numberOfLines={4}
        />
      </ScrollView>

      <View style={styles.footer}>
        <Button
          variant="danger"
          size="lg"
          onPress={handleSubmit}
          disabled={!reason || !details.trim()}
        >
          Submit Dispute
        </Button>
        <Spacing size={12} />
        <Button variant="ghost" size="sm" onPress={() => console.log('cancel')}>
          Cancel
        </Button>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: theme.colors.surface.primary },
  scroll: { padding: theme.spacing[4] },
  reasonBtn: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    padding: theme.spacing[4],
    backgroundColor: theme.colors.surface.secondary,
    borderRadius: theme.radii.md,
    marginBottom: theme.spacing[2],
    borderWidth: 2,
    borderColor: 'transparent',
  },
  reasonBtnActive: { borderColor: theme.colors.brand.primary },
  footer: { padding: theme.spacing[4], borderTopWidth: 1, borderTopColor: theme.colors.surface.secondary },
});

export default DisputeEntryScreen;
