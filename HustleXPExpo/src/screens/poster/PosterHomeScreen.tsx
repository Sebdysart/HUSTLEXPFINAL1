import React from 'react';
import { StyleSheet, Text, TouchableOpacity, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useNavigation } from '@react-navigation/native';
import { SPACING } from '../../../constants';
import { GRAY } from '../../../constants/colors';

export default function PosterHomeScreen() {
  const navigation = useNavigation<any>();

  return (
    <SafeAreaView style={styles.root} edges={['top']}>
      <View style={styles.content}>
        <Text style={styles.title}>Post a task</Text>
        <Text style={styles.subtitle}>Create an opportunity, fund escrow, and get worker proof.</Text>

        <TouchableOpacity
          style={styles.primaryButton}
          onPress={() => navigation.navigate('TaskCreation')}
        >
          <Text style={styles.primaryButtonText}>Create Task</Text>
        </TouchableOpacity>

        <Text style={styles.note}>
          Tip: This RN port wires the core flow (create to escrow to feed). Other poster screens are still being ported.
        </Text>
      </View>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  root: { flex: 1, backgroundColor: GRAY[50] },
  content: { flex: 1, paddingHorizontal: SPACING[4], paddingTop: SPACING[4] },
  title: { fontSize: 22, fontWeight: '800', color: GRAY[900], marginBottom: 10 },
  subtitle: { fontSize: 14, color: GRAY[600], lineHeight: 20, marginBottom: SPACING[5] },
  primaryButton: {
    height: 52,
    backgroundColor: '#5B2DFF',
    borderRadius: 14,
    alignItems: 'center',
    justifyContent: 'center',
    marginBottom: SPACING[4],
  },
  primaryButtonText: { color: '#FFF', fontWeight: '800', fontSize: 16 },
  note: { color: GRAY[600], fontSize: 13, lineHeight: 18 },
});
