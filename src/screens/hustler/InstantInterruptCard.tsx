/**
 * InstantInterruptCard - Urgent task notification overlay
 */

import React from 'react';
import { View, StyleSheet, Modal } from 'react-native';
import { Text, Spacing, Card, Button, MoneyDisplay } from '../../components';
import { theme } from '../../theme';

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
    <Modal visible={visible} transparent animationType="slide">
      <View style={styles.overlay}>
        <Card variant="elevated" padding="lg" style={styles.card}>
          {/* Urgent Badge */}
          <View style={styles.urgentBadge}>
            <Text variant="caption" color="inverse">⚡ {task.urgency}</Text>
          </View>

          <Spacing size={16} />

          <Text variant="title2" color="primary" align="center">
            New Task Nearby!
          </Text>

          <Spacing size={20} />

          <Text variant="headline" color="primary" align="center">
            {task.title}
          </Text>
          <Spacing size={4} />
          <Text variant="body" color="secondary" align="center">
            {task.distance} away
          </Text>

          <Spacing size={20} />

          <View style={styles.priceContainer}>
            <MoneyDisplay amount={task.price} size="lg" />
          </View>

          <Spacing size={24} />

          <View style={styles.actions}>
            <Button 
              variant="secondary" 
              size="lg" 
              onPress={onDecline}
              style={styles.actionBtn}
            >
              Pass
            </Button>
            <View style={styles.actionSpacer} />
            <Button 
              variant="primary" 
              size="lg" 
              onPress={onAccept}
              style={styles.actionBtn}
            >
              Accept
            </Button>
          </View>

          <Spacing size={12} />

          <Text variant="caption" color="tertiary" align="center">
            This offer expires in 2 minutes
          </Text>
        </Card>
      </View>
    </Modal>
  );
}

// Demo component for standalone viewing
export function InstantInterruptCardDemo() {
  const [visible, setVisible] = React.useState(true);

  return (
    <View style={styles.demoContainer}>
      <Button variant="primary" onPress={() => setVisible(true)}>
        Show Interrupt
      </Button>
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
          title: 'Urgent grocery pickup',
          price: 35,
          distance: '0.3 mi',
          urgency: 'ASAP',
        }}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  overlay: {
    flex: 1,
    backgroundColor: 'rgba(0,0,0,0.7)',
    justifyContent: 'center',
    padding: theme.spacing[4],
  },
  card: {
    alignItems: 'center',
  },
  urgentBadge: {
    backgroundColor: theme.colors.semantic.warning,
    paddingHorizontal: theme.spacing[4],
    paddingVertical: theme.spacing[2],
    borderRadius: theme.radii.full,
  },
  priceContainer: {
    backgroundColor: theme.colors.surface.secondary,
    paddingHorizontal: theme.spacing[6],
    paddingVertical: theme.spacing[4],
    borderRadius: theme.radii.md,
  },
  actions: {
    flexDirection: 'row',
    width: '100%',
  },
  actionBtn: {
    flex: 1,
  },
  actionSpacer: {
    width: theme.spacing[3],
  },
  demoContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: theme.colors.surface.primary,
  },
});

export default InstantInterruptCard;
