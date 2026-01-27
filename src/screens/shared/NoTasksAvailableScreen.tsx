/**
 * NoTasksAvailableScreen - Empty state for task feed
 */

import React from 'react';
import { View, StyleSheet } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { useNavigation } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import type { RootStackParamList } from '../../navigation/types';

type NavigationProp = NativeStackNavigationProp<RootStackParamList>;
import { Text, Spacing, Button, Card } from '../../components';
import { theme } from '../../theme';

export function NoTasksAvailableScreen() {
  const insets = useSafeAreaInsets();
  // Navigation available via useNavigation<NavigationProp>() when needed

  return (
    <View style={[styles.container, { paddingTop: insets.top, paddingBottom: insets.bottom }]}>
      <View style={styles.content}>
        <Text variant="hero">🔍</Text>
        <Spacing size={24} />
        <Text variant="title1" color="primary" align="center">No Tasks Nearby</Text>
        <Spacing size={8} />
        <Text variant="body" color="secondary" align="center">
          There aren't any available tasks in your area right now.
        </Text>

        <Spacing size={32} />

        <Card variant="default" padding="lg">
          <Text variant="headline" color="primary">What you can do:</Text>
          <Spacing size={12} />
          <SuggestionItem emoji="📍" text="Expand your service area" />
          <SuggestionItem emoji="🔔" text="Enable notifications for new tasks" />
          <SuggestionItem emoji="📋" text="Add more skills to your profile" />
          <SuggestionItem emoji="⏰" text="Check back later - tasks are posted throughout the day" />
        </Card>

        <Spacing size={32} />

        <Button variant="primary" size="lg" onPress={() => console.log('expand area')}>
          Expand Search Area
        </Button>
        <Spacing size={12} />
        <Button variant="secondary" size="md" onPress={() => console.log('notify')}>
          Notify Me When Tasks Appear
        </Button>
      </View>
    </View>
  );
}

function SuggestionItem({ emoji, text }: { emoji: string; text: string }) {
  return (
    <View style={styles.suggestion}>
      <Text variant="body">{emoji}</Text>
      <Text variant="body" color="secondary" style={styles.suggestionText}>{text}</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: theme.colors.surface.primary },
  content: { flex: 1, padding: theme.spacing[4], justifyContent: 'center', alignItems: 'center' },
  suggestion: { flexDirection: 'row', marginBottom: theme.spacing[3] },
  suggestionText: { marginLeft: theme.spacing[3], flex: 1 },
});

export default NoTasksAvailableScreen;
