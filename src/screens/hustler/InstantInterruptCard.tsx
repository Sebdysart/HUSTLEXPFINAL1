/**
 * InstantInterruptCard - Task notification overlay
 * 
 * Archetype: Interrupt
 * Emotion: "The system has this under control"
 * - Calm, confident presentation
 * - Authority without aggression
 * - Clear information hierarchy
 * - Actions obvious but not urgent
 * - NO neon accents, NO urgent language
 */

import React from 'react';
import { View, StyleSheet, Modal } from 'react-native';

import { HCard, HText, HButton, HBadge } from '../../components/atoms';
import { MoneyDisplay } from '../../components';
import { hustleColors, hustleSpacing, hustleRadii } from '../../theme/hustle-tokens';

interface InstantInterruptCardProps {
  visible: boolean;
  onAccept: () => void;
  onDecline: () => void;
  task: {
    title: string;
    price: number;
    distance: string;
    urgency: string;
  };
}

export function InstantInterruptCard({ visible, onAccept, onDecline, task }: InstantInterruptCardProps) {
  return (
    <Modal visible={visible} transparent animationType="fade">
      <View style={styles.overlay}>
        <HCard variant="elevated" padding="lg" style={styles.card}>
          {/* Status indicator - calm, not alarming */}
          <HBadge variant="default" size="md">
            {task.urgency}
          </HBadge>

          <View style={styles.content}>
            <HText variant="title2" color="primary" center>
              New task available
            </HText>

            <View style={styles.taskDetails}>
              <HText variant="headline" color="primary" center>
                {task.title}
              </HText>
              <HText variant="body" color="secondary" center>
                {task.distance} away
              </HText>
            </View>

            <View style={styles.priceContainer}>
              <MoneyDisplay amount={task.price} size="lg" />
            </View>
          </View>

          <View style={styles.actions}>
            <HButton 
              variant="secondary" 
              size="lg" 
              onPress={onDecline}
              style={styles.actionBtn}
            >
              Not now
            </HButton>
            <View style={styles.actionSpacer} />
            <HButton 
              variant="primary" 
              size="lg" 
              onPress={onAccept}
              style={styles.actionBtn}
            >
              Accept
            </HButton>
          </View>

          <HText variant="caption" color="tertiary" center style={styles.expiry}>
            Available for the next 2 minutes
          </HText>
        </HCard>
      </View>
    </Modal>
  );
}

// Demo component for standalone viewing
export function InstantInterruptCardDemo() {
  const [visible, setVisible] = React.useState(true);

  return (
    <View style={styles.demoContainer}>
      <HButton variant="primary" onPress={() => setVisible(true)}>
        Show Task
      </HButton>
      <InstantInterruptCard
        visible={visible}
        onAccept={() => {
          console.log('Accepted');
          setVisible(false);
        }}
        onDecline={() => {
          console.log('Declined');
          setVisible(false);
        }}
        task={{
          title: 'Grocery pickup',
          price: 35,
          distance: '0.3 mi',
          urgency: 'Nearby',
        }}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  overlay: {
    flex: 1,
    backgroundColor: 'rgba(0, 0, 0, 0.75)',
    justifyContent: 'center',
    padding: hustleSpacing.xl,
  },
  card: {
    alignItems: 'center',
  },
  content: {
    width: '100%',
    alignItems: 'center',
    marginTop: hustleSpacing.xl,
  },
  taskDetails: {
    marginTop: hustleSpacing.lg,
    alignItems: 'center',
  },
  priceContainer: {
    backgroundColor: hustleColors.dark.surface,
    paddingHorizontal: hustleSpacing['2xl'],
    paddingVertical: hustleSpacing.lg,
    borderRadius: hustleRadii.lg,
    marginTop: hustleSpacing.xl,
  },
  actions: {
    flexDirection: 'row',
    width: '100%',
    marginTop: hustleSpacing.xl,
  },
  actionBtn: {
    flex: 1,
  },
  actionSpacer: {
    width: hustleSpacing.md,
  },
  expiry: {
    marginTop: hustleSpacing.lg,
  },
  demoContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: hustleColors.dark.base,
  },
});

export default InstantInterruptCard;
