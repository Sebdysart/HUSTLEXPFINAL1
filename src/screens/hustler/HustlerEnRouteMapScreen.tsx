/**
 * HustlerEnRouteMapScreen - Navigation to task
 * 
 * Archetype C: Task Lifecycle (Map Screen)
 * - Map is background, status card overlays
 * - "On the way" feeling
 * - CTA: "I'm here"
 */

import React from 'react';
import { View, StyleSheet } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { useNavigation, useRoute, RouteProp } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import {
  HCard,
  HText,
  HBadge,
  HButton,
  HActivityIndicator,
} from '../../components/atoms';
import { hustleColors, hustleSpacing } from '../../theme/hustle-tokens';
import { useTaskStore } from '../../store';
import type { RootStackParamList } from '../../navigation/types';

type NavigationProp = NativeStackNavigationProp<RootStackParamList>;
type RouteProps = RouteProp<RootStackParamList, 'HustlerEnRouteMap'>;

export function HustlerEnRouteMapScreen() {
  const insets = useSafeAreaInsets();
  const navigation = useNavigation<NavigationProp>();
  const route = useRoute<RouteProps>();
  const { taskId } = route.params;

  const { tasks, updateTask } = useTaskStore();
  const task = tasks.find(t => t.id === taskId);

  const handleArrived = () => {
    if (task) {
      updateTask(taskId, { status: 'arrived' });
      navigation.navigate('TaskInProgress', { taskId });
    }
  };

  const handleMessage = () => {
    navigation.navigate('TaskConversation', { taskId });
  };

  const handleOpenMaps = () => {
    // TODO: Deep link to maps app
    console.log('Open external maps');
  };

  return (
    <View style={[styles.container, { paddingTop: insets.top }]}>
      {/* Map Background */}
      <View style={styles.mapContainer}>
        <View style={styles.mapPlaceholder}>
          <HText variant="title2" color="tertiary">🗺️</HText>
          <HText variant="body" color="tertiary">Map View</HText>
          <View style={styles.spacer} />
          <HActivityIndicator active label="Loading route..." />
        </View>
      </View>

      {/* Status Card Overlay */}
      <View style={[styles.overlay, { paddingBottom: insets.bottom + 16 }]}>
        <HCard variant="elevated" padding="lg">
          {/* Status Row */}
          <View style={styles.statusRow}>
            <HBadge variant="purple" pulsing dot>
              On the way
            </HBadge>
            <HText variant="headline" color="primary">~12 min</HText>
          </View>

          <View style={styles.spacerLg} />

          {/* Task Info - minimal */}
          <HText variant="title3" color="primary">
            {task?.title || 'Task'}
          </HText>
          <View style={styles.spacerSm} />
          <HText variant="body" color="secondary">
            📍 {task?.address || 'Loading...'}
          </HText>

          <View style={styles.spacerLg} />

          {/* Poster Info */}
          <View style={styles.posterRow}>
            <View style={styles.avatar}>
              <HText variant="body">👤</HText>
            </View>
            <View style={styles.posterInfo}>
              <HText variant="body" color="primary">
                {task?.posterName || 'Poster'}
              </HText>
              <HText variant="caption" color="tertiary">
                Ready for you
              </HText>
            </View>
            <HButton variant="secondary" size="sm" onPress={handleMessage}>
              Message
            </HButton>
          </View>

          <View style={styles.spacerLg} />

          {/* Primary CTA */}
          <HButton variant="primary" size="lg" fullWidth onPress={handleArrived}>
            I'm here
          </HButton>

          <View style={styles.spacerMd} />

          {/* Secondary action */}
          <HButton variant="ghost" size="sm" onPress={handleOpenMaps}>
            Open in Maps
          </HButton>
        </HCard>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: hustleColors.dark.void,
  },
  mapContainer: {
    flex: 1,
  },
  mapPlaceholder: {
    flex: 1,
    backgroundColor: hustleColors.dark.surface,
    justifyContent: 'center',
    alignItems: 'center',
  },
  overlay: {
    position: 'absolute',
    bottom: 0,
    left: 0,
    right: 0,
    padding: hustleSpacing.lg,
  },
  statusRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  posterRow: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  avatar: {
    width: 44,
    height: 44,
    borderRadius: 22,
    backgroundColor: hustleColors.dark.surface,
    justifyContent: 'center',
    alignItems: 'center',
  },
  posterInfo: {
    flex: 1,
    marginLeft: hustleSpacing.md,
  },
  spacer: { height: hustleSpacing.md },
  spacerSm: { height: hustleSpacing.sm },
  spacerMd: { height: hustleSpacing.md },
  spacerLg: { height: hustleSpacing.xl },
});

export default HustlerEnRouteMapScreen;
