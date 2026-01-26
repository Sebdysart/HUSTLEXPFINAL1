/**
 * TaskCompletionHustlerScreen - Task completed celebration
 */

import React from 'react';
import { View, StyleSheet } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { Text, Spacing, Card, MoneyDisplay, Button, TrustBadge } from '../../components';
import { theme } from '../../theme';

export function TaskCompletionHustlerScreen() {
  const insets = useSafeAreaInsets();

  return (
    <View style={[styles.container, { paddingTop: insets.top, paddingBottom: insets.bottom }]}>
      <View style={styles.content}>
        <View style={styles.celebration}>
          <Text variant="hero">🎉</Text>
          <Spacing size={16} />
          <Text variant="hero" color="primary" align="center">Task Complete!</Text>
          <Spacing size={8} />
          <Text variant="body" color="secondary" align="center">
            Great job! Your payment is being processed.
          </Text>
        </View>

        <Spacing size={32} />

        <Card variant="elevated" padding="lg">
          <View style={styles.earningsRow}>
            <Text variant="body" color="secondary">You earned</Text>
            <MoneyDisplay amount={75} size="lg" />
          </View>
          <Spacing size={16} />
          <View style={styles.xpRow}>
            <Text variant="body" color="secondary">XP Earned</Text>
            <Text variant="title2" color="brand">+150 XP</Text>
          </View>
        </Card>

        <Spacing size={24} />

        <Card variant="default" padding="md">
          <Text variant="headline" color="primary">Level Progress</Text>
          <Spacing size={12} />
          <TrustBadge level={3} xp={2600} size="md" showProgress nextLevelXp={3000} />
          <Spacing size={8} />
          <Text variant="caption" color="secondary" align="center">400 XP to Level 4</Text>
        </Card>

        <Spacing size={24} />

        <Text variant="body" color="secondary" align="center">
          Your rating request has been sent to Sarah M.
        </Text>
      </View>

      <View style={styles.footer}>
        <Button variant="primary" size="lg" onPress={() => console.log('find more')}>
          Find More Tasks
        </Button>
        <Spacing size={12} />
        <Button variant="ghost" size="sm" onPress={() => console.log('home')}>
          Go Home
        </Button>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: theme.colors.surface.primary },
  content: { flex: 1, padding: theme.spacing[4], justifyContent: 'center' },
  celebration: { alignItems: 'center' },
  earningsRow: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center' },
  xpRow: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center' },
  footer: { padding: theme.spacing[4] },
});

export default TaskCompletionHustlerScreen;
