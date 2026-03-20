import React, { useState } from 'react';
import { Image, StyleSheet, Text, TextInput, TouchableOpacity, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useNavigation, useRoute } from '@react-navigation/native';
import { StatusBanner } from '../../components/molecules';
import { SPACING } from '../../../constants';
import { GRAY } from '../../../constants/colors';
import { TRPCClient } from '../../network/trpcClient';

export default function ProofSubmissionScreen() {
  const navigation = useNavigation<any>();
  const route = useRoute<any>();
  const taskId: string = route.params?.taskId ?? 'task-1';

  const [notes, setNotes] = useState('');
  const [photoUri, setPhotoUri] = useState<string | null>(null);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const pickPhoto = async () => {
    setError(null);
    try {
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      const mod: any = require('react-native-image-picker');
      const result = await mod.launchImageLibrary({
        mediaType: 'photo',
        selectionLimit: 1,
        quality: 0.8,
      });

      const asset = result.assets?.[0];
      if (asset?.uri) setPhotoUri(asset.uri);
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Failed to pick photo');
    }
  };

  const uploadPhotoToR2 = async (uri: string) => {
    const blob = await (await fetch(uri)).blob();
    const fileSize = blob.size;

    const presigned: { uploadUrl: string; publicUrl: string } = await TRPCClient.shared.call<
      {
        taskId: string;
        filename: string;
        contentType: string;
        fileSize?: number | null;
        purpose?: string | null;
      },
      any
    >('upload', 'getPresignedUrl', 'mutation', {
      taskId,
      filename: 'proof.jpg',
      contentType: 'image/jpeg',
      fileSize,
      purpose: 'proof',
    });

    const uploadRes = await fetch(presigned.uploadUrl, {
      method: 'PUT',
      headers: {
        'Content-Type': 'image/jpeg',
        'Content-Length': String(fileSize),
      },
      body: blob,
    });

    if (!uploadRes.ok) {
      throw new Error(`R2 upload failed (HTTP ${uploadRes.status})`);
    }

    return presigned.publicUrl;
  };

  const handleSubmit = async () => {
    if (isSubmitting) return;
    setIsSubmitting(true);
    setError(null);
    try {
      if (!photoUri) {
        throw new Error('Please choose a photo proof.');
      }

      const publicUrl = await uploadPhotoToR2(photoUri);

      await TRPCClient.shared.call<
        {
          taskId: string;
          photoUrls: string[];
          notes: string | null;
          gpsLatitude: number | null;
          gpsLongitude: number | null;
          biometricHash: string | null;
        },
        any
      >('task', 'submitProof', 'mutation', {
        taskId,
        photoUrls: [publicUrl],
        notes: notes.trim().length ? notes.trim() : null,
        gpsLatitude: null,
        gpsLongitude: null,
        biometricHash: null,
      });
      navigation.navigate('TaskCompletion', { taskId });
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Failed to submit proof');
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <SafeAreaView style={styles.root} edges={['top']}>
      <View style={styles.content}>
        <Text style={styles.title}>Submit proof</Text>
        <Text style={styles.subtitle}>Choose a photo proof and optionally add notes for the poster.</Text>

        {error ? (
          <View style={styles.banner}>
            <StatusBanner tone="danger" text={error} />
          </View>
        ) : null}

        <TouchableOpacity
          style={[styles.photoButton, isSubmitting ? { opacity: 0.7 } : null]}
          disabled={isSubmitting}
          onPress={pickPhoto}
        >
          <Text style={styles.photoButtonText}>{photoUri ? 'Change photo' : 'Choose photo proof'}</Text>
        </TouchableOpacity>

        {photoUri ? (
          <View style={styles.photoPreview}>
            <Image source={{ uri: photoUri }} style={styles.photoImage} />
          </View>
        ) : null}

        <View style={styles.field}>
          <Text style={styles.label}>Notes</Text>
          <TextInput
            style={styles.input}
            placeholder="What did you do? Any details the poster should know."
            placeholderTextColor="rgba(0,0,0,0.35)"
            value={notes}
            onChangeText={(t) => {
              setNotes(t);
              setError(null);
            }}
            multiline
          />
        </View>

        <TouchableOpacity
          style={[styles.primaryButton, isSubmitting ? { opacity: 0.7 } : null]}
          disabled={isSubmitting}
          onPress={handleSubmit}
        >
          <Text style={styles.primaryButtonText}>{isSubmitting ? 'Submitting...' : 'Submit proof'}</Text>
        </TouchableOpacity>

        <TouchableOpacity disabled={isSubmitting} onPress={() => navigation.goBack()}>
          <Text style={styles.backText}>Cancel</Text>
        </TouchableOpacity>
      </View>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  root: { flex: 1, backgroundColor: GRAY[50] },
  content: { flex: 1, paddingHorizontal: SPACING[4], paddingTop: SPACING[4] },
  title: { fontSize: 22, fontWeight: '700', color: GRAY[900], marginBottom: 8 },
  subtitle: { fontSize: 14, color: GRAY[600], lineHeight: 20, marginBottom: SPACING[4] },
  banner: { marginBottom: SPACING[3] },
  photoButton: {
    height: 44,
    borderRadius: 12,
    backgroundColor: '#5B2DFF',
    alignItems: 'center',
    justifyContent: 'center',
    marginBottom: SPACING[3],
  },
  photoButtonText: { color: 'white', fontWeight: '800', fontSize: 14 },
  photoPreview: {
    backgroundColor: 'white',
    borderRadius: 12,
    overflow: 'hidden',
    marginBottom: SPACING[4],
  },
  photoImage: { width: '100%', height: 180, resizeMode: 'cover' },
  field: {
    backgroundColor: 'white',
    borderRadius: 12,
    padding: SPACING[4],
    marginBottom: SPACING[4],
  },
  label: { fontSize: 13, fontWeight: '600', color: GRAY[700], marginBottom: 10 },
  input: { minHeight: 120, textAlignVertical: 'top', color: GRAY[900] },
  primaryButton: {
    height: 50,
    borderRadius: 12,
    backgroundColor: '#5B2DFF',
    alignItems: 'center',
    justifyContent: 'center',
    marginBottom: 16,
  },
  primaryButtonText: { color: 'white', fontWeight: '800', fontSize: 16 },
  backText: { color: GRAY[600], fontWeight: '600', textAlign: 'center' },
});
