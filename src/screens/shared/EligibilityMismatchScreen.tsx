/**
 * EligibilityMismatchScreen - Can't accept task due to missing requirements
 */

import React from 'react';
import { View, StyleSheet, ScrollView } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { useNavigation } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import type { RootStackParamList } from '../../navigation/types';

type NavigationProp = NativeStackNavigationProp<RootStackParamList>;
import { Text, Spacing, Card, Button } from '../../components';
import { theme } from '../../theme';

export function EligibilityMismatchScreen() {
  const insets = useSafeAreaInsets();
  const navigation = useNavigation<NavigationProp>();

  return (
    <View style={[styles.container, { paddingTop: insets.top, paddingBottom: insets.bottom }]}>
      <ScrollView contentContainerStyle={styles.scroll}>
        <View style={styles.header}>
          <Text variant="hero">🚫</Text>
          <Spacing size={16} />
          <Text variant="title1" color="primary" align="center">Can't Accept This Task</Text>
          <Spacing size={8} />
          <Text variant="body" color="secondary" align="center">
            This task requires qualifications you haven't verified yet.
          </Text>
        </View>

        <Spacing size={32} />

        {/* Task Info */}
        <Card variant="default" padding="md">
          <Text variant="headline" color="primary">Task: Electrical repair</Text>
          <Text variant="footnote" color="secondary">Requires licensed electrician</Text>
        </Card>

        <Spacing size={24} />

        {/* Missing Requirements */}
        <Text variant="headline" color="primary">Missing Requirements</Text>
        <Spacing size={12} />

        <RequirementItem
          title="Licensed Electrician"
          description="This task requires a valid electrician license"
          action="Add License"
        />
        <Spacing size={8} />
        <RequirementItem
          title="Liability Insurance"
          description="$1M minimum coverage required"
          action="Add Insurance"
        />

        <Spacing size={24} />

        <Card variant="default" padding="md">
          <Text variant="footnote" color="secondary">
            💡 Once you add these qualifications, you'll be able to access premium tasks like this one with higher pay.
          </Text>
        </Card>
      </ScrollView>

      <View style={styles.footer}>
        <Button variant="primary" size="lg" onPress={() => console.log('verify')}>
          Complete Verification
        </Button>
        <Spacing size={12} />
        <Button variant="ghost" size="sm" onPress={() => console.log('browse')}>
          Browse Other Tasks
        </Button>
      </View>
    </View>
  );
}

function RequirementItem({ title, description, action }: {
  title: string;
  description: string;
  action: string;
}) {
  return (
    <Card variant="default" padding="md">
      <View style={styles.reqRow}>
        <View style={styles.reqInfo}>
          <Text variant="headline" color="danger">❌ {title}</Text>
          <Text variant="footnote" color="secondary">{description}</Text>
        </View>
        <Button variant="secondary" size="sm" onPress={() => console.log(action)}>
          {action}
        </Button>
      </View>
    </Card>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: theme.colors.surface.primary },
  scroll: { padding: theme.spacing[4] },
  header: { alignItems: 'center' },
  reqRow: { flexDirection: 'row', alignItems: 'center' },
  reqInfo: { flex: 1 },
  footer: { padding: theme.spacing[4] },
});

export default EligibilityMismatchScreen;
