/**
 * TrustTierLockedScreen - Feature locked until higher trust level
 */

import React from 'react';
import { View, StyleSheet } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
// import { useNavigation } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import type { RootStackParamList } from '../../navigation/types';

// type NavigationProp = NativeStackNavigationProp<RootStackParamList>;
import { Text, Spacing, Card, Button, TrustBadge } from '../../components';
import { theme } from '../../theme';

export function TrustTierLockedScreen() {
  const insets = useSafeAreaInsets();
  // Navigation available when needed via useNavigation<NavigationProp>()

  return (
    <View style={[styles.container, { paddingTop: insets.top, paddingBottom: insets.bottom }]}>
      <View style={styles.content}>
        <Text variant="hero">🔒</Text>
        <Spacing size={24} />
        <Text variant="title1" color="primary" align="center">Feature Locked</Text>
        <Spacing size={8} />
        <Text variant="body" color="secondary" align="center">
          You need to reach a higher trust level to access this feature.
        </Text>

        <Spacing size={32} />

        {/* Current vs Required */}
        <Card variant="elevated" padding="lg">
          <View style={styles.levelRow}>
            <View style={styles.levelItem}>
              <Text variant="caption" color="secondary">Your Level</Text>
              <Spacing size={8} />
              <TrustBadge level={2} xp={850} size="md" />
            </View>
            <Text variant="title2" color="tertiary">→</Text>
            <View style={styles.levelItem}>
              <Text variant="caption" color="secondary">Required</Text>
              <Spacing size={8} />
              <TrustBadge level={4} xp={3000} size="md" />
            </View>
          </View>
        </Card>

        <Spacing size={24} />

        {/* How to level up */}
        <Card variant="default" padding="md">
          <Text variant="headline" color="primary">How to reach Level 4:</Text>
          <Spacing size={12} />
          <Text variant="body" color="secondary">• Complete more tasks (+100-200 XP each)</Text>
          <Text variant="body" color="secondary">• Earn 5-star ratings (+50 XP each)</Text>
          <Text variant="body" color="secondary">• Maintain high completion rate</Text>
          <Spacing size={12} />
          <Text variant="caption" color="tertiary">You need 2,150 more XP</Text>
        </Card>
      </View>

      <View style={styles.footer}>
        <Button variant="primary" size="lg" onPress={() => console.log('find tasks')}>
          Find Tasks to Level Up
        </Button>
        <Spacing size={12} />
        <Button variant="ghost" size="sm" onPress={() => console.log('back')}>
          Go Back
        </Button>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: theme.colors.surface.primary },
  content: { flex: 1, padding: theme.spacing[4], justifyContent: 'center', alignItems: 'center' },
  levelRow: { flexDirection: 'row', justifyContent: 'space-around', alignItems: 'center', width: '100%' },
  levelItem: { alignItems: 'center' },
  footer: { padding: theme.spacing[4] },
});

export default TrustTierLockedScreen;
