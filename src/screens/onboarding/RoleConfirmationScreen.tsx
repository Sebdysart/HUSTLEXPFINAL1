/**
 * RoleConfirmationScreen - Hustler vs Poster role selection
 */

import React, { useState } from 'react';
import { View, StyleSheet, TouchableOpacity } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { useNavigation } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import { Button, Text, Spacing } from '../../components';
import { theme } from '../../theme';
import type { RootStackParamList } from '../../navigation/types';

type NavigationProp = NativeStackNavigationProp<RootStackParamList>;
type Role = 'hustler' | 'poster' | 'both';

export function RoleConfirmationScreen() {
  const insets = useSafeAreaInsets();
  const navigation = useNavigation<NavigationProp>();
  const [selectedRole, setSelectedRole] = useState<Role | null>(null);

  const handleContinue = () => {
    if (!selectedRole) return;
    
    // If hustler or both, go through capability screens
    if (selectedRole === 'hustler' || selectedRole === 'both') {
      navigation.navigate('CapabilityLocation');
    } else {
      // Posters skip most onboarding
      navigation.navigate('OnboardingComplete');
    }
  };

  const handleBack = () => {
    navigation.goBack();
  };

  return (
    <View style={[styles.container, { paddingTop: insets.top, paddingBottom: insets.bottom }]}>
      {/* Back button */}
      <TouchableOpacity style={styles.backButton} onPress={handleBack}>
        <Text variant="body" color="primary">← Back</Text>
      </TouchableOpacity>

      <View style={styles.content}>
        {/* Header */}
        <View style={styles.header}>
          <Text variant="title1" color="primary" align="center">
            How will you use HustleXP?
          </Text>
          <Spacing size={8} />
          <Text variant="body" color="secondary" align="center">
            You can always do both later
          </Text>
        </View>

        <Spacing size={40} />

        {/* Role Options */}
        <RoleCard
          emoji="💪"
          title="I want to earn"
          subtitle="Complete tasks posted by others and get paid"
          selected={selectedRole === 'hustler'}
          onPress={() => setSelectedRole('hustler')}
        />
        
        <Spacing size={16} />
        
        <RoleCard
          emoji="📋"
          title="I need help"
          subtitle="Post tasks and find people to help you"
          selected={selectedRole === 'poster'}
          onPress={() => setSelectedRole('poster')}
        />
        
        <Spacing size={16} />
        
        <RoleCard
          emoji="🔄"
          title="Both"
          subtitle="Earn money and post tasks when you need help"
          selected={selectedRole === 'both'}
          onPress={() => setSelectedRole('both')}
        />
      </View>

      {/* CTA */}
      <View style={styles.footer}>
        <Button
          variant="primary"
          size="lg"
          onPress={handleContinue}
          disabled={!selectedRole}
        >
          Continue
        </Button>
      </View>
    </View>
  );
}

function RoleCard({ 
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
  return (
    <TouchableOpacity
      style={[styles.roleCard, selected && styles.roleCardSelected]}
      onPress={onPress}
      activeOpacity={0.7}
    >
      <View style={styles.roleEmoji}>
        <Text variant="hero">{emoji}</Text>
      </View>
      <View style={styles.roleText}>
        <Text variant="headline" color="primary">{title}</Text>
        <Text variant="footnote" color="secondary">{subtitle}</Text>
      </View>
      <View style={[styles.radioOuter, selected && styles.radioOuterSelected]}>
        {selected && <View style={styles.radioInner} />}
      </View>
    </TouchableOpacity>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: theme.colors.surface.primary,
  },
  backButton: {
    padding: theme.spacing[4],
    paddingBottom: 0,
  },
  content: {
    flex: 1,
    paddingHorizontal: theme.spacing[4],
  },
  header: {
    marginTop: theme.spacing[4],
  },
  roleCard: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: theme.colors.surface.secondary,
    padding: theme.spacing[4],
    borderRadius: theme.radii.md,
    borderWidth: 2,
    borderColor: 'transparent',
  },
  roleCardSelected: {
    borderColor: theme.colors.brand.primary,
  },
  roleEmoji: {
    width: 56,
    height: 56,
    borderRadius: 28,
    backgroundColor: theme.colors.surface.tertiary,
    justifyContent: 'center',
    alignItems: 'center',
  },
  roleText: {
    flex: 1,
    marginLeft: theme.spacing[4],
  },
  radioOuter: {
    width: 24,
    height: 24,
    borderRadius: 12,
    borderWidth: 2,
    borderColor: theme.colors.text.tertiary,
    justifyContent: 'center',
    alignItems: 'center',
  },
  radioOuterSelected: {
    borderColor: theme.colors.brand.primary,
  },
  radioInner: {
    width: 12,
    height: 12,
    borderRadius: 6,
    backgroundColor: theme.colors.brand.primary,
  },
  footer: {
    paddingHorizontal: theme.spacing[4],
    paddingBottom: theme.spacing[4],
  },
});

export default RoleConfirmationScreen;
