import React from 'react';
import { ScrollView, StyleSheet, Text, TouchableOpacity, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { GRAY } from '../../../constants/colors';
import { SPACING } from '../../../constants';

export default function SupportScreen() {
  return (
    <SafeAreaView style={styles.root} edges={['top']}>
      <ScrollView contentContainerStyle={styles.scrollContent} showsVerticalScrollIndicator={false}>
        <Text style={styles.title}>Help & Support</Text>

        <View style={styles.card}>
          <Text style={styles.cardTitle}>Quick answers</Text>

          <FAQRow title="How do tasks work?" />
          <FAQRow title="How do I submit proof?" />
          <FAQRow title="What happens if my proof is rejected?" />
          <FAQRow title="How does escrow work?" />
        </View>

        <View style={styles.card}>
          <Text style={styles.cardTitle}>Contact</Text>
          <TouchableOpacity style={styles.action} onPress={() => {}} activeOpacity={0.85}>
            <Text style={styles.actionText}>Email support</Text>
          </TouchableOpacity>
          <TouchableOpacity style={styles.action} onPress={() => {}} activeOpacity={0.85}>
            <Text style={styles.actionText}>Report an issue</Text>
          </TouchableOpacity>
        </View>

        <View style={{ height: SPACING[8] }} />
      </ScrollView>
    </SafeAreaView>
  );
}

function FAQRow({ title }: { title: string }) {
  return (
    <View style={styles.faqRow}>
      <Text style={styles.faqText}>{title}</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  root: { flex: 1, backgroundColor: GRAY[50] },
  scrollContent: { paddingHorizontal: SPACING[4], paddingTop: SPACING[3], paddingBottom: 32 },
  title: { fontSize: 22, fontWeight: '900', color: GRAY[900], marginBottom: SPACING[4] },
  card: { backgroundColor: '#fff', borderRadius: 16, borderWidth: 1, borderColor: GRAY[200], padding: SPACING[4], marginBottom: SPACING[4] },
  cardTitle: { color: GRAY[600], fontSize: 13, fontWeight: '900', marginBottom: SPACING[2] },
  faqRow: { paddingVertical: SPACING[2], borderTopWidth: 1, borderTopColor: GRAY[200] },
  faqText: { color: GRAY[900], fontSize: 14, fontWeight: '800' },
  action: { paddingVertical: SPACING[2], borderTopWidth: 1, borderTopColor: GRAY[200] },
  actionText: { color: GRAY[900], fontSize: 14, fontWeight: '900' },
});
