/**
 * ActiveTaskScreen - Currently working on a task
 */

import React, { useState } from 'react';
import { View, StyleSheet, ScrollView } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { useNavigation } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import type { RootStackParamList } from '../../navigation/types';

type NavigationProp = NativeStackNavigationProp<RootStackParamList>;
import { Text, Spacing, Card, MoneyDisplay, Button } from '../../components';
import { theme } from '../../theme';

export function TaskInProgressScreen() {
  const insets = useSafeAreaInsets();
  const navigation = useNavigation<NavigationProp>();
  const [status, setStatus] = useState<'in_progress' | 'proof_submitted'>('in_progress');

  return (
    <View style={[styles.container, { paddingTop: insets.top, paddingBottom: insets.bottom }]}>
      <ScrollView contentContainerStyle={styles.scroll}>
        {/* Status Banner */}
        <View style={[styles.statusBanner, status === 'proof_submitted' && styles.statusPending]}>
          <Text variant="headline" color="inverse">
            {status === 'in_progress' ? '🔨 Task In Progress' : '⏳ Awaiting Approval'}
          </Text>
        </View>

        <Spacing size={20} />

        {/* Task Info */}
        <Text variant="title1" color="primary">Help moving furniture</Text>
        <Spacing size={4} />
        <Text variant="footnote" color="secondary">For Sarah M. • Started 45 min ago</Text>

        <Spacing size={20} />

        {/* Payment Info */}
        <Card variant="default" padding="md">
          <View style={styles.paymentRow}>
            <Text variant="body" color="secondary">You'll earn</Text>
            <MoneyDisplay amount={75} size="lg" />
          </View>
          <Spacing size={4} />
          <Text variant="caption" color="tertiary">Released after poster approves</Text>
        </Card>

        <Spacing size={20} />

        {/* Checklist */}
        <Text variant="headline" color="primary">Task Checklist</Text>
        <Spacing size={12} />
        <ChecklistItem text="Arrive at location" done />
        <ChecklistItem text="Move couch to truck" done />
        <ChecklistItem text="Move chairs to truck" done={false} />
        <ChecklistItem text="Confirm with poster" done={false} />

        <Spacing size={20} />

        {/* Contact */}
        <Card variant="default" padding="md">
          <Text variant="headline" color="primary">Need help?</Text>
          <Spacing size={8} />
          <View style={styles.contactRow}>
            <Button variant="secondary" size="sm" onPress={() => {}}>Message Sarah</Button>
            <Button variant="ghost" size="sm" onPress={() => {}}>Report Issue</Button>
          </View>
        </Card>
      </ScrollView>

      {/* CTA */}
      <View style={styles.footer}>
        {status === 'in_progress' ? (
          <Button variant="primary" size="lg" onPress={() => setStatus('proof_submitted')}>
            Submit Proof of Completion
          </Button>
        ) : (
          <View style={styles.pendingFooter}>
            <Text variant="body" color="secondary" align="center">
              Waiting for Sarah to review and approve...
            </Text>
          </View>
        )}
      </View>
    </View>
  );
}

function ChecklistItem({ text, done }: { text: string; done: boolean }) {
  return (
    <View style={styles.checklistItem}>
      <Text variant="body">{done ? '✅' : '⬜'}</Text>
      <Text variant="body" color={done ? 'secondary' : 'primary'} style={styles.checklistText}>{text}</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: theme.colors.surface.primary },
  scroll: { padding: theme.spacing[4] },
  statusBanner: { backgroundColor: theme.colors.brand.primary, padding: theme.spacing[4], borderRadius: theme.radii.md, alignItems: 'center' },
  statusPending: { backgroundColor: theme.colors.semantic.warning },
  paymentRow: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center' },
  checklistItem: { flexDirection: 'row', alignItems: 'center', marginBottom: theme.spacing[3] },
  checklistText: { marginLeft: theme.spacing[3] },
  contactRow: { flexDirection: 'row', gap: theme.spacing[3] },
  footer: { padding: theme.spacing[4], borderTopWidth: 1, borderTopColor: theme.colors.surface.secondary },
  pendingFooter: { paddingVertical: theme.spacing[2] },
});

export default TaskInProgressScreen;
