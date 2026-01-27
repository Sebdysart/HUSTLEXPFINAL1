/**
 * HustlerOnWayScreen - Poster watching hustler arrive
 * 
 * Archetype C: Task Lifecycle (Map Screen)
 * - Map is background, status card overlays
 * - "On the way" - confident, no anxiety
 * - System handles it
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
  HTrustBadge,
} from '../../components/atoms';
import { hustleColors, hustleSpacing } from '../../theme/hustle-tokens';
import { useTaskStore } from '../../store';
import type { RootStackParamList } from '../../navigation/types';

type NavigationProp = NativeStackNavigationProp<RootStackParamList>;
type RouteProps = RouteProp<RootStackParamList, 'HustlerOnWay'>;

export function HustlerOnWayScreen() {
  const insets = useSafeAreaInsets();
  const navigation = useNavigation<NavigationProp>();
  const route = useRoute<RouteProps>();
  const { taskId } = route.params || {};

  const { tasks } = useTaskStore();
  const task = taskId ? tasks.find(t => t.id === taskId) : null;

  const handleMessage = () => {
    if (taskId) {
      navigation.navigate('TaskConversation', { taskId });
    }
  };

  // Mock hustler data - would come from task in real app
  const hustler = {
    name: 'John D.',
    rating: 4.9,
    tasks: 47,
    tier: 3,
    xp: 2600,
  };

  return (
    <View style={[styles.container, { paddingTop: insets.top }]}>
      {/* Map Background */}
      <View style={styles.mapContainer}>
        <View style={styles.mapPlaceholder}>
          <HText variant="title2" color="tertiary">🗺️</HText>
          <HText variant="body" color="tertiary">Live Tracking</HText>
          <View style={styles.spacer} />
          <HActivityIndicator active label="Tracking..." />
        </View>
      </View>

      {/* Status Card Overlay */}
      <View style={[styles.overlay, { paddingBottom: insets.bottom + 16 }]}>
        <HCard variant="elevated" padding="lg">
          {/* Status - confident, not anxious */}
          <View style={styles.statusCenter}>
            <HBadge variant="purple" size="lg" pulsing>
              On the way
            </HBadge>
            <View style={styles.spacerSm} />
            <HText variant="title2" color="primary">~8 min</HText>
          </View>

          <View style={styles.spacerLg} />

          {/* Task Reference */}
          <HText variant="headline" color="primary">
            {task?.title || 'Help moving furniture'}
          </HText>

          <View style={styles.spacerLg} />

          {/* Hustler Info */}
          <HCard variant="default" padding="md">
            <View style={styles.hustlerRow}>
              <View style={styles.avatar}>
                <HText variant="title2">👤</HText>
              </View>
              <View style={styles.hustlerInfo}>
                <HText variant="headline" color="primary">{hustler.name}</HText>
                <HText variant="caption" color="secondary">
                  ⭐ {hustler.rating} • {hustler.tasks} tasks
                </HText>
              </View>
              <HTrustBadge tier={hustler.tier} size="sm" />
            </View>
          </HCard>

          <View style={styles.spacerLg} />

          {/* Actions */}
          <View style={styles.actionsRow}>
            <HButton 
              variant="secondary" 
              size="md" 
              onPress={handleMessage}
              style={styles.actionBtn}
            >
              Message
            </HButton>
            <View style={styles.actionSpacer} />
            <HButton 
              variant="secondary" 
              size="md" 
              onPress={() => console.log('call')}
              style={styles.actionBtn}
            >
              Call
            </HButton>
          </View>

          <View style={styles.spacerMd} />

          {/* Reassurance - system handles it */}
          <HText variant="caption" color="tertiary" center>
            You'll be notified when {hustler.name.split(' ')[0]} arrives
          </HText>
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
  statusCenter: {
    alignItems: 'center',
  },
  hustlerRow: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  avatar: {
    width: 52,
    height: 52,
    borderRadius: 26,
    backgroundColor: hustleColors.dark.surface,
    justifyContent: 'center',
    alignItems: 'center',
  },
  hustlerInfo: {
    flex: 1,
    marginLeft: hustleSpacing.md,
  },
  actionsRow: {
    flexDirection: 'row',
  },
  actionBtn: {
    flex: 1,
  },
  actionSpacer: {
    width: hustleSpacing.md,
  },
  spacer: { height: hustleSpacing.md },
  spacerSm: { height: hustleSpacing.sm },
  spacerMd: { height: hustleSpacing.md },
  spacerLg: { height: hustleSpacing.xl },
});

export default HustlerOnWayScreen;
