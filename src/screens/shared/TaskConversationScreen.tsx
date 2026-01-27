/**
 * TaskConversationScreen - Task-specific chat
 * 
 * Archetype: Interrupt
 * Emotion: "The system has this under control"
 * - Task context always visible but not intrusive
 * - Natural messaging flow
 * - Theirs = dark card, yours = purple subtle
 * - System messages feel neutral, informative
 */

import React, { useState, useRef } from 'react';
import { View, StyleSheet, ScrollView, KeyboardAvoidingView, Platform } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { useNavigation } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import type { RootStackParamList } from '../../navigation/types';

import { HScreen, HCard, HText, HButton, HInput } from '../../components/atoms';
import { MoneyDisplay } from '../../components';
import { hustleColors, hustleSpacing, hustleRadii } from '../../theme/hustle-tokens';

type NavigationProp = NativeStackNavigationProp<RootStackParamList>;

interface ChatMessage {
  id: string;
  type: 'system' | 'message';
  sender?: 'hustler' | 'poster';
  name?: string;
  text: string;
  time?: string;
}

const MOCK_MESSAGES: ChatMessage[] = [
  { id: '0', type: 'system', text: 'Task started. You can message each other now.' },
  { id: '1', type: 'message', sender: 'hustler', name: 'John', text: 'I\'m on my way!', time: '2:30 PM' },
  { id: '2', type: 'message', sender: 'poster', name: 'You', text: 'Great, gate code is 1234', time: '2:31 PM' },
  { id: '3', type: 'message', sender: 'hustler', name: 'John', text: 'Thanks! See you in about 10 minutes', time: '2:32 PM' },
];

export function TaskConversationScreen() {
  const insets = useSafeAreaInsets();
  const navigation = useNavigation<NavigationProp>();
  const [message, setMessage] = useState('');
  const scrollRef = useRef<ScrollView>(null);

  const handleSend = () => {
    if (message.trim()) {
      console.log('Send:', message);
      setMessage('');
    }
  };

  const handleBack = () => navigation.goBack();

  return (
    <HScreen ambient={false}>
      <KeyboardAvoidingView 
        style={styles.container} 
        behavior={Platform.OS === 'ios' ? 'padding' : undefined}
        keyboardVerticalOffset={insets.top}
      >
        {/* Task Context Header - calm, informative */}
        <View style={[styles.header, { paddingTop: insets.top + hustleSpacing.sm }]}>
          <HButton variant="ghost" size="sm" onPress={handleBack}>
            ← Back
          </HButton>
        </View>
        
        <HCard variant="default" padding="md" style={styles.taskContext}>
          <View style={styles.taskRow}>
            <View style={styles.taskInfo}>
              <HText variant="headline" color="primary">Help moving furniture</HText>
              <HText variant="caption" color="secondary" style={styles.taskMeta}>
                In Progress
              </HText>
            </View>
            <MoneyDisplay amount={75} size="sm" />
          </View>
        </HCard>

        {/* Messages */}
        <ScrollView 
          ref={scrollRef}
          style={styles.messagesContainer}
          contentContainerStyle={styles.messages}
          onContentSizeChange={() => scrollRef.current?.scrollToEnd({ animated: false })}
        >
          {MOCK_MESSAGES.map(msg => (
            msg.type === 'system' 
              ? <SystemMessage key={msg.id} text={msg.text} />
              : <ChatBubble key={msg.id} message={msg} />
          ))}
        </ScrollView>

        {/* Input */}
        <View style={[styles.inputContainer, { paddingBottom: insets.bottom + hustleSpacing.md }]}>
          <View style={styles.inputRow}>
            <HInput
              placeholder="Message about this task..."
              value={message}
              onChangeText={setMessage}
              style={styles.input}
              onSubmitEditing={handleSend}
              returnKeyType="send"
            />
            <HButton 
              variant="primary" 
              size="sm" 
              onPress={handleSend}
              disabled={!message.trim()}
              style={styles.sendBtn}
            >
              ↑
            </HButton>
          </View>
        </View>
      </KeyboardAvoidingView>
    </HScreen>
  );
}

function SystemMessage({ text }: { text: string }) {
  return (
    <View style={styles.systemMsg}>
      <HText variant="caption" color="tertiary" center>{text}</HText>
    </View>
  );
}

function ChatBubble({ message }: { message: ChatMessage }) {
  const isMe = message.sender === 'poster';
  
  return (
    <View style={[styles.bubbleRow, isMe && styles.bubbleRowMe]}>
      <View style={[
        styles.bubble, 
        isMe ? styles.bubbleMe : styles.bubbleOther
      ]}>
        {!isMe && message.name && (
          <HText variant="caption" color="secondary" style={styles.senderName}>
            {message.name}
          </HText>
        )}
        <HText variant="body" color="primary">
          {message.text}
        </HText>
        {message.time && (
          <HText variant="caption" color="tertiary" style={styles.time}>
            {message.time}
          </HText>
        )}
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { 
    flex: 1,
  },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: hustleSpacing.md,
    paddingBottom: hustleSpacing.sm,
  },
  taskContext: {
    marginHorizontal: hustleSpacing.lg,
    marginBottom: hustleSpacing.sm,
  },
  taskRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  taskInfo: {
    flex: 1,
    marginRight: hustleSpacing.md,
  },
  taskMeta: {
    flexDirection: 'row',
    marginTop: hustleSpacing.xs,
  },
  messagesContainer: {
    flex: 1,
  },
  messages: { 
    padding: hustleSpacing.lg,
    paddingBottom: hustleSpacing.xl,
  },
  systemMsg: { 
    paddingVertical: hustleSpacing.md,
  },
  bubbleRow: { 
    marginBottom: hustleSpacing.sm,
    alignItems: 'flex-start',
  },
  bubbleRowMe: { 
    alignItems: 'flex-end',
  },
  bubble: {
    maxWidth: '75%',
    paddingVertical: hustleSpacing.sm,
    paddingHorizontal: hustleSpacing.md,
    borderRadius: hustleRadii.lg,
  },
  // Theirs = dark card
  bubbleOther: {
    backgroundColor: hustleColors.dark.elevated,
    borderBottomLeftRadius: hustleRadii.xs,
  },
  // Yours = purple subtle
  bubbleMe: {
    backgroundColor: hustleColors.purple.deep,
    borderBottomRightRadius: hustleRadii.xs,
  },
  senderName: {
    marginBottom: hustleSpacing.xs,
  },
  time: { 
    marginTop: hustleSpacing.xs,
    textAlign: 'right',
  },
  inputContainer: {
    paddingHorizontal: hustleSpacing.lg,
    paddingTop: hustleSpacing.md,
    borderTopWidth: 1,
    borderTopColor: hustleColors.dark.border,
    backgroundColor: hustleColors.dark.base,
  },
  inputRow: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  input: {
    flex: 1,
    marginRight: hustleSpacing.sm,
  },
  sendBtn: {
    width: 44,
    height: 44,
    borderRadius: 22,
    paddingHorizontal: 0,
  },
});

export default TaskConversationScreen;
