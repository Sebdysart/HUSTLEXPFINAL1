/**
 * ChatScreen - In-app messaging
 * 
 * Archetype: Interrupt
 * Emotion: "The system has this under control"
 * - Calm, natural messaging
 * - Theirs = dark card, yours = purple subtle
 * - Input always visible, send obvious
 * - No typing indicators (feels watched)
 */

import React, { useState, useRef } from 'react';
import { View, StyleSheet, ScrollView, KeyboardAvoidingView, Platform } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { useNavigation } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import type { RootStackParamList } from '../../navigation/types';

import { HScreen, HCard, HText, HButton, HInput } from '../../components/atoms';
import { hustleColors, hustleSpacing, hustleRadii } from '../../theme/hustle-tokens';

type NavigationProp = NativeStackNavigationProp<RootStackParamList>;

interface Message {
  id: string;
  sender: 'me' | 'other';
  text: string;
  time: string;
}

const MOCK_MESSAGES: Message[] = [
  { id: '1', sender: 'other', text: 'Hi! I\'m on my way now', time: '2:30 PM' },
  { id: '2', sender: 'me', text: 'Great, see you soon!', time: '2:31 PM' },
  { id: '3', sender: 'other', text: 'Should I bring any tools?', time: '2:32 PM' },
  { id: '4', sender: 'me', text: 'No, I have everything we need', time: '2:33 PM' },
  { id: '5', sender: 'other', text: 'Perfect, ETA 10 minutes', time: '2:35 PM' },
];

export function ChatScreen() {
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
        {/* Header - calm, informative */}
        <View style={[styles.header, { paddingTop: insets.top + hustleSpacing.sm }]}>
          <HButton variant="ghost" size="sm" onPress={handleBack}>
            ← Back
          </HButton>
          <View style={styles.headerCenter}>
            <View style={styles.avatar}>
              <HText variant="body">👤</HText>
            </View>
            <View style={styles.headerInfo}>
              <HText variant="headline" color="primary">John D.</HText>
              <HText variant="caption" color="secondary">Available</HText>
            </View>
          </View>
          <View style={styles.headerSpacer} />
        </View>

        {/* Messages */}
        <ScrollView 
          ref={scrollRef}
          style={styles.messagesContainer}
          contentContainerStyle={styles.messages}
          onContentSizeChange={() => scrollRef.current?.scrollToEnd({ animated: false })}
        >
          {MOCK_MESSAGES.map(msg => (
            <ChatBubble key={msg.id} message={msg} />
          ))}
        </ScrollView>

        {/* Input - always visible, obvious send */}
        <View style={[styles.inputContainer, { paddingBottom: insets.bottom + hustleSpacing.md }]}>
          <View style={styles.inputRow}>
            <HInput
              placeholder="Type a message..."
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

function ChatBubble({ message }: { message: Message }) {
  const isMe = message.sender === 'me';
  
  return (
    <View style={[styles.bubbleRow, isMe && styles.bubbleRowMe]}>
      <View style={[
        styles.bubble, 
        isMe ? styles.bubbleMe : styles.bubbleOther
      ]}>
        <HText variant="body" color={isMe ? 'primary' : 'primary'}>
          {message.text}
        </HText>
        <HText 
          variant="caption" 
          color="tertiary" 
          style={styles.time}
        >
          {message.time}
        </HText>
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
    paddingBottom: hustleSpacing.md,
    borderBottomWidth: 1,
    borderBottomColor: hustleColors.dark.border,
  },
  headerCenter: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
  },
  avatar: {
    width: 36,
    height: 36,
    borderRadius: 18,
    backgroundColor: hustleColors.dark.surface,
    justifyContent: 'center',
    alignItems: 'center',
  },
  headerInfo: { 
    marginLeft: hustleSpacing.sm,
  },
  headerSpacer: { width: 60 },
  messagesContainer: {
    flex: 1,
  },
  messages: { 
    padding: hustleSpacing.lg,
    paddingBottom: hustleSpacing.xl,
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

export default ChatScreen;
