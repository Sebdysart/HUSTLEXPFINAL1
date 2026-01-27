/**
 * TaskInProgressScreen - Currently working on a task
 */

import React, { useState, useEffect } from 'react';
import { View, StyleSheet, ScrollView, TouchableOpacity, Alert } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { useNavigation, useRoute, RouteProp } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import { Text, Spacing, Card, MoneyDisplay, Button } from '../../components';
import { theme } from '../../theme';
import { useTaskStore } from '../../store';
import type { RootStackParamList } from '../../navigation/types';

type NavigationProp = NativeStackNavigationProp<RootStackParamList>;
type TaskInProgressRouteProp = RouteProp<RootStackParamList, 'TaskInProgress'>;

export function TaskInProgressScreen() {
  const insets = useSafeAreaInsets();
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
  const [elapsedTime, setElapsedTime] = useState(0);

  useEffect(() => {
    if (task) {
      setActiveTask(task);
      // Start task if not already started
      if (task.status === 'claimed') {
        updateTask(taskId, { status: 'in_progress', startedAt: new Date().toISOString() });
      }
    }
  }, [task, taskId, setActiveTask, updateTask]);

  // Timer
  useEffect(() => {
    const interval = setInterval(() => {
      if (task?.startedAt) {
        const start = new Date(task.startedAt).getTime();
        setElapsedTime(Math.floor((Date.now() - start) / 1000));
      }
    }, 1000);
    return () => clearInterval(interval);
  }, [task?.startedAt]);

  const toggleChecklistItem = (id: number) => {
    setChecklist(prev => prev.map(item => 
      item.id === id ? { ...item, done: !item.done } : item
    ));
  };

  const handleEnRoute = () => {
    updateTask(taskId, { status: 'en_route' });
    navigation.navigate('HustlerEnRouteMap', { taskId });
  };

  const handleSubmitCompletion = () => {
    const allDone = checklist.every(item => item.done);
    if (!allDone) {
      Alert.alert('Incomplete', 'Please complete all checklist items before submitting.');
      return;
    }
    navigation.navigate('TaskCompletionHustler', { taskId });
  };

  const handleChat = () => {
    navigation.navigate('TaskConversation', { taskId });
  };

  const handleReport = () => {
    navigation.navigate('DisputeEntry', { taskId });
  };

  const formatTime = (seconds: number) => {
    const hrs = Math.floor(seconds / 3600);
    const mins = Math.floor((seconds % 3600) / 60);
    const secs = seconds % 60;
    if (hrs > 0) return `${hrs}h ${mins}m`;
    if (mins > 0) return `${mins}m ${secs}s`;
    return `${secs}s`;
  };

  if (!task) {
    return (
      <View style={[styles.container, styles.centered, { paddingTop: insets.top }]}>
        <Text variant="body" color="secondary">Task not found</Text>
        <Spacing size={12} />
        <Button variant="secondary" size="sm" onPress={() => navigation.goBack()}>
          Go Back
        </Button>
      </View>
    );
  }

  const isEnRoute = task.status === 'en_route';
  const isArrived = task.status === 'arrived' || task.status === 'in_progress';

  return (
    <View style={[styles.container, { paddingTop: insets.top, paddingBottom: insets.bottom }]}>
      <ScrollView contentContainerStyle={styles.scroll}>
        {/* Status Banner */}
        <View style={[styles.statusBanner, isEnRoute && styles.statusEnRoute]}>
          <Text variant="headline" color="inverse">
            {isEnRoute ? '🚗 En Route' : '🔨 Task In Progress'}
          </Text>
          <Text variant="caption" color="inverse">{formatTime(elapsedTime)}</Text>
        </View>

        <Spacing size={20} />

        {/* Task Info */}
        <Text variant="title1" color="primary">{task.title}</Text>
        <Spacing size={4} />
        <Text variant="footnote" color="secondary">For {task.posterName}</Text>
        <Spacing size={4} />
        <Text variant="footnote" color="tertiary">📍 {task.address}</Text>

        <Spacing size={20} />

        {/* Payment Info */}
        <Card variant="elevated" padding="md">
          <View style={styles.paymentRow}>
            <Text variant="body" color="secondary">You'll earn</Text>
            <MoneyDisplay amount={task.maxPay} size="lg" />
          </View>
          <Spacing size={8} />
          <View style={styles.xpRow}>
            <Text variant="caption" color="success">+{task.baseXP} XP</Text>
            {task.bonusXP && <Text variant="caption" color="success"> + {task.bonusXP} bonus</Text>}
          </View>
          <Spacing size={4} />
          <Text variant="caption" color="tertiary">Released after poster approves</Text>
        </Card>

        <Spacing size={20} />

        {/* Checklist */}
        <Text variant="headline" color="primary">Task Checklist</Text>
        <Spacing size={12} />
        {checklist.map(item => (
          <TouchableOpacity key={item.id} onPress={() => toggleChecklistItem(item.id)}>
            <ChecklistItem text={item.text} done={item.done} />
          </TouchableOpacity>
        ))}

        <Spacing size={20} />

        {/* Contact */}
        <Card variant="default" padding="md">
          <Text variant="headline" color="primary">Need help?</Text>
          <Spacing size={8} />
          <View style={styles.contactRow}>
            <Button variant="secondary" size="sm" onPress={handleChat}>
              {`Message ${task.posterName.split(' ')[0]}`}
            </Button>
            <Button variant="ghost" size="sm" onPress={handleReport}>
              Report Issue
            </Button>
          </View>
        </Card>
      </ScrollView>

      {/* CTA */}
      <View style={styles.footer}>
        {!isArrived && !isEnRoute ? (
          <Button variant="primary" size="lg" onPress={handleEnRoute}>
            Start Navigation
          </Button>
        ) : (
          <Button 
            variant="primary" 
            size="lg" 
            onPress={handleSubmitCompletion}
            disabled={!checklist.every(item => item.done)}
          >
            Submit Completion
          </Button>
        )}
      </View>
    </View>
  );
}

function ChecklistItem({ text, done }: { text: string; done: boolean }) {
  return (
    <View style={styles.checklistItem}>
      <Text variant="body">{done ? '✅' : '⬜'}</Text>
      <Text variant="body" color={done ? 'secondary' : 'primary'} style={styles.checklistText}>{text}</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: theme.colors.surface.primary },
  centered: { justifyContent: 'center', alignItems: 'center' },
  scroll: { padding: theme.spacing[4] },
  statusBanner: { 
    backgroundColor: theme.colors.brand.primary, 
    padding: theme.spacing[4], 
    borderRadius: theme.radii.md, 
    alignItems: 'center',
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  statusEnRoute: { backgroundColor: theme.colors.semantic.info },
  paymentRow: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center' },
  xpRow: { flexDirection: 'row' },
  checklistItem: { flexDirection: 'row', alignItems: 'center', marginBottom: theme.spacing[3] },
  checklistText: { marginLeft: theme.spacing[3] },
  contactRow: { flexDirection: 'row', gap: theme.spacing[3] },
  footer: { padding: theme.spacing[4], borderTopWidth: 1, borderTopColor: theme.colors.surface.secondary },
});

export default TaskInProgressScreen;
