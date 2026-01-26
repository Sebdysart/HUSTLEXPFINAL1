/**
 * TaskDetailScreen - Full task details and accept flow
 */

import React from 'react';
import { View, StyleSheet, ScrollView } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { Text, Spacing, Card, MoneyDisplay, Button, TrustBadge } from '../../components';
import { theme } from '../../theme';

export function TaskDetailScreen() {
  const insets = useSafeAreaInsets();

  return (
    <View style={[styles.container, { paddingTop: insets.top, paddingBottom: insets.bottom }]}>
      <ScrollView contentContainerStyle={styles.scroll}>
        {/* Header */}
        <Text variant="title1" color="primary">Help moving furniture</Text>
        <Spacing size={4} />
        <View style={styles.meta}>
          <Text variant="footnote" color="secondary">📍 0.8 mi away</Text>
          <Text variant="footnote" color="secondary">⏱️ Est. 2 hours</Text>
        </View>

        <Spacing size={20} />

        {/* Price Card */}
        <Card variant="elevated" padding="lg">
          <View style={styles.priceRow}>
            <Text variant="body" color="secondary">Task Payment</Text>
            <MoneyDisplay amount={75} size="lg" />
          </View>
          <Spacing size={8} />
          <Text variant="caption" color="tertiary">Payment held in escrow until completion</Text>
        </Card>

        <Spacing size={20} />

        {/* Description */}
        <Text variant="headline" color="primary">Description</Text>
        <Spacing size={8} />
        <Text variant="body" color="secondary">
          Need help moving a couch and two chairs from my apartment to a moving truck. 
          Items are on the 2nd floor, no elevator. Looking for someone strong who can help lift heavy items carefully.
        </Text>

        <Spacing size={20} />

        {/* Details */}
        <Text variant="headline" color="primary">Details</Text>
        <Spacing size={12} />
        <DetailRow label="Category" value="Moving & Lifting" />
        <DetailRow label="Date" value="Today, 3:00 PM" />
        <DetailRow label="Duration" value="~2 hours" />
        <DetailRow label="Location" value="123 Main St, Apt 2B" />

        <Spacing size={20} />

        {/* Poster Info */}
        <Text variant="headline" color="primary">Posted by</Text>
        <Spacing size={12} />
        <Card variant="default" padding="md">
          <View style={styles.posterRow}>
            <View style={styles.avatar}>
              <Text variant="title2">👤</Text>
            </View>
            <View style={styles.posterInfo}>
              <Text variant="headline" color="primary">Sarah M.</Text>
              <Text variant="footnote" color="secondary">12 tasks posted • 4.8 avg rating</Text>
            </View>
            <TrustBadge level={2} xp={850} size="sm" />
          </View>
        </Card>
      </ScrollView>

      {/* CTA */}
      <View style={styles.footer}>
        <Button variant="primary" size="lg" onPress={() => console.log('Accept task')}>
          Accept Task — $75
        </Button>
      </View>
    </View>
  );
}

function DetailRow({ label, value }: { label: string; value: string }) {
  return (
    <View style={styles.detailRow}>
      <Text variant="body" color="secondary">{label}</Text>
      <Text variant="body" color="primary">{value}</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: theme.colors.surface.primary },
  scroll: { padding: theme.spacing[4] },
  meta: { flexDirection: 'row', gap: theme.spacing[4] },
  priceRow: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center' },
  detailRow: { flexDirection: 'row', justifyContent: 'space-between', marginBottom: theme.spacing[3] },
  posterRow: { flexDirection: 'row', alignItems: 'center' },
  avatar: { width: 48, height: 48, borderRadius: 24, backgroundColor: theme.colors.surface.tertiary, justifyContent: 'center', alignItems: 'center' },
  posterInfo: { flex: 1, marginLeft: theme.spacing[3] },
  footer: { padding: theme.spacing[4], borderTopWidth: 1, borderTopColor: theme.colors.surface.secondary },
});

export default TaskDetailScreen;
