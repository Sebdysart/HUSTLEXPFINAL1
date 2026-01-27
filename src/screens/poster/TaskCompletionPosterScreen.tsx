/**
 * TaskCompletionPosterScreen - Task completed confirmation for poster
 */

import React from 'react';
import { View, StyleSheet } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
// import { useNavigation } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import type { RootStackParamList } from '../../navigation/types';

// type NavigationProp = NativeStackNavigationProp<RootStackParamList>;
import { Text, Spacing, Card, Button, MoneyDisplay, TrustBadge } from '../../components';
import { theme } from '../../theme';

export function TaskCompletionPosterScreen() {
  const insets = useSafeAreaInsets();
  // Navigation available via useNavigation<NavigationProp>() when needed

  return (
    <View style={[styles.container, { paddingTop: insets.top, paddingBottom: insets.bottom }]}>
      <View style={styles.content}>
        <View style={styles.celebration}>
          <Text variant="hero">✅</Text>
          <Spacing size={16} />
          <Text variant="hero" color="primary" align="center">Task Complete!</Text>
          <Spacing size={8} />
          <Text variant="body" color="secondary" align="center">
            Payment has been released to John
          </Text>
        </View>

        <Spacing size={32} />

        <Card variant="elevated" padding="lg">
          <View style={styles.row}>
            <Text variant="body" color="secondary">Task</Text>
            <Text variant="body" color="primary">Help moving furniture</Text>
          </View>
          <Spacing size={12} />
          <View style={styles.row}>
            <Text variant="body" color="secondary">Amount Paid</Text>
            <MoneyDisplay amount={75} size="md" />
          </View>
          <Spacing size={12} />
          <View style={styles.row}>
            <Text variant="body" color="secondary">Your Rating</Text>
            <Text variant="body" color="primary">⭐⭐⭐⭐⭐</Text>
          </View>
        </Card>

        <Spacing size={24} />

        <Card variant="default" padding="md">
          <Text variant="headline" color="primary" align="center">Hustler</Text>
          <Spacing size={12} />
          <View style={styles.hustlerInfo}>
            <View style={styles.avatar}>
              <Text variant="title2">👤</Text>
            </View>
            <Spacing size={12} />
            <Text variant="headline" color="primary">John D.</Text>
            <TrustBadge level={3} xp={2600} size="sm" />
          </View>
        </Card>

        <Spacing size={24} />

        <Text variant="body" color="secondary" align="center">
          Thanks for using HustleXP! Your feedback helps build trust in our community.
        </Text>
      </View>

      <View style={styles.footer}>
        <Button variant="primary" size="lg" onPress={() => console.log('post another')}>
          Post Another Task
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
  row: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center' },
  hustlerInfo: { alignItems: 'center' },
  avatar: { 
    width: 64, 
    height: 64, 
    borderRadius: 32, 
    backgroundColor: theme.colors.surface.tertiary, 
    justifyContent: 'center', 
    alignItems: 'center' 
  },
  footer: { padding: theme.spacing[4] },
});

export default TaskCompletionPosterScreen;
