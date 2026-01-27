/**
 * CapabilityBackgroundScreen - Background check consent
 */

import React from 'react';
import { View, StyleSheet } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
// import { useNavigation } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import type { RootStackParamList } from '../../navigation/types';

// type NavigationProp = NativeStackNavigationProp<RootStackParamList>;
import { Button, Text, Spacing, Card } from '../../components';
import { theme } from '../../theme';

export function CapabilityBackgroundScreen() {
  const insets = useSafeAreaInsets();
  // Navigation available via useNavigation<NavigationProp>() when needed

  return (
    <View style={[styles.container, { paddingTop: insets.top, paddingBottom: insets.bottom }]}>
      <View style={styles.content}>
        <View style={styles.iconContainer}>
          <Text variant="hero">🔒</Text>
        </View>

        <Spacing size={24} />

        <Text variant="title1" color="primary" align="center">
          Build trust with a background check
        </Text>
        <Spacing size={8} />
        <Text variant="body" color="secondary" align="center">
          Verified hustlers get more tasks and higher pay
        </Text>

        <Spacing size={32} />

        <Card variant="default" padding="lg">
          <BenefitRow emoji="⭐" text="'Verified' badge on your profile" />
          <Spacing size={12} />
          <BenefitRow emoji="💰" text="Access to higher-paying tasks" />
          <Spacing size={12} />
          <BenefitRow emoji="🤝" text="Posters prefer verified hustlers" />
          <Spacing size={12} />
          <BenefitRow emoji="🔐" text="Your data is encrypted and secure" />
        </Card>

        <Spacing size={24} />

        <Text variant="footnote" color="tertiary" align="center">
          Background check is optional. You can skip this and complete it later in settings.
        </Text>
      </View>

      <View style={styles.footer}>
        <Button variant="primary" size="lg" onPress={() => console.log('start check')}>
          Start Background Check
        </Button>
        <Spacing size={12} />
        <Button variant="ghost" size="sm" onPress={() => console.log('skip')}>
          Skip for now
        </Button>
      </View>
    </View>
  );
}

function BenefitRow({ emoji, text }: { emoji: string; text: string }) {
  return (
    <View style={styles.benefitRow}>
      <Text variant="body">{emoji}</Text>
      <Text variant="body" color="primary" style={styles.benefitText}>{text}</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: theme.colors.surface.primary },
  content: { flex: 1, paddingHorizontal: theme.spacing[4], paddingTop: theme.spacing[8] },
  iconContainer: { alignItems: 'center' },
  benefitRow: { flexDirection: 'row', alignItems: 'center' },
  benefitText: { marginLeft: theme.spacing[3] },
  footer: { paddingHorizontal: theme.spacing[4], paddingBottom: theme.spacing[4] },
});

export default CapabilityBackgroundScreen;
