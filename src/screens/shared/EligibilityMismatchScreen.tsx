/**
 * EligibilityMismatchScreen - Can't accept task due to missing requirements
 * 
 * Archetype: Interrupt
 * Emotion: "The system has this under control"
 * - Never blame user
 * - Explain simply, offer clear next step
 * - "Hmm, that didn't work" energy
 * - Calm, factual, helpful
 */

import React from 'react';
import { View, StyleSheet, ScrollView } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { useNavigation } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import type { RootStackParamList } from '../../navigation/types';

import { HScreen, HCard, HText, HButton } from '../../components/atoms';
import { hustleColors, hustleSpacing } from '../../theme/hustle-tokens';

type NavigationProp = NativeStackNavigationProp<RootStackParamList>;

export function EligibilityMismatchScreen() {
  const insets = useSafeAreaInsets();
  const navigation = useNavigation<NavigationProp>();

  const handleBack = () => navigation.goBack();
  const handleVerify = () => navigation.navigate('WorkEligibility');
  const handleBrowse = () => navigation.navigate('TaskFeed');

  return (
    <HScreen ambient={false}>
      {/* Header */}
      <View style={[styles.header, { paddingTop: insets.top + hustleSpacing.sm }]}>
        <HButton variant="ghost" size="sm" onPress={handleBack}>
          ← Back
        </HButton>
      </View>

      <ScrollView 
        style={styles.scrollContainer}
        contentContainerStyle={styles.scroll}
      >
        {/* Header - calm, not alarming */}
        <View style={styles.heroSection}>
          <View style={styles.iconCircle}>
            <HText variant="hero">🔒</HText>
          </View>
          <HText variant="title1" color="primary" center style={styles.title}>
            This one needs a bit more
          </HText>
          <HText variant="body" color="secondary" center>
            This task requires some qualifications you haven't added yet.
          </HText>
        </View>

        {/* Task Info */}
        <HCard variant="default" padding="md" style={styles.taskCard}>
          <View style={styles.taskRow}>
            <View style={styles.taskInfo}>
              <HText variant="headline" color="primary">Electrical repair</HText>
              <HText variant="caption" color="secondary">Requires licensed electrician</HText>
            </View>
            <HText variant="caption" color="purple">Premium</HText>
          </View>
        </HCard>

        {/* Missing Requirements - calm, actionable */}
        <HText variant="headline" color="primary" style={styles.sectionTitle}>
          What's needed
        </HText>

        <RequirementCard
          title="Licensed Electrician"
          description="This task requires a valid electrician license"
          actionLabel="Add License"
          onAction={() => console.log('add license')}
        />
        
        <RequirementCard
          title="Liability Insurance"
          description="$1M minimum coverage required for electrical work"
          actionLabel="Add Insurance"
          onAction={() => console.log('add insurance')}
        />

        {/* Helpful info */}
        <HCard variant="default" padding="md" style={styles.infoCard}>
          <HText variant="footnote" color="secondary">
            Once you add these qualifications, you'll unlock premium tasks like this one — they typically pay more and have less competition.
          </HText>
        </HCard>
      </ScrollView>

      {/* Footer */}
      <View style={[styles.footer, { paddingBottom: insets.bottom + hustleSpacing.lg }]}>
        <HButton 
          variant="primary" 
          size="lg" 
          onPress={handleVerify}
          style={styles.primaryBtn}
        >
          Complete Verification
        </HButton>
        <HButton 
          variant="ghost" 
          size="sm" 
          onPress={handleBrowse}
          style={styles.secondaryBtn}
        >
          Browse other tasks
        </HButton>
      </View>
    </HScreen>
  );
}

interface RequirementCardProps {
  title: string;
  description: string;
  actionLabel: string;
  onAction: () => void;
}

function RequirementCard({ title, description, actionLabel, onAction }: RequirementCardProps) {
  return (
    <HCard variant="default" padding="md" style={styles.requirementCard}>
      <View style={styles.requirementRow}>
        <View style={styles.requirementIcon}>
          <HText variant="body">○</HText>
        </View>
        <View style={styles.requirementInfo}>
          <HText variant="headline" color="primary">{title}</HText>
          <HText variant="caption" color="secondary">{description}</HText>
        </View>
        <HButton variant="secondary" size="sm" onPress={onAction}>
          {actionLabel}
        </HButton>
      </View>
    </HCard>
  );
}

const styles = StyleSheet.create({
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: hustleSpacing.lg,
    paddingBottom: hustleSpacing.md,
  },
  scrollContainer: {
    flex: 1,
  },
  scroll: { 
    padding: hustleSpacing.lg,
    paddingTop: 0,
  },
  heroSection: { 
    alignItems: 'center',
    marginBottom: hustleSpacing['2xl'],
  },
  iconCircle: {
    width: 80,
    height: 80,
    borderRadius: 40,
    backgroundColor: hustleColors.dark.elevated,
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: hustleSpacing.lg,
  },
  title: {
    marginBottom: hustleSpacing.sm,
  },
  taskCard: {
    marginBottom: hustleSpacing.xl,
  },
  taskRow: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  taskInfo: {
    flex: 1,
  },
  sectionTitle: {
    marginBottom: hustleSpacing.md,
  },
  requirementCard: {
    marginBottom: hustleSpacing.sm,
  },
  requirementRow: { 
    flexDirection: 'row', 
    alignItems: 'center',
  },
  requirementIcon: {
    width: 24,
    height: 24,
    justifyContent: 'center',
    alignItems: 'center',
  },
  requirementInfo: { 
    flex: 1,
    marginLeft: hustleSpacing.sm,
    marginRight: hustleSpacing.md,
  },
  infoCard: {
    marginTop: hustleSpacing.lg,
  },
  footer: { 
    padding: hustleSpacing.lg,
  },
  primaryBtn: {
    marginBottom: hustleSpacing.sm,
  },
  secondaryBtn: {
    alignSelf: 'center',
  },
});

export default EligibilityMismatchScreen;
