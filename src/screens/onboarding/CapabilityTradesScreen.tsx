/**
 * CapabilityTradesScreen - Any certifications?
 * 
 * CHOSEN-STATE: Unlocking pro-tier tasks
 * One decision: Got credentials?
 */

import React, { useState } from 'react';
import { View, StyleSheet, Pressable, ScrollView } from 'react-native';
import { useNavigation } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import Animated, {
  useSharedValue,
  useAnimatedStyle,
  withSpring,
} from 'react-native-reanimated';
import { HScreen, HText, HButton, HCard, HBadge } from '../../components/atoms';
import { hustleSpacing } from '../../theme/hustle-tokens';
import type { RootStackParamList } from '../../navigation/types';

type NavigationProp = NativeStackNavigationProp<RootStackParamList>;

type TradeOption = {
  id: string;
  emoji: string;
  label: string;
  pro?: boolean;
};

const TRADES: TradeOption[] = [
  { id: 'plumber', emoji: '🔧', label: 'Plumber', pro: true },
  { id: 'electrician', emoji: '⚡', label: 'Electrician', pro: true },
  { id: 'hvac', emoji: '❄️', label: 'HVAC', pro: true },
  { id: 'contractor', emoji: '🏗️', label: 'Contractor', pro: true },
  { id: 'painter', emoji: '🎨', label: 'Painter' },
  { id: 'locksmith', emoji: '🔐', label: 'Locksmith', pro: true },
  { id: 'appliance', emoji: '🔌', label: 'Appliance' },
  { id: 'none', emoji: '✨', label: 'No certs yet' },
];

export function CapabilityTradesScreen() {
  const navigation = useNavigation<NavigationProp>();
  const [selected, setSelected] = useState<string[]>([]);

  const toggleTrade = (id: string) => {
    if (id === 'none') {
      setSelected(['none']);
    } else {
      setSelected(prev => {
        const filtered = prev.filter(i => i !== 'none');
        return filtered.includes(id) 
          ? filtered.filter(i => i !== id)
          : [...filtered, id];
      });
    }
  };

  const handleContinue = () => {
    navigation.goBack();
  };

  const proCount = selected.filter(id => 
    TRADES.find(t => t.id === id)?.pro
  ).length;

  return (
    <HScreen
      ambient
      scroll={false}
      footer={
        <View style={styles.footer}>
          {proCount > 0 && (
            <HText variant="caption" color="purple" center>
              {proCount} pro cert{proCount > 1 ? 's' : ''} — premium tasks unlocked
            </HText>
          )}
          <HButton 
            variant="primary" 
            size="lg" 
            fullWidth 
            onPress={handleContinue}
          >
            Continue
          </HButton>
        </View>
      }
    >
      <View style={styles.content}>
        <View style={styles.header}>
          <HText variant="title1" center>
            Any certifications?
          </HText>
          <View style={styles.headerSpacer} />
          <HText variant="body" color="secondary" center>
            Pros get access to higher-paying tasks
          </HText>
        </View>

        <View style={styles.spacer} />

        <ScrollView 
          style={styles.scroll} 
          contentContainerStyle={styles.list}
          showsVerticalScrollIndicator={false}
        >
          {TRADES.map((trade) => (
            <TradeCard
              key={trade.id}
              emoji={trade.emoji}
              label={trade.label}
              pro={trade.pro}
              selected={selected.includes(trade.id)}
              onPress={() => toggleTrade(trade.id)}
            />
          ))}
        </ScrollView>
      </View>
    </HScreen>
  );
}

function TradeCard({ 
  emoji, 
  label, 
  pro,
  selected, 
  onPress 
}: { 
  emoji: string; 
  label: string; 
  pro?: boolean;
  selected: boolean; 
  onPress: () => void;
}) {
  const scale = useSharedValue(1);

  const handlePressIn = () => {
    scale.value = withSpring(0.98, { damping: 20, stiffness: 400 });
  };

  const handlePressOut = () => {
    scale.value = withSpring(1, { damping: 15, stiffness: 400 });
  };

  const animatedStyle = useAnimatedStyle(() => ({
    transform: [{ scale: scale.value }],
  }));

  return (
    <Pressable
      onPress={onPress}
      onPressIn={handlePressIn}
      onPressOut={handlePressOut}
      style={styles.cardWrapper}
    >
      <Animated.View style={animatedStyle}>
        <HCard 
          variant={selected ? 'outlined' : 'default'} 
          padding="lg"
        >
          <View style={styles.cardContent}>
            <HText variant="title2">{emoji}</HText>
            <View style={styles.cardText}>
              <View style={styles.labelRow}>
                <HText 
                  variant="headline" 
                  color={selected ? 'primary' : 'secondary'}
                >
                  {label}
                </HText>
                {pro && (
                  <HBadge variant="success" size="sm">PRO</HBadge>
                )}
              </View>
            </View>
            {selected && (
              <HText variant="body" color="purple">✓</HText>
            )}
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
    alignItems: 'center',
    paddingTop: hustleSpacing.lg,
  },
  headerSpacer: {
    height: hustleSpacing.sm,
  },
  spacer: {
    height: hustleSpacing.xl,
  },
  scroll: {
    flex: 1,
  },
  list: {
    gap: hustleSpacing.md,
    paddingBottom: hustleSpacing['2xl'],
  },
  cardWrapper: {},
  cardContent: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: hustleSpacing.lg,
  },
  cardText: {
    flex: 1,
  },
  labelRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: hustleSpacing.sm,
  },
  footer: {
    gap: hustleSpacing.md,
  },
});

export default CapabilityTradesScreen;
