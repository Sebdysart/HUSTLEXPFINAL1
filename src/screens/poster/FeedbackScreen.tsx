/**
 * FeedbackScreen - App feedback form
 */

import React, { useState } from 'react';
import { View, StyleSheet, ScrollView, TouchableOpacity } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { useNavigation } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import type { RootStackParamList } from '../../navigation/types';

type NavigationProp = NativeStackNavigationProp<RootStackParamList>;
import { Text, Spacing, Button, Input } from '../../components';
import { theme } from '../../theme';

const FEEDBACK_TYPES = [
  { id: 'bug', emoji: '🐛', label: 'Bug Report' },
  { id: 'feature', emoji: '💡', label: 'Feature Request' },
  { id: 'general', emoji: '💬', label: 'General Feedback' },
  { id: 'complaint', emoji: '😤', label: 'Complaint' },
];

export function FeedbackScreen() {
  const insets = useSafeAreaInsets();
  // Navigation available via useNavigation<NavigationProp>() when needed
  const [type, setType] = useState<string | null>(null);
  const [message, setMessage] = useState('');
  const [submitted, setSubmitted] = useState(false);

  const handleSubmit = () => {
    console.log('Submit feedback:', { type, message });
    setSubmitted(true);
  };

  if (submitted) {
    return (
      <View style={[styles.container, { paddingTop: insets.top, paddingBottom: insets.bottom }]}>
        <View style={styles.successContent}>
          <Text variant="hero">✅</Text>
          <Spacing size={16} />
          <Text variant="title1" color="primary" align="center">Thanks!</Text>
          <Spacing size={8} />
          <Text variant="body" color="secondary" align="center">
            Your feedback helps us improve HustleXP for everyone.
          </Text>
          <Spacing size={32} />
          <Button variant="primary" size="lg" onPress={() => console.log('go back')}>
            Done
          </Button>
        </View>
      </View>
    );
  }

  return (
    <View style={[styles.container, { paddingTop: insets.top, paddingBottom: insets.bottom }]}>
      <ScrollView contentContainerStyle={styles.scroll}>
        <Text variant="title1" color="primary">Send Feedback</Text>
        <Spacing size={8} />
        <Text variant="body" color="secondary">
          We'd love to hear from you
        </Text>

        <Spacing size={24} />

        <Text variant="headline" color="primary">What's this about?</Text>
        <Spacing size={12} />
        <View style={styles.types}>
          {FEEDBACK_TYPES.map(t => (
            <TouchableOpacity
              key={t.id}
              style={[styles.typeBtn, type === t.id && styles.typeBtnActive]}
              onPress={() => setType(t.id)}
            >
              <Text variant="title3">{t.emoji}</Text>
              <Text variant="caption" color={type === t.id ? 'primary' : 'secondary'}>{t.label}</Text>
            </TouchableOpacity>
          ))}
        </View>

        <Spacing size={24} />

        <Input
          label="Your message"
          placeholder="Tell us what's on your mind..."
          value={message}
          onChangeText={setMessage}
          multiline
          numberOfLines={6}
        />

        <Spacing size={16} />

        <Text variant="footnote" color="tertiary">
          Your feedback is anonymous unless you include contact info.
        </Text>
      </ScrollView>

      <View style={styles.footer}>
        <Button
          variant="primary"
          size="lg"
          onPress={handleSubmit}
          disabled={!type || !message.trim()}
        >
          Send Feedback
        </Button>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: theme.colors.surface.primary },
  scroll: { padding: theme.spacing[4] },
  successContent: { flex: 1, justifyContent: 'center', alignItems: 'center', padding: theme.spacing[4] },
  types: { flexDirection: 'row', flexWrap: 'wrap', gap: theme.spacing[2] },
  typeBtn: {
    width: '48%',
    alignItems: 'center',
    padding: theme.spacing[4],
    backgroundColor: theme.colors.surface.secondary,
    borderRadius: theme.radii.md,
    borderWidth: 2,
    borderColor: 'transparent',
  },
  typeBtnActive: { borderColor: theme.colors.brand.primary },
  footer: { padding: theme.spacing[4], borderTopWidth: 1, borderTopColor: theme.colors.surface.secondary },
});

export default FeedbackScreen;
