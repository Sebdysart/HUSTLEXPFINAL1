/**
 * HustlerEnRouteMapScreen - Navigation to task location
 */

import React from 'react';
import { View, StyleSheet } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { useNavigation } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import type { RootStackParamList } from '../../navigation/types';

type NavigationProp = NativeStackNavigationProp<RootStackParamList>;
import { Text, Spacing, Card, Button } from '../../components';
import { theme } from '../../theme';

export function HustlerEnRouteMapScreen() {
  const insets = useSafeAreaInsets();
  const navigation = useNavigation<NavigationProp>();

  return (
    <View style={[styles.container, { paddingTop: insets.top, paddingBottom: insets.bottom }]}>
      {/* Map Placeholder */}
      <View style={styles.mapContainer}>
        <View style={styles.mapPlaceholder}>
          <Text variant="title2" color="secondary">🗺️</Text>
          <Text variant="body" color="secondary">Map View</Text>
          <Text variant="caption" color="tertiary">Navigation integration pending</Text>
        </View>
      </View>

      {/* Bottom Card */}
      <View style={styles.bottomSheet}>
        <Card variant="elevated" padding="lg">
          <View style={styles.header}>
            <View style={styles.statusBadge}>
              <Text variant="caption" color="inverse">En Route</Text>
            </View>
            <Text variant="caption" color="secondary">ETA: 12 min</Text>
          </View>

          <Spacing size={16} />

          <Text variant="headline" color="primary">Help moving furniture</Text>
          <Spacing size={4} />
          <Text variant="body" color="secondary">123 Main St, Apt 2B</Text>

          <Spacing size={16} />

          <View style={styles.posterInfo}>
            <View style={styles.avatar}>
              <Text variant="body">👤</Text>
            </View>
            <View style={styles.posterText}>
              <Text variant="body" color="primary">Sarah M.</Text>
              <Text variant="caption" color="secondary">Waiting for you</Text>
            </View>
            <Button variant="secondary" size="sm" onPress={() => console.log('message')}>
              Message
            </Button>
          </View>

          <Spacing size={16} />

          <View style={styles.actions}>
            <Button variant="primary" size="lg" onPress={() => console.log('arrived')} style={styles.actionBtn}>
              I've Arrived
            </Button>
          </View>

          <Spacing size={12} />

          <Button variant="ghost" size="sm" onPress={() => console.log('navigate')}>
            Open in Maps App
          </Button>
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
  header: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center' },
  statusBadge: { 
    backgroundColor: theme.colors.brand.primary, 
    paddingHorizontal: theme.spacing[3], 
    paddingVertical: theme.spacing[1], 
    borderRadius: theme.radii.full 
  },
  posterInfo: { flexDirection: 'row', alignItems: 'center' },
  avatar: { 
    width: 40, 
    height: 40, 
    borderRadius: 20, 
    backgroundColor: theme.colors.surface.tertiary, 
    justifyContent: 'center', 
    alignItems: 'center' 
  },
  posterText: { flex: 1, marginLeft: theme.spacing[3] },
  actions: { flexDirection: 'row' },
  actionBtn: { flex: 1 },
});

export default HustlerEnRouteMapScreen;
