/**
 * RoleConfirmationScreen - App adjusts to you
 * 
 * CHOSEN-STATE: Not "tell us about you" - "we're tuning to you"
 * One decision: How should the app orient?
 */

import React, { useState } from 'react';
import { View, StyleSheet, Pressable } from 'react-native';
import { useNavigation } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import Animated, {
  useSharedValue,
  useAnimatedStyle,
  withSpring,
} from 'react-native-reanimated';
import { HScreen, HText, HButton, HCard } from '../../components/atoms';
import { hustleColors, hustleSpacing } from '../../theme/hustle-tokens';
import type { RootStackParamList } from '../../navigation/types';

type NavigationProp = NativeStackNavigationProp<RootStackParamList>;
type Role = 'hustler' | 'poster' | 'both';

export function RoleConfirmationScreen() {
  const navigation = useNavigation<NavigationProp>();
  const [selectedRole, setSelectedRole] = useState<Role | null>(null);

  const handleContinue = () => {
    if (!selectedRole) return;
    
    if (selectedRole === 'hustler' || selectedRole === 'both') {
      navigation.navigate('CapabilityLocation');
    } else {
      navigation.navigate('OnboardingComplete');
    }
  };

  return (
    <HScreen
      ambient
      scroll={false}
      footer={
        <HButton 
          variant="primary" 
          size="lg" 
          fullWidth 
          onPress={handleContinue}
          disabled={!selectedRole}
        >
          Continue
        </HButton>
      }
    >
      <View style={styles.content}>
        {/* Header - app adjusting, not asking */}
        <View style={styles.header}>
          <HText variant="title1" center>
            What brings you here?
          </HText>
          <View style={styles.headerSpacer} />
          <HText variant="body" color="secondary" center>
            We'll tune your experience
          </HText>
        </View>

        <View style={styles.spacer} />

        {/* Role choices */}
        <RoleOption
          emoji="💪"
          title="Ready to earn"
          subtitle="Tasks are waiting"
          selected={selectedRole === 'hustler'}
          onPress={() => setSelectedRole('hustler')}
        />
        
        <View style={styles.optionGap} />
        
        <RoleOption
          emoji="📋"
          title="Need something done"
          subtitle="Post and relax"
          selected={selectedRole === 'poster'}
          onPress={() => setSelectedRole('poster')}
        />
        
        <View style={styles.optionGap} />
        
        <RoleOption
          emoji="🔄"
          title="A bit of both"
          subtitle="Earn and delegate"
          selected={selectedRole === 'both'}
          onPress={() => setSelectedRole('both')}
        />

        <View style={styles.hint}>
          <HText variant="caption" color="tertiary" center>
            You can always switch later
          </HText>
        </View>
      </View>
    </HScreen>
  );
}

function RoleOption({ 
  emoji, 
  title, 
  subtitle, 
  selected, 
  onPress 
}: { 
  emoji: string; 
  title: string; 
  subtitle: string; 
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
    >
      <Animated.View style={animatedStyle}>
        <HCard 
          variant={selected ? 'outlined' : 'default'} 
          padding="lg"
        >
          <View style={styles.roleContent}>
            <View style={styles.roleEmoji}>
              <HText variant="hero">{emoji}</HText>
            </View>
            <View style={styles.roleText}>
              <HText variant="headline">{title}</HText>
              <HText variant="caption" color="tertiary">{subtitle}</HText>
            </View>
            <View style={[styles.indicator, selected && styles.indicatorSelected]}>
              {selected && <View style={styles.indicatorDot} />}
            </View>
          </View>
        </HCard>
      </Animated.View>
    </Pressable>
  );
}

const styles = StyleSheet.create({
  content: {
    flex: 1,
    justifyContent: 'center',
  },
  header: {
    alignItems: 'center',
  },
  headerSpacer: {
    height: hustleSpacing.sm,
  },
  spacer: {
    height: hustleSpacing['2xl'],
  },
  optionGap: {
    height: hustleSpacing.md,
  },
  roleContent: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  roleEmoji: {
    width: 56,
    height: 56,
    borderRadius: 28,
    backgroundColor: hustleColors.dark.surface,
    justifyContent: 'center',
    alignItems: 'center',
  },
  roleText: {
    flex: 1,
    marginLeft: hustleSpacing.md,
  },
  indicator: {
    width: 24,
    height: 24,
    borderRadius: 12,
    borderWidth: 2,
    borderColor: hustleColors.text.muted,
    justifyContent: 'center',
    alignItems: 'center',
  },
  indicatorSelected: {
    borderColor: hustleColors.purple.soft,
  },
  indicatorDot: {
    width: 12,
    height: 12,
    borderRadius: 6,
    backgroundColor: hustleColors.purple.soft,
  },
  hint: {
    marginTop: hustleSpacing.xl,
  },
});

export default RoleConfirmationScreen;
