/**
 * WorkEligibilityScreen - Unlock more tasks
 * 
 * CHOSEN-STATE: Progression, not gatekeeping
 * One decision per item: Start verification?
 */

import React from 'react';
import { View, StyleSheet, Pressable, ScrollView } from 'react-native';
import { useNavigation } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import Animated, {
  useSharedValue,
  useAnimatedStyle,
  withSpring,
} from 'react-native-reanimated';
import { HScreen, HText, HCard, HBadge } from '../../components/atoms';
import { hustleSpacing, hustleColors } from '../../theme/hustle-tokens';
import type { RootStackParamList } from '../../navigation/types';

type NavigationProp = NativeStackNavigationProp<RootStackParamList>;

type VerificationStatus = 'verified' | 'pending' | 'available';

type VerificationItem = {
  id: string;
  emoji: string;
  title: string;
  hint: string;
  status: VerificationStatus;
};

const VERIFICATIONS: VerificationItem[] = [
  { 
    id: 'identity', 
    emoji: '🪪', 
    title: 'Identity', 
    hint: 'Verified with ID',
    status: 'verified' 
  },
  { 
    id: 'background', 
    emoji: '🔍', 
    title: 'Background', 
    hint: 'Check in progress',
    status: 'pending' 
  },
  { 
    id: 'work', 
    emoji: '📋', 
    title: 'Work Auth', 
    hint: 'Tap to verify',
    status: 'available' 
  },
  { 
    id: 'insurance', 
    emoji: '🛡️', 
    title: 'Insurance', 
    hint: 'Unlock premium tasks',
    status: 'available' 
  },
];

export function WorkEligibilityScreen() {
  const navigation = useNavigation<NavigationProp>();

  const handleItemPress = (id: string, status: VerificationStatus) => {
    if (status === 'available') {
      // Would navigate to verification flow
      console.log('Start verification:', id);
    }
  };

  const verifiedCount = VERIFICATIONS.filter(v => v.status === 'verified').length;

  return (
    <HScreen ambient scroll={false}>
      <View style={styles.content}>
        <View style={styles.header}>
          <HText variant="title1">
            Your verifications
          </HText>
          <View style={styles.headerSpacer} />
          <HText variant="body" color="secondary">
            More verifications = more task types
          </HText>
        </View>

        <View style={styles.progress}>
          <HBadge variant="purple">
            {verifiedCount}/{VERIFICATIONS.length} complete
          </HBadge>
        </View>

        <ScrollView 
          style={styles.scroll} 
          contentContainerStyle={styles.list}
          showsVerticalScrollIndicator={false}
        >
          {VERIFICATIONS.map((item) => (
            <VerificationCard
              key={item.id}
              emoji={item.emoji}
              title={item.title}
              hint={item.hint}
              status={item.status}
              onPress={() => handleItemPress(item.id, item.status)}
            />
          ))}
        </ScrollView>

        <View style={styles.note}>
          <HText variant="caption" color="tertiary" center>
            🔒 Your data is encrypted and secure
          </HText>
        </View>
      </View>
    </HScreen>
  );
}

function VerificationCard({ 
  emoji, 
  title, 
  hint,
  status,
  onPress 
}: { 
  emoji: string; 
  title: string; 
  hint: string;
  status: VerificationStatus;
  onPress: () => void;
}) {
  const scale = useSharedValue(1);

  const handlePressIn = () => {
    if (status === 'available') {
      scale.value = withSpring(0.98, { damping: 20, stiffness: 400 });
    }
  };

  const handlePressOut = () => {
    scale.value = withSpring(1, { damping: 15, stiffness: 400 });
  };

  const animatedStyle = useAnimatedStyle(() => ({
    transform: [{ scale: scale.value }],
  }));

  const statusConfig = {
    verified: { badge: 'Verified', variant: 'success' as const, icon: '✓' },
    pending: { badge: 'Pending', variant: 'warning' as const, icon: '⏳' },
    available: { badge: 'Start', variant: 'purple' as const, icon: '→' },
  };

  const config = statusConfig[status];

  return (
    <Pressable
      onPress={onPress}
      onPressIn={handlePressIn}
      onPressOut={handlePressOut}
      disabled={status !== 'available'}
    >
      <Animated.View style={animatedStyle}>
        <HCard 
          variant={status === 'verified' ? 'success' : 'default'} 
          padding="lg"
        >
          <View style={styles.cardContent}>
            <HText variant="title2">{emoji}</HText>
            <View style={styles.cardText}>
              <HText 
                variant="headline" 
                color={status === 'verified' ? 'success' : 'primary'}
              >
                {title}
              </HText>
              <HText variant="caption" color="tertiary">
                {hint}
              </HText>
            </View>
            <HBadge variant={config.variant} size="sm">
              {config.badge}
            </HBadge>
          </View>
        </HCard>
      </Animated.View>
    </Pressable>
  );
}

const styles = StyleSheet.create({
  content: {
    flex: 1,
  },
  header: {
    paddingTop: hustleSpacing.lg,
  },
  headerSpacer: {
    height: hustleSpacing.sm,
  },
  progress: {
    marginTop: hustleSpacing.lg,
    alignItems: 'flex-start',
  },
  scroll: {
    flex: 1,
    marginTop: hustleSpacing.xl,
  },
  list: {
    gap: hustleSpacing.md,
    paddingBottom: hustleSpacing['2xl'],
  },
  cardContent: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: hustleSpacing.lg,
  },
  cardText: {
    flex: 1,
  },
  note: {
    paddingVertical: hustleSpacing.lg,
  },
});

export default WorkEligibilityScreen;
