/**
 * FramingScreen - The system is ready for you
 * 
 * CHOSEN-STATE: "Things are happening. You're next."
 * One decision: Acknowledge you're in.
 */

import React from 'react';
import { View, StyleSheet } from 'react-native';
import { useNavigation } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import { HScreen, HText, HButton, HCard, HSignal } from '../../components/atoms';
import { hustleColors, hustleSpacing } from '../../theme/hustle-tokens';
import type { RootStackParamList } from '../../navigation/types';

type NavigationProp = NativeStackNavigationProp<RootStackParamList>;

export function FramingScreen() {
  const navigation = useNavigation<NavigationProp>();

  const handleContinue = () => {
    navigation.navigate('RoleConfirmation', {});
  };

  return (
    <HScreen
      ambient
      scroll={false}
      footer={
        <HButton variant="primary" size="lg" fullWidth onPress={handleContinue}>
          Let's go
        </HButton>
      }
    >
      <View style={styles.content}>
        {/* Activity signals - system is alive */}
        <View style={styles.signalRow}>
          <HSignal text="Task claimed" icon="✓" delay={0} />
          <HSignal text="$45 earned" icon="💰" delay={400} />
          <HSignal text="New match" icon="🔗" delay={800} />
        </View>

        {/* Hero */}
        <View style={styles.hero}>
          <HText variant="hero" center>
            Your hustle,{'\n'}your way
          </HText>
          
          <View style={styles.spacer} />
          
          <HText variant="body" color="secondary" center>
            People are getting things done right now.{'\n'}
            You're next.
          </HText>
        </View>

        {/* Value signals - what's already working */}
        <View style={styles.values}>
          <ValueCard 
            emoji="🛡️" 
            title="Payments protected" 
            subtitle="Funds held until you're satisfied"
          />
          <View style={styles.valueGap} />
          <ValueCard 
            emoji="⭐" 
            title="Trust built in" 
            subtitle="Your reputation grows with each task"
          />
          <View style={styles.valueGap} />
          <ValueCard 
            emoji="💰" 
            title="Your rates, your earnings" 
            subtitle="Keep what you make"
          />
        </View>
      </View>
    </HScreen>
  );
}

function ValueCard({ emoji, title, subtitle }: { emoji: string; title: string; subtitle: string }) {
  return (
    <HCard variant="default" padding="md">
      <View style={styles.valueContent}>
        <HText variant="title2">{emoji}</HText>
        <View style={styles.valueText}>
          <HText variant="headline">{title}</HText>
          <HText variant="caption" color="tertiary">{subtitle}</HText>
        </View>
      </View>
    </HCard>
  );
}

const styles = StyleSheet.create({
  content: {
    flex: 1,
    justifyContent: 'center',
  },
  signalRow: {
    flexDirection: 'row',
    justifyContent: 'center',
    gap: 8,
    marginBottom: hustleSpacing.xl,
  },
  hero: {
    alignItems: 'center',
    marginBottom: hustleSpacing['2xl'],
  },
  spacer: {
    height: hustleSpacing.md,
  },
  values: {
    marginTop: hustleSpacing.lg,
  },
  valueGap: {
    height: hustleSpacing.md,
  },
  valueContent: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  valueText: {
    marginLeft: hustleSpacing.md,
    flex: 1,
  },
});

export default FramingScreen;
