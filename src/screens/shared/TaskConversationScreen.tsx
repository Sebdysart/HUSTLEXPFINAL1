/**
 * TaskConversationScreen - Task-specific chat
 */

import React, { useState } from 'react';
import { View, StyleSheet, ScrollView, TextInput, TouchableOpacity } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
// import { useNavigation } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import type { RootStackParamList } from '../../navigation/types';

// type NavigationProp = NativeStackNavigationProp<RootStackParamList>;
import { Text, Spacing, MoneyDisplay } from '../../components';
import { theme } from '../../theme';

export function TaskConversationScreen() {
  const insets = useSafeAreaInsets();
  // Navigation available via useNavigation<NavigationProp>() when needed
  const [message, setMessage] = useState('');

  return (
    <View style={[styles.container, { paddingTop: insets.top, paddingBottom: insets.bottom }]}>
      {/* Task Context Header */}
      <View style={styles.taskHeader}>
        <View style={styles.taskInfo}>
          <Text variant="headline" color="primary">Help moving furniture</Text>
          <Text variant="caption" color="secondary">In Progress</Text>
        </View>
        <MoneyDisplay amount={75} size="sm" />
      </View>

      {/* Messages */}
      <ScrollView contentContainerStyle={styles.messages}>
        <SystemMessage text="Task started. You can now message each other." />
        <Spacing size={16} />
        <ChatBubble sender="hustler" name="John" text="I'm on my way!" time="2:30 PM" />
        <ChatBubble sender="poster" name="You" text="Great, gate code is 1234" time="2:31 PM" />
        <ChatBubble sender="hustler" name="John" text="Thanks! ETA 10 min" time="2:32 PM" />
      </ScrollView>

      {/* Input */}
      <View style={styles.inputContainer}>
        <TextInput
          style={styles.input}
          placeholder="Message about this task..."
          placeholderTextColor={theme.colors.text.tertiary}
          value={message}
          onChangeText={setMessage}
        />
        <TouchableOpacity style={styles.sendBtn}>
          <Text variant="headline" color="inverse">↑</Text>
        </TouchableOpacity>
      </View>
    </View>
  );
}

function SystemMessage({ text }: { text: string }) {
  return (
    <View style={styles.systemMsg}>
      <Text variant="caption" color="tertiary" align="center">{text}</Text>
    </View>
  );
}

function ChatBubble({ sender, name, text, time }: {
  sender: 'hustler' | 'poster';
  name: string;
  text: string;
  time: string;
}) {
  const isMe = sender === 'poster';
  return (
    <View style={[styles.bubbleRow, isMe && styles.bubbleRowMe]}>
      <View style={[styles.bubble, isMe ? styles.bubbleMe : styles.bubbleOther]}>
        {!isMe && <Text variant="caption" color="brand">{name}</Text>}
        <Text variant="body" color={isMe ? 'inverse' : 'primary'}>{text}</Text>
        <Text variant="caption" color={isMe ? 'inverse' : 'tertiary'}>{time}</Text>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: theme.colors.surface.primary },
  taskHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    padding: theme.spacing[4],
    borderBottomWidth: 1,
    borderBottomColor: theme.colors.surface.secondary,
    backgroundColor: theme.colors.surface.secondary,
  },
  taskInfo: { flex: 1 },
  messages: { padding: theme.spacing[4] },
  systemMsg: { paddingVertical: theme.spacing[2] },
  bubbleRow: { marginBottom: theme.spacing[3] },
  bubbleRowMe: { alignItems: 'flex-end' },
  bubble: { maxWidth: '75%', padding: theme.spacing[3], borderRadius: theme.radii.md },
  bubbleMe: { backgroundColor: theme.colors.brand.primary, borderBottomRightRadius: theme.radii.xs },
  bubbleOther: { backgroundColor: theme.colors.surface.secondary, borderBottomLeftRadius: theme.radii.xs },
  inputContainer: { flexDirection: 'row', padding: theme.spacing[4], borderTopWidth: 1, borderTopColor: theme.colors.surface.secondary },
  input: { flex: 1, backgroundColor: theme.colors.surface.secondary, borderRadius: theme.radii.full, paddingHorizontal: theme.spacing[4], paddingVertical: theme.spacing[3], color: theme.colors.text.primary, fontSize: 16 },
  sendBtn: { width: 44, height: 44, borderRadius: 22, backgroundColor: theme.colors.brand.primary, justifyContent: 'center', alignItems: 'center', marginLeft: theme.spacing[2] },
});

export default TaskConversationScreen;
