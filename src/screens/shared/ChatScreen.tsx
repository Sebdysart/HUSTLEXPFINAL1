/**
 * ChatScreen - In-app messaging
 */

import React, { useState } from 'react';
import { View, StyleSheet, ScrollView, TextInput, TouchableOpacity } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { useNavigation } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import type { RootStackParamList } from '../../navigation/types';

type NavigationProp = NativeStackNavigationProp<RootStackParamList>;
import { Text } from '../../components';
import { theme } from '../../theme';

const MOCK_MESSAGES = [
  { id: '1', sender: 'other', text: 'Hi! I\'m on my way now', time: '2:30 PM' },
  { id: '2', sender: 'me', text: 'Great, see you soon!', time: '2:31 PM' },
  { id: '3', sender: 'other', text: 'Should I bring any tools?', time: '2:32 PM' },
  { id: '4', sender: 'me', text: 'No, I have everything we need', time: '2:33 PM' },
  { id: '5', sender: 'other', text: 'Perfect, ETA 10 minutes', time: '2:35 PM' },
];

export function ChatScreen() {
  const insets = useSafeAreaInsets();
  // Navigation available via useNavigation<NavigationProp>() when needed
  const [message, setMessage] = useState('');

  const handleSend = () => {
    if (message.trim()) {
      console.log('Send:', message);
      setMessage('');
    }
  };

  return (
    <View style={[styles.container, { paddingTop: insets.top, paddingBottom: insets.bottom }]}>
      {/* Header */}
      <View style={styles.header}>
        <View style={styles.avatar}>
          <Text variant="body">👤</Text>
        </View>
        <View style={styles.headerInfo}>
          <Text variant="headline" color="primary">John D.</Text>
          <Text variant="caption" color="success">Online</Text>
        </View>
      </View>

      {/* Messages */}
      <ScrollView contentContainerStyle={styles.messages}>
        {MOCK_MESSAGES.map(msg => (
          <View key={msg.id} style={[styles.msgRow, msg.sender === 'me' && styles.msgRowMe]}>
            <View style={[styles.bubble, msg.sender === 'me' ? styles.bubbleMe : styles.bubbleOther]}>
              <Text variant="body" color={msg.sender === 'me' ? 'inverse' : 'primary'}>{msg.text}</Text>
              <Text variant="caption" color={msg.sender === 'me' ? 'inverse' : 'tertiary'} style={styles.time}>
                {msg.time}
              </Text>
            </View>
          </View>
        ))}
      </ScrollView>

      {/* Input */}
      <View style={styles.inputContainer}>
        <TextInput
          style={styles.input}
          placeholder="Type a message..."
          placeholderTextColor={theme.colors.text.tertiary}
          value={message}
          onChangeText={setMessage}
        />
        <TouchableOpacity style={styles.sendBtn} onPress={handleSend}>
          <Text variant="headline" color="inverse">↑</Text>
        </TouchableOpacity>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: theme.colors.surface.primary },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    padding: theme.spacing[4],
    borderBottomWidth: 1,
    borderBottomColor: theme.colors.surface.secondary,
  },
  avatar: {
    width: 40,
    height: 40,
    borderRadius: 20,
    backgroundColor: theme.colors.surface.tertiary,
    justifyContent: 'center',
    alignItems: 'center',
  },
  headerInfo: { marginLeft: theme.spacing[3] },
  messages: { padding: theme.spacing[4] },
  msgRow: { marginBottom: theme.spacing[3] },
  msgRowMe: { alignItems: 'flex-end' },
  bubble: {
    maxWidth: '75%',
    padding: theme.spacing[3],
    borderRadius: theme.radii.md,
  },
  bubbleMe: {
    backgroundColor: theme.colors.brand.primary,
    borderBottomRightRadius: theme.radii.xs,
  },
  bubbleOther: {
    backgroundColor: theme.colors.surface.secondary,
    borderBottomLeftRadius: theme.radii.xs,
  },
  time: { marginTop: theme.spacing[1] },
  inputContainer: {
    flexDirection: 'row',
    padding: theme.spacing[4],
    borderTopWidth: 1,
    borderTopColor: theme.colors.surface.secondary,
  },
  input: {
    flex: 1,
    backgroundColor: theme.colors.surface.secondary,
    borderRadius: theme.radii.full,
    paddingHorizontal: theme.spacing[4],
    paddingVertical: theme.spacing[3],
    color: theme.colors.text.primary,
    fontSize: 16,
  },
  sendBtn: {
    width: 44,
    height: 44,
    borderRadius: 22,
    backgroundColor: theme.colors.brand.primary,
    justifyContent: 'center',
    alignItems: 'center',
    marginLeft: theme.spacing[2],
  },
});

export default ChatScreen;
