/**
 * WorkEligibilityScreen - Work eligibility verification
 */

import React from 'react';
import { View, StyleSheet, ScrollView } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
// import { useNavigation } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import type { RootStackParamList } from '../../navigation/types';

// type NavigationProp = NativeStackNavigationProp<RootStackParamList>;
import { Text, Spacing, Card, Button } from '../../components';
import { theme } from '../../theme';

export function WorkEligibilityScreen() {
  const insets = useSafeAreaInsets();
  // Navigation available via useNavigation<NavigationProp>() when needed

  return (
    <View style={[styles.container, { paddingTop: insets.top }]}>
      <ScrollView contentContainerStyle={styles.scroll}>
        <Text variant="title1" color="primary">Work Eligibility</Text>
        <Spacing size={8} />
        <Text variant="body" color="secondary">
          Complete verification to unlock more tasks
        </Text>

        <Spacing size={24} />

        <VerificationItem
          title="Identity Verification"
          description="Verify your identity with a government ID"
          status="verified"
        />
        <Spacing size={12} />
        <VerificationItem
          title="Background Check"
          description="Complete a background check for premium tasks"
          status="pending"
        />
        <Spacing size={12} />
        <VerificationItem
          title="Work Authorization"
          description="Confirm you're authorized to work"
          status="not_started"
        />
        <Spacing size={12} />
        <VerificationItem
          title="Vehicle Insurance"
          description="Add proof of vehicle insurance"
          status="not_started"
        />

        <Spacing size={24} />

        <Card variant="default" padding="md">
          <Text variant="footnote" color="secondary">
            🔒 Your documents are encrypted and stored securely. We only share verification status, never your actual documents.
          </Text>
        </Card>
      </ScrollView>
    </View>
  );
}

function VerificationItem({ title, description, status }: {
  title: string;
  description: string;
  status: 'verified' | 'pending' | 'not_started';
}) {
  const statusConfig = {
    verified: { icon: '✅', text: 'Verified', color: 'success' as const },
    pending: { icon: '⏳', text: 'Pending', color: 'warning' as const },
    not_started: { icon: '○', text: 'Not started', color: 'secondary' as const },
  };

  const config = statusConfig[status];

  return (
    <Card variant="default" padding="md">
      <View style={styles.itemRow}>
        <View style={styles.itemInfo}>
          <Text variant="headline" color="primary">{title}</Text>
          <Text variant="footnote" color="secondary">{description}</Text>
        </View>
        <View style={styles.itemStatus}>
          <Text variant="body">{config.icon}</Text>
          <Text variant="caption" color={config.color}>{config.text}</Text>
        </View>
      </View>
      {status === 'not_started' && (
        <>
          <Spacing size={12} />
          <Button variant="secondary" size="sm" onPress={() => {}}>
            Start Verification
          </Button>
        </>
      )}
    </Card>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: theme.colors.surface.primary },
  scroll: { padding: theme.spacing[4] },
  itemRow: { flexDirection: 'row', justifyContent: 'space-between' },
  itemInfo: { flex: 1 },
  itemStatus: { alignItems: 'flex-end' },
});

export default WorkEligibilityScreen;
