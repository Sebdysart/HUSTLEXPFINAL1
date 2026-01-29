/**
 * TaskInProgressScreen - "This is already in motion"
 * 
 * Archetype C: Task Lifecycle
 * - Simpler than feeds (simplicity = confidence)
 * - Clear progress, inevitable completion
 * - Status: "In motion"
 * - CTAs: "I'm here", "Done"
 */

import React, { useState, useEffect } from 'react';
import { View, StyleSheet, TouchableOpacity } from 'react-native';
import { useNavigation, useRoute, RouteProp } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import {
  HScreen,
  HCard,
  HText,
  HMoney,
  HBadge,
  HButton,
  HActivityIndicator,
} from '../../components/atoms';
import { hustleSpacing } from '../../theme/hustle-tokens';
import { useTaskStore } from '../../store';
import type { RootStackParamList } from '../../navigation/types';

type NavigationProp = NativeStackNavigationProp<RootStackParamList>;
type TaskInProgressRouteProp = RouteProp<RootStackParamList, 'TaskInProgress'>;

export function TaskInProgressScreen() {
  const navigation = useNavigation<NavigationProp>();
  const route = useRoute<TaskInProgressRouteProp>();
  const { taskId } = route.params;

  const { tasks, updateTask, setActiveTask } = useTaskStore();
  const task = tasks.find(t => t.id === taskId);

  const [checklist, setChecklist] = useState([
    { id: 1, text: 'Arrive at location', done: false },
    { id: 2, text: 'Complete main task', done: false },
    { id: 3, text: 'Take completion photos', done: false },
    { id: 4, text: 'Confirm with poster', done: false },
  ]);

  useEffect(() => {
    if (task) {
      setActiveTask(task);
      if (task.status === 'claimed') {
        updateTask(taskId, { status: 'in_progress', startedAt: new Date().toISOString() });
      }
    }
  }, [task, taskId, setActiveTask, updateTask]);

  const toggleChecklistItem = (id: number) => {
    setChecklist(prev =>
      prev.map(item => (item.id === id ? { ...item, done: !item.done } : item))
    );
  };

  const handleEnRoute = () => {
    updateTask(taskId, { status: 'en_route' });
    navigation.navigate('HustlerEnRouteMap', { taskId });
  };

  const handleImHere = () => {
    updateTask(taskId, { status: 'arrived' });
    setChecklist(prev => prev.map((item, i) => (i === 0 ? { ...item, done: true } : item)));
  };

  const handleDone = () => {
    navigation.navigate('TaskCompletionHustler', { taskId });
  };

  const handleChat = () => {
    navigation.navigate('TaskConversation', { taskId });
  };

  if (!task) {
    return (
      <HScreen ambient scroll={false}>
        <View style={styles.centered}>
          <HText variant="body" color="secondary">Task not found</HText>
          <View style={styles.spacerMd} />
          <HButton variant="secondary" size="sm" onPress={() => navigation.goBack()}>
            Go Back
          </HButton>
        </View>
      </HScreen>
    );
  }

  const isEnRoute = task.status === 'en_route';
  const isArrived = task.status === 'arrived' || task.status === 'in_progress';
  const allDone = checklist.every(item => item.done);

  const footer = (
    <View style={styles.footerButtons}>
      {!isEnRoute && !isArrived ? (
        <HButton variant="primary" size="lg" fullWidth onPress={handleEnRoute}>
          Start Navigation
        </HButton>
      ) : isEnRoute ? (
        <HButton variant="primary" size="lg" fullWidth onPress={handleImHere}>
          I'm here
        </HButton>
      ) : (
        <HButton
          variant={allDone ? 'success' : 'primary'}
          size="lg"
          fullWidth
          disabled={!allDone}
          onPress={handleDone}
        >
          Done
        </HButton>
      )}
    </View>
  );

  return (
    <HScreen ambient footer={footer}>
      {/* Status Badge */}
      <View style={styles.statusRow}>
        <HBadge variant={isEnRoute ? 'purple' : 'success'} pulsing>
          {isEnRoute ? 'On the way' : 'In motion'}
        </HBadge>
        <HActivityIndicator active label="Live" />
      </View>

      <View style={styles.spacerLg} />

      {/* Task Info */}
      <HText variant="title2" color="primary">{task.title}</HText>
      <View style={styles.spacerSm} />
      <HText variant="body" color="secondary">For {task.posterName}</HText>
      <HText variant="caption" color="tertiary">📍 {task.address}</HText>

      <View style={styles.spacerLg} />

      {/* Payment - prominent, confident */}
      <HCard variant="success" padding="lg">
        <View style={styles.paymentRow}>
          <HText variant="body" color="secondary">You'll earn</HText>
          <HMoney amount={task.maxPay} size="lg" />
        </View>
        <View style={styles.spacerSm} />
        <HText variant="caption" color="success">
          +{task.baseXP + (task.bonusXP || 0)} XP • Payment secured
        </HText>
      </HCard>

      <View style={styles.spacerLg} />

      {/* Checklist - simple, confident */}
      <HText variant="headline" color="primary">Progress</HText>
      <View style={styles.spacerMd} />
      
      {checklist.map(item => (
        <TouchableOpacity
          key={item.id}
          onPress={() => toggleChecklistItem(item.id)}
          style={styles.checklistItem}
        >
          <HText variant="body" color={item.done ? 'success' : 'secondary'}>
            {item.done ? '✓' : '○'}
          </HText>
          <HText
            variant="body"
            color={item.done ? 'tertiary' : 'primary'}
            style={styles.checklistText}
          >
            {item.text}
          </HText>
        </TouchableOpacity>
      ))}

      <View style={styles.spacerLg} />

      {/* Quick Contact */}
      <HCard variant="default" padding="md">
        <View style={styles.contactRow}>
          <HText variant="body" color="secondary">
            Questions? Message {task.posterName.split(' ')[0]}
          </HText>
          <HButton variant="ghost" size="sm" onPress={handleChat}>
            Chat
          </HButton>
        </View>
      </HCard>
    </HScreen>
  );
}

const styles = StyleSheet.create({
  centered: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  statusRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  paymentRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  checklistItem: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingVertical: hustleSpacing.sm,
  },
  checklistText: {
    marginLeft: hustleSpacing.md,
    flex: 1,
  },
  contactRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  footerButtons: {
    gap: hustleSpacing.sm,
  },
  spacerSm: { height: hustleSpacing.sm },
  spacerMd: { height: hustleSpacing.md },
  spacerLg: { height: hustleSpacing.xl },
});

export default TaskInProgressScreen;
