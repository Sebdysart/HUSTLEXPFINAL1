/**
 * NeonHomePreview - Preview of upgraded neon UI
 * This shows what HustlerHomeScreen COULD look like
 */

import React from 'react';
import { View, StyleSheet, ScrollView, Dimensions } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import Animated, {
  useSharedValue,
  useAnimatedStyle,
  withRepeat,
  withTiming,
  Easing,
  FadeInDown,
} from 'react-native-reanimated';
import LinearGradient from 'react-native-linear-gradient';
import { Text } from '../components/Text';
import { GlassCard, NeonBadge } from '../components/GlassCard';
import { NeonButton } from '../components/NeonButton';
import { neonColors, neonShadows, neonRadii } from '../theme/neon-tokens';

const { width } = Dimensions.get('window');

export function NeonHomePreview() {
  const insets = useSafeAreaInsets();
  
  // Animated gradient rotation
  const rotation = useSharedValue(0);
  
  React.useEffect(() => {
    rotation.value = withRepeat(
      withTiming(360, { duration: 10000, easing: Easing.linear }),
      -1,
      false
    );
  }, []);

  const animatedGradientStyle = useAnimatedStyle(() => ({
    transform: [{ rotate: `${rotation.value}deg` }],
  }));

  return (
    <View style={[styles.container, { paddingTop: insets.top }]}>
      {/* Animated background gradient */}
      <View style={StyleSheet.absoluteFill}>
        <LinearGradient
          colors={[neonColors.surface.void, neonColors.surface.primary, neonColors.surface.secondary]}
          style={StyleSheet.absoluteFill}
        />
        <Animated.View style={[styles.gradientOrb, animatedGradientStyle]}>
          <LinearGradient
            colors={[neonColors.glow.cyan, 'transparent']}
            style={styles.orb}
          />
        </Animated.View>
        <View style={[styles.gradientOrb2]}>
          <LinearGradient
            colors={[neonColors.glow.magenta, 'transparent']}
            style={styles.orb}
          />
        </View>
      </View>

      <ScrollView contentContainerStyle={styles.scroll} showsVerticalScrollIndicator={false}>
        {/* Header */}
        <Animated.View entering={FadeInDown.delay(100).springify()} style={styles.header}>
          <View>
            <Text variant="footnote" color={neonColors.text.secondary}>Welcome back</Text>
            <Text variant="title1" color={neonColors.cyan} style={styles.neonText}>
              Sebastian
            </Text>
          </View>
          <NeonBadge color={neonColors.cyan} pulsing>
            <Text variant="caption" color={neonColors.cyan}>⚡ TIER 3</Text>
          </NeonBadge>
        </Animated.View>

        {/* Earnings Card - Main CTA */}
        <Animated.View entering={FadeInDown.delay(200).springify()}>
          <GlassCard variant="neon" glowColor={neonColors.cyan} padding="xl">
            <Text variant="footnote" color={neonColors.text.secondary}>
              This Week's Earnings
            </Text>
            <View style={styles.earningsRow}>
              <Text variant="hero" color={neonColors.white} style={styles.moneyText}>
                $347
              </Text>
              <Text variant="title2" color={neonColors.text.tertiary}>.50</Text>
            </View>
            <View style={styles.statsRow}>
              <StatPill label="Tasks" value="5" color={neonColors.cyan} />
              <StatPill label="Hours" value="12" color={neonColors.magenta} />
              <StatPill label="Rating" value="4.9" color={neonColors.lime} />
            </View>
          </GlassCard>
        </Animated.View>

        {/* Quick Actions Grid */}
        <Animated.View entering={FadeInDown.delay(300).springify()}>
          <Text variant="headline" color={neonColors.white} style={styles.sectionTitle}>
            Quick Actions
          </Text>
          <View style={styles.actionsGrid}>
            <ActionTile emoji="🔍" label="Find Tasks" color={neonColors.cyan} />
            <ActionTile emoji="📋" label="My Tasks" color={neonColors.magenta} />
            <ActionTile emoji="💰" label="Earnings" color={neonColors.lime} />
            <ActionTile emoji="👤" label="Profile" color={neonColors.gold} />
          </View>
        </Animated.View>

        {/* Nearby Tasks */}
        <Animated.View entering={FadeInDown.delay(400).springify()}>
          <Text variant="headline" color={neonColors.white} style={styles.sectionTitle}>
            Nearby Tasks
          </Text>
          <TaskCard
            title="Move couch to storage"
            price={75}
            distance="0.3 mi"
            time="~45 min"
          />
          <TaskCard
            title="Grocery delivery"
            price={35}
            distance="0.8 mi"
            time="~30 min"
          />
        </Animated.View>

        {/* CTA Button */}
        <Animated.View entering={FadeInDown.delay(500).springify()} style={styles.ctaContainer}>
          <NeonButton variant="primary" size="lg" fullWidth>
            Find More Tasks
          </NeonButton>
        </Animated.View>
      </ScrollView>
    </View>
  );
}

