import React, { useEffect, useState } from 'react';
import { Button, ScrollView, StyleSheet, Text, TextInput, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useRoute } from '@react-navigation/native';
import { TRPCClient } from '../../network/trpcClient';
import { GRAY } from '../../../constants/colors';
import { SPACING } from '../../../constants';

type BackendMessage = {
  id?: string;
  senderName?: string;
  content?: string;
  timestamp?: string;
};

export default function TaskConversationScreen() {
  const route = useRoute<any>();
  const taskId: string = route.params?.taskId ?? '';

  const [messages, setMessages] = useState<BackendMessage[]>([]);
  const [text, setText] = useState('');
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [sending, setSending] = useState(false);

  const fetchMessages = async () => {
    setLoading(true);
    setError(null);
    try {
      const response = await TRPCClient.shared.call<{ taskId: string }, BackendMessage[]>(
        'messaging',
        'getTaskMessages',
        'query',
        { taskId } as any
      );
      setMessages(Array.isArray(response) ? response : []);
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Failed to load messages');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    if (!taskId) return;

    (async () => {
      await fetchMessages();
      // SwiftUI marks messages as read when viewing the conversation.
      try {
        await TRPCClient.shared.call<{ taskId: string }, any>('messaging', 'markAllAsRead', 'mutation', { taskId } as any);
      } catch {
        // Best-effort; don't block UI
      }
    })();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [taskId]);

  const handleSend = async () => {
    if (!text.trim() || sending || !taskId) return;
    setSending(true);
    setError(null);
    try {
      await TRPCClient.shared.call<
        { taskId: string; messageType: string; content: string },
        any
      >('messaging', 'sendMessage', 'mutation', {
        taskId,
        messageType: 'TEXT',
        content: text.trim(),
      } as any);
      setText('');
      await fetchMessages();
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Failed to send message');
    } finally {
      setSending(false);
    }
  };

  return (
    <SafeAreaView style={styles.root} edges={['top']}>
      <View style={styles.header}>
        <Text style={styles.title}>Messages</Text>
        <Text style={styles.subtle}>Task: {taskId}</Text>
      </View>

      {error ? (
        <View style={styles.errorBox}>
          <Text style={styles.error}>{error}</Text>
        </View>
      ) : null}

      <ScrollView style={styles.list} contentContainerStyle={styles.listContent} showsVerticalScrollIndicator={false}>
        {loading ? (
          <Text style={styles.subtle}>Loading...</Text>
        ) : (
          messages.map((m) => (
            <View key={m.id ?? `${m.senderName}-${m.timestamp}`} style={styles.messageRow}>
              <Text style={styles.sender}>{m.senderName ?? 'Unknown'}</Text>
              <Text style={styles.content}>{m.content ?? ''}</Text>
            </View>
          ))
        )}
      </ScrollView>

      <View style={styles.composer}>
        <TextInput
          value={text}
          onChangeText={setText}
          placeholder="Type a message..."
          placeholderTextColor={GRAY[600]}
          style={styles.input}
          multiline
        />
        <View style={{ width: SPACING[2] }} />
        <Button title={sending ? 'Sending...' : 'Send'} onPress={handleSend} disabled={sending} />
      </View>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  root: { flex: 1, backgroundColor: GRAY[50] },
  header: { paddingHorizontal: SPACING[4], paddingTop: SPACING[3], paddingBottom: SPACING[2] },
  title: { fontSize: 20, fontWeight: '900', color: GRAY[900] },
  subtle: { marginTop: 4, color: GRAY[600], fontSize: 12, fontWeight: '700' },
  errorBox: { paddingHorizontal: SPACING[4], paddingBottom: SPACING[2] },
  error: { color: '#EF4444', fontWeight: '900' },
  list: { flex: 1 },
  listContent: { paddingHorizontal: SPACING[4], paddingBottom: SPACING[8], paddingTop: SPACING[2] },
  messageRow: {
    marginBottom: SPACING[3],
    borderRadius: 14,
    backgroundColor: '#fff',
    borderWidth: 1,
    borderColor: GRAY[200],
    padding: SPACING[3],
  },
  sender: { fontSize: 12, fontWeight: '900', color: GRAY[600] },
  content: { marginTop: 6, fontSize: 14, fontWeight: '800', color: GRAY[900], lineHeight: 18 },
  composer: {
    flexDirection: 'row',
    alignItems: 'flex-end',
    paddingHorizontal: SPACING[4],
    paddingVertical: SPACING[3],
    borderTopWidth: 1,
    borderTopColor: GRAY[200],
    backgroundColor: '#fff',
  },
  input: {
    flex: 1,
    maxHeight: 100,
    minHeight: 40,
    borderRadius: 12,
    backgroundColor: GRAY[50],
    paddingHorizontal: SPACING[3],
    paddingVertical: SPACING[2],
    fontSize: 14,
    fontWeight: '800',
    color: GRAY[900],
  },
});
