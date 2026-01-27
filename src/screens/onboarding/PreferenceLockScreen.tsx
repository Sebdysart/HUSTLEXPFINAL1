/**
 * PreferenceLockScreen - All set!
 * 
 * CHOSEN-STATE: Confirmation, not summary
 * One decision: Ready to go?
 */

import React from 'react';
import { View, StyleSheet, Pressable } from 'react-native';
import { useNavigation } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import Animated, {
  useSharedValue,
  useAnimatedStyle,
  withSpring,
} from 'react-native-reanimated';
import { HScreen, HText, HButton, HCard, HBadge, HTextButton } from '../../components/atoms';
import { hustleSpacing, hustleColors } from '../../theme/hustle-tokens';
import type { RootStackParamList } from '../../navigation/types';

type NavigationProp = NativeStackNavigationProp<RootStackParamList>;

export function PreferenceLockScreen() {
  const navigation = useNavigation<NavigationProp>();

  const handleConfirm = () => {
    // Proceed to main app
    navigation.goBack();
  };

  const handleEdit = () => {
    navigation.goBack();
  };

  return (
    <HScreen
      ambient
      scroll={false}
      footer={
        <View style={styles.footer}>
          <HButton 
            variant="primary" 
            size="lg" 
            fullWidth 
            onPress={handleConfirm}
          >
            Continue
          </HButton>
          <HTextButton onPress={handleEdit}>
            Make changes
          </HTextButton>
        </View>
      }
    >
      <View style={styles.content}>
        <View style={styles.header}>
          <HText variant="hero" center>🎯</HText>
          <View style={styles.headerSpacer} />
          <HText variant="title1" center>
            You're dialed in
          </HText>
          <View style={styles.headerSpacer} />
          <HText variant="body" color="secondary" center>
            System's calibrated to you
          </HText>
        </View>

        <View style={styles.spacer} />

        <HCard variant="default" padding="lg">
          <View style={styles.summary}>
            <SummaryRow emoji="👤" label="Mode" value="Hustler & Poster" />
            <View style={styles.divider} />
            <SummaryRow emoji="🎯" label="Interests" value="Delivery, Tech, Assembly" />
            <View style={styles.divider} />
            <SummaryRow emoji="🔔" label="Notifications" value="On" />
          </View>
        </HCard>

        <View style={styles.badges}>
          <HBadge variant="purple" pulsing>Ready to earn</HBadge>
        </View>
      </View>
    </HScreen>
  );
}

function SummaryRow({ 
  emoji, 
  label, 
  value 
}: { 
  emoji: string; 
  label: string; 
  value: string;
}) {
  return (
    <View style={styles.row}>
      <View style={styles.rowLeft}>
        <HText variant="body">{emoji}</HText>
        <HText variant="callout" color="tertiary">{label}</HText>
      </View>
      <HText variant="callout" color="primary">{value}</HText>
    </View>
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
  summary: {
    gap: hustleSpacing.md,
  },
  row: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  rowLeft: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: hustleSpacing.sm,
  },
  divider: {
    height: 1,
    backgroundColor: hustleColors.glass.border,
  },
  badges: {
    marginTop: hustleSpacing.xl,
    alignItems: 'center',
  },
  footer: {
    gap: hustleSpacing.sm,
  },
});

export default PreferenceLockScreen;
