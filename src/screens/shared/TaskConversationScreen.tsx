import React, { useState } from 'react';
import { View, Text, StyleSheet, ScrollView, TextInput, TouchableOpacity } from 'react-native';
import { NEUTRAL, SPACING, FONT_SIZE, FONT_WEIGHT, RADIUS } from '../../constants';

export function TaskConversationScreen() {
  const [messageText, setMessageText] = useState('');

  // Stub data
  const task = {
    title: 'Fix Leaky Faucet',
  };
  const otherUser = {
    name: 'John Doe',
  };
  const messages = [
    { id: '1', text: 'Hello, I\'m on my way!', sender: 'other', timestamp: '10:30 AM' },
    { id: '2', text: 'Great, see you soon!', sender: 'me', timestamp: '10:31 AM' },
    { id: '3', text: 'I\'ve arrived at the location', sender: 'other', timestamp: '10:45 AM' },
  ];

  const handleSend = () => {
    if (messageText.trim()) {
      console.log('Send message:', messageText);
      setMessageText('');
    }
  };

  return (
    <View style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.headerTitle}>{task.title}</Text>
        <Text style={styles.headerSubtitle}>Chat with {otherUser.name}</Text>
      </View>

      <ScrollView style={styles.messagesContainer} contentContainerStyle={styles.messagesContent}>
        {messages.map((message) => (
          <View
            key={message.id}
            style={[
              styles.messageBubble,
              message.sender === 'me' ? styles.myMessage : styles.otherMessage,
            ]}
          >
            <Text style={styles.messageText}>{message.text}</Text>
            <Text style={styles.messageTimestamp}>{message.timestamp}</Text>
          </View>
        ))}
      </ScrollView>

      <View style={styles.inputContainer}>
        <TextInput
          style={styles.input}
          placeholder="Type a message..."
          value={messageText}
          onChangeText={setMessageText}
          multiline
          placeholderTextColor={NEUTRAL.TEXT_TERTIARY}
        />
        <TouchableOpacity style={styles.sendButton} onPress={handleSend}>
          <Text style={styles.sendButtonText}>Send</Text>
        </TouchableOpacity>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: NEUTRAL.BACKGROUND,
  },
  header: {
    padding: SPACING[4],
    backgroundColor: NEUTRAL.BACKGROUND_SECONDARY,
    borderBottomWidth: 1,
    borderBottomColor: NEUTRAL.BORDER,
  },
  headerTitle: {
    fontSize: FONT_SIZE.lg,
    fontWeight: FONT_WEIGHT.bold,
    color: NEUTRAL.TEXT,
    marginBottom: SPACING[1],
  },
  headerSubtitle: {
    fontSize: FONT_SIZE.sm,
    color: NEUTRAL.TEXT_SECONDARY,
  },
  messagesContainer: {
    flex: 1,
  },
  messagesContent: {
    padding: SPACING[4],
  },
  messageBubble: {
    maxWidth: '75%',
    padding: SPACING[3],
    borderRadius: RADIUS.lg,
    marginBottom: SPACING[2],
  },
  myMessage: {
    backgroundColor: '#3B82F6',
    alignSelf: 'flex-end',
  },
  otherMessage: {
    backgroundColor: NEUTRAL.BACKGROUND_SECONDARY,
    alignSelf: 'flex-start',
  },
  messageText: {
    fontSize: FONT_SIZE.base,
    color: NEUTRAL.TEXT,
    marginBottom: SPACING[1],
  },
  messageTimestamp: {
    fontSize: FONT_SIZE.xs,
    color: NEUTRAL.TEXT_TERTIARY,
  },
  inputContainer: {
    flexDirection: 'row',
    padding: SPACING[3],
    backgroundColor: NEUTRAL.BACKGROUND_SECONDARY,
    borderTopWidth: 1,
    borderTopColor: NEUTRAL.BORDER,
    alignItems: 'flex-end',
  },
  input: {
    flex: 1,
    minHeight: 40,
    maxHeight: 100,
    padding: SPACING[2],
    backgroundColor: NEUTRAL.BACKGROUND,
    borderRadius: RADIUS.md,
    fontSize: FONT_SIZE.base,
    color: NEUTRAL.TEXT,
    marginRight: SPACING[2],
  },
  sendButton: {
    paddingVertical: SPACING[2],
    paddingHorizontal: SPACING[4],
    backgroundColor: '#3B82F6',
    borderRadius: RADIUS.md,
  },
  sendButtonText: {
    color: NEUTRAL.TEXT_INVERSE,
    fontSize: FONT_SIZE.base,
    fontWeight: FONT_WEIGHT.semibold,
  },
});