// Sub-components
const StatPill: React.FC<{ label: string; value: string; color: string }> = ({ label, value, color }) => (
  <View style={[styles.statPill, { borderColor: `${color}44` }]}>
    <Text variant="title3" color={color}>{value}</Text>
    <Text variant="caption" color={neonColors.text.tertiary}>{label}</Text>
  </View>
);

const ActionTile: React.FC<{ emoji: string; label: string; color: string }> = ({ emoji, label, color }) => (
  <GlassCard 
    variant="default" 
    padding="md" 
    style={styles.actionTile}
    onPress={() => {}}
  >
    <Text style={styles.actionEmoji}>{emoji}</Text>
    <Text variant="caption" color={neonColors.text.secondary}>{label}</Text>
  </GlassCard>
);

const TaskCard: React.FC<{ title: string; price: number; distance: string; time: string }> = ({ 
  title, price, distance, time 
}) => (
  <GlassCard variant="elevated" padding="lg" style={styles.taskCard} onPress={() => {}}>
    <View style={styles.taskHeader}>
      <Text variant="headline" color={neonColors.white}>{title}</Text>
      <Text variant="title3" color={neonColors.lime}>${price}</Text>
    </View>
    <View style={styles.taskMeta}>
      <Text variant="caption" color={neonColors.text.tertiary}>📍 {distance}</Text>
      <Text variant="caption" color={neonColors.text.tertiary}>⏱ {time}</Text>
    </View>
  </GlassCard>
);

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: neonColors.surface.void,
  },
  scroll: {
    padding: 20,
    paddingBottom: 40,
  },
  gradientOrb: {
    position: 'absolute',
    top: -100,
    right: -100,
    width: 300,
    height: 300,
    opacity: 0.3,
  },
  gradientOrb2: {
    position: 'absolute',
    bottom: 100,
    left: -100,
    width: 250,
    height: 250,
    opacity: 0.2,
  },
  orb: {
    width: '100%',
    height: '100%',
    borderRadius: 999,
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 24,
  },
  neonText: {
    textShadowColor: neonColors.cyan,
    textShadowOffset: { width: 0, height: 0 },
    textShadowRadius: 10,
  },
  earningsRow: {
    flexDirection: 'row',
    alignItems: 'baseline',
    marginVertical: 8,
  },
  moneyText: {
    textShadowColor: neonColors.cyan,
    textShadowOffset: { width: 0, height: 0 },
    textShadowRadius: 20,
  },
  statsRow: {
    flexDirection: 'row',
    justifyContent: 'space-around',
    marginTop: 16,
  },
  statPill: {
    alignItems: 'center',
    paddingVertical: 8,
    paddingHorizontal: 16,
    borderWidth: 1,
    borderRadius: 12,
    backgroundColor: neonColors.glass.light,
  },
  sectionTitle: {
    marginTop: 24,
    marginBottom: 12,
  },
  actionsGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 12,
  },
  actionTile: {
    width: (width - 52) / 2,
    alignItems: 'center',
    paddingVertical: 20,
  },
  actionEmoji: {
    fontSize: 28,
    marginBottom: 8,
  },
  taskCard: {
    marginBottom: 12,
  },
  taskHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  taskMeta: {
    flexDirection: 'row',
    gap: 16,
    marginTop: 8,
  },
  ctaContainer: {
    marginTop: 24,
  },
});
