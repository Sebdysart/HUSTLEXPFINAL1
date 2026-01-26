/**
 * HustlerOnWayScreen - Poster view of hustler en route
 */

import React from 'react';
import { View, StyleSheet } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { Text, Spacing, Card, Button, TrustBadge } from '../../components';
import { theme } from '../../theme';

export function HustlerOnWayScreen() {
  const insets = useSafeAreaInsets();

  return (
    <View style={[styles.container, { paddingTop: insets.top, paddingBottom: insets.bottom }]}>
      {/* Map Placeholder */}
      <View style={styles.mapContainer}>
        <View style={styles.mapPlaceholder}>
          <Text variant="title2" color="secondary">🗺️</Text>
          <Text variant="body" color="secondary">Live Tracking</Text>
        </View>
      </View>

      {/* Bottom Card */}
      <View style={styles.bottomSheet}>
        <Card variant="elevated" padding="lg">
          <View style={styles.etaBadge}>
            <Text variant="headline" color="inverse">Arriving in ~8 min</Text>
          </View>

          <Spacing size={20} />

          <Text variant="headline" color="primary">Help moving furniture</Text>
          <Spacing size={4} />
          <Text variant="body" color="secondary">Your hustler is on the way!</Text>

          <Spacing size={20} />

          {/* Hustler Info */}
          <View style={styles.hustlerRow}>
            <View style={styles.avatar}>
              <Text variant="title2">👤</Text>
            </View>
            <View style={styles.hustlerInfo}>
              <Text variant="headline" color="primary">John D.</Text>
              <View style={styles.ratingRow}>
                <Text variant="footnote" color="secondary">⭐ 4.9 • 47 tasks</Text>
              </View>
            </View>
            <TrustBadge level={3} xp={2600} size="sm" />
          </View>

          <Spacing size={16} />

          <View style={styles.actions}>
            <Button variant="secondary" size="md" onPress={() => console.log('message')} style={styles.actionBtn}>
              Message
            </Button>
            <View style={styles.spacer} />
            <Button variant="secondary" size="md" onPress={() => console.log('call')} style={styles.actionBtn}>
              Call
            </Button>
          </View>

          <Spacing size={16} />

          <Card variant="default" padding="sm">
            <Text variant="footnote" color="secondary" align="center">
              🔔 You'll be notified when John arrives
            </Text>
          </Card>
        </Card>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: theme.colors.surface.primary },
  mapContainer: { flex: 1 },
  mapPlaceholder: { 
    flex: 1, 
    backgroundColor: theme.colors.surface.secondary, 
    justifyContent: 'center', 
    alignItems: 'center' 
  },
  bottomSheet: { padding: theme.spacing[4] },
  etaBadge: { 
    backgroundColor: theme.colors.brand.primary, 
    paddingVertical: theme.spacing[3],
    paddingHorizontal: theme.spacing[4],
    borderRadius: theme.radii.md,
    alignItems: 'center',
  },
  hustlerRow: { flexDirection: 'row', alignItems: 'center' },
  avatar: { 
    width: 56, 
    height: 56, 
    borderRadius: 28, 
    backgroundColor: theme.colors.surface.tertiary, 
    justifyContent: 'center', 
    alignItems: 'center' 
  },
  hustlerInfo: { flex: 1, marginLeft: theme.spacing[3] },
  ratingRow: { flexDirection: 'row', alignItems: 'center' },
  actions: { flexDirection: 'row' },
  actionBtn: { flex: 1 },
  spacer: { width: theme.spacing[3] },
});

export default HustlerOnWayScreen;
