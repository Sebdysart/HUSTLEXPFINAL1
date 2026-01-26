/**
 * FramingScreen - Welcome/value prop framing
 * First screen users see after signup
 */

import React from 'react';
import { View, StyleSheet, Image } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { Button, Text, Spacing } from '../../components';
import { theme } from '../../theme';

export function FramingScreen() {
  const insets = useSafeAreaInsets();

  const handleContinue = () => {
    console.log('Continue to calibration');
  };

  return (
    <View style={[styles.container, { paddingTop: insets.top, paddingBottom: insets.bottom }]}>
      <View style={styles.content}>
        {/* Hero illustration placeholder */}
        <View style={styles.heroSection}>
          <View style={styles.illustration}>
            <Text variant="hero" align="center">💼</Text>
          </View>
          
          <Spacing size={32} />
          
          <Text variant="hero" color="primary" align="center">
            Your hustle,{'\n'}your way
          </Text>
          
          <Spacing size={16} />
          
          <Text variant="body" color="secondary" align="center">
            Connect with people who need help.{'\n'}
            Build trust. Earn money.
          </Text>
        </View>

        {/* Value props */}
        <View style={styles.valueProps}>
          <ValueProp 
            emoji="🛡️" 
            title="Protected payments" 
            subtitle="Money held in escrow until task complete"
          />
          <Spacing size={16} />
          <ValueProp 
            emoji="⭐" 
            title="Build your reputation" 
            subtitle="Level up with every successful task"
          />
          <Spacing size={16} />
          <ValueProp 
            emoji="💰" 
            title="Fair pricing" 
            subtitle="Set your own rates, keep what you earn"
          />
        </View>
      </View>

      {/* CTA */}
      <View style={styles.footer}>
        <Button
          variant="primary"
          size="lg"
          onPress={handleContinue}
        >
          Get Started
        </Button>
      </View>
    </View>
  );
}

function ValueProp({ emoji, title, subtitle }: { emoji: string; title: string; subtitle: string }) {
  return (
    <View style={styles.valueProp}>
      <Text variant="title2">{emoji}</Text>
      <View style={styles.valuePropText}>
        <Text variant="headline" color="primary">{title}</Text>
        <Text variant="footnote" color="secondary">{subtitle}</Text>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: theme.colors.surface.primary,
  },
  content: {
    flex: 1,
    paddingHorizontal: theme.spacing[4],
    justifyContent: 'center',
  },
  heroSection: {
    alignItems: 'center',
    marginBottom: theme.spacing[8],
  },
  illustration: {
    width: 120,
    height: 120,
    borderRadius: 60,
    backgroundColor: theme.colors.surface.secondary,
    justifyContent: 'center',
    alignItems: 'center',
  },
  valueProps: {
    paddingHorizontal: theme.spacing[2],
  },
  valueProp: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: theme.colors.surface.secondary,
    padding: theme.spacing[4],
    borderRadius: theme.radii.md,
  },
  valuePropText: {
    marginLeft: theme.spacing[4],
    flex: 1,
  },
  footer: {
    paddingHorizontal: theme.spacing[4],
    paddingBottom: theme.spacing[4],
  },
});

export default FramingScreen;
