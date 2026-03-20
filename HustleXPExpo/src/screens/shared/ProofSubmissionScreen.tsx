import React, { useEffect, useMemo, useState } from 'react';
import { Image, ScrollView, StyleSheet, Text, TextInput, TouchableOpacity, View } from 'react-native';
import { Modal } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { CommonActions, useNavigation, useRoute } from '@react-navigation/native';
import { StatusBanner } from '../../components/molecules';
import { SPACING } from '../../../constants';
import { GRAY } from '../../../constants/colors';
import { TRPCClient } from '../../network/trpcClient';
import * as Location from 'expo-location';
import { getTaskDetailData } from '../../data/adapters';
import type { TaskDetailProps } from '../../data/adapters';
import type { PosterSummary } from '../../data/types';
import AsyncStorage from '@react-native-async-storage/async-storage';

export default function ProofSubmissionScreen() {
  const navigation = useNavigation<any>();
  const route = useRoute<any>();
  const taskId: string = route.params?.taskId ?? 'task-1';

  const [notes, setNotes] = useState('');
  const [photoUri, setPhotoUri] = useState<string | null>(null);
  const [gps, setGps] = useState<{ lat: number; lng: number; accuracy?: number | null } | null>(null);
  const [isCapturingGps, setIsCapturingGps] = useState(false);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const [showSuccess, setShowSuccess] = useState(false);
  const [showValidationFeedback, setShowValidationFeedback] = useState(false);
  const [validationResult, setValidationResult] = useState<LocalBiometricValidationResult | null>(null);
  const [showRatingSheet, setShowRatingSheet] = useState(false);
  const [ratingContext, setRatingContext] = useState<{
    taskTitle: string;
    otherUserName: string;
  } | null>(null);

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

      // SwiftUI parity: capture GPS before submitting proof.
      setIsCapturingGps(true);
      try {
        const perm = await Location.requestForegroundPermissionsAsync();
        if (!perm.granted) {
          throw new Error('Location permission is required to submit proof.');
        }

        const pos = await Location.getCurrentPositionAsync({
          accuracy: Location.Accuracy.Highest,
        });

        if (!pos.coords) throw new Error('Could not read GPS coordinates.');

        setGps({
          lat: pos.coords.latitude,
          lng: pos.coords.longitude,
          accuracy: pos.coords.accuracy ?? null,
        });
      } finally {
        setIsCapturingGps(false);
      }

      if (!gps) {
        throw new Error('GPS coordinates are required to submit proof.');
      }

      const publicUrl = await uploadPhotoToR2(photoUri);

      const biometricHash = await generateBiometricHash(gps.lat, gps.lng);

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
        gpsLatitude: gps.lat,
        gpsLongitude: gps.lng,
        biometricHash,
      });

      // SwiftUI parity: after submit, show validation feedback first.
      // SwiftUI's LiveDataService validates locally using task location distance + random liveness/deepfake scores.
      // We also fetch task/poster name here once, so validation and rating prompt are consistent.
      try {
        const detail: TaskDetailProps = await getTaskDetailData(taskId).then((r) => r.props as any);

        const taskLat = detail?.task?.location?.lat;
        const taskLng = detail?.task?.location?.lng;

        const localResult = computeLocalValidationResult({
          taskLat: typeof taskLat === 'number' ? taskLat : 37.7749,
          taskLng: typeof taskLng === 'number' ? taskLng : -122.4194,
          gpsLat: gps.lat,
          gpsLng: gps.lng,
          gpsAccuracyMeters: gps.accuracy ?? undefined,
          hasPhoto: !!photoUri,
        });

        setValidationResult(localResult);
        setShowValidationFeedback(true);

        const posterName = (detail?.poster as PosterSummary | undefined)?.name ?? 'the poster';
        setRatingContext({
          taskTitle: detail?.task?.title ?? 'this task',
          otherUserName: posterName,
        });
      } catch {
        // If we can't fetch task details, still show validation + rating prompt best-effort.
        const localResult = computeLocalValidationResult({
          taskLat: 37.7749,
          taskLng: -122.4194,
          gpsLat: gps.lat,
          gpsLng: gps.lng,
          gpsAccuracyMeters: gps.accuracy ?? undefined,
          hasPhoto: !!photoUri,
        });
        setValidationResult(localResult);
        setShowValidationFeedback(true);
        setRatingContext({ taskTitle: 'this task', otherUserName: 'the poster' });
      }
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Failed to submit proof');
    } finally {
      setIsSubmitting(false);
    }
  };

  const resetSubmission = () => {
    // SwiftUI's resetSubmission clears photo + GPS inputs.
    setShowValidationFeedback(false);
    setShowSuccess(false);
    setValidationResult(null);
    setPhotoUri(null);
    setGps(null);
    setNotes('');
    setError(null);
  };

  const continueToSuccess = () => {
    setShowValidationFeedback(false);
    setShowSuccess(true);
  };

  const submitAnyway = () => {
    // Matches SwiftUI: on reject, user can submit anyway and continue to success UI.
    setShowValidationFeedback(false);
    setShowSuccess(true);
  };

  const goHome = () => {
    // SwiftUI parity: reset hustler/poster navigation path back to Home (not just pop the stack).
    const parentNav = (navigation as any).getParent?.();
    if (parentNav?.dispatch) {
      parentNav.dispatch(
        CommonActions.reset({
          index: 0,
          routes: [{ name: 'Home' }],
        })
      );
      return;
    }

    navigation.navigate('Home' as never);
  };

  const ratingTags = useMemo(
    () => ['On Time', 'Professional', 'Friendly', 'Good Quality', 'Fast', 'Great Communication'],
    []
  );

  return (
    <SafeAreaView style={styles.root} edges={['top']}>
      <View style={styles.content}>
        {showValidationFeedback && validationResult ? (
          <ValidationResultView
            result={validationResult}
            onContinue={continueToSuccess}
            onTryAgain={resetSubmission}
            onSubmitAnyway={submitAnyway}
          />
        ) : showSuccess ? (
          <>
            <Text style={styles.title}>Proof Submitted!</Text>
            <Text style={styles.subtitle}>The poster will review your work.</Text>

            {ratingContext ? (
              <>
                <View style={styles.successCard} />

                <TouchableOpacity
                  style={styles.ratingPrompt}
                  onPress={() => {
                    setShowRatingSheet(true);
                  }}
                >
                  <Text style={styles.ratingPromptStar}>★</Text>
                  <View style={{ flex: 1 }}>
                    <Text style={styles.ratingPromptTitle}>
                      Rate {ratingContext.otherUserName}
                    </Text>
                    <Text style={styles.ratingPromptSubtitle}>How was your experience?</Text>
                  </View>
                  <Text style={styles.ratingPromptChevron}>{'>'}</Text>
                </TouchableOpacity>
              </>
            ) : null}

            <TouchableOpacity style={styles.doneButton} onPress={goHome} activeOpacity={0.85}>
              <Text style={styles.doneButtonText}>Back to Home</Text>
            </TouchableOpacity>

            {error ? (
              <View style={styles.banner}>
                <StatusBanner tone="danger" text={error} />
              </View>
            ) : null}

            <RateTaskSheetModal
              isVisible={showRatingSheet}
              onClose={() => setShowRatingSheet(false)}
              taskId={taskId}
              taskTitle={ratingContext?.taskTitle ?? 'this task'}
              otherUserName={ratingContext?.otherUserName ?? 'the poster'}
              tags={ratingTags}
              onDone={() => {
                setShowRatingSheet(false);
                goHome();
              }}
            />
          </>
        ) : (
          <>
            <Text style={styles.title}>Submit proof</Text>
            <Text style={styles.subtitle}>
              Choose a photo proof and optionally add notes for the poster.
            </Text>

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
              <Text style={styles.label}>GPS</Text>
              <Text style={styles.gpsText}>
                {isCapturingGps
                  ? 'Capturing location...'
                  : gps
                    ? `Captured: ${gps.lat.toFixed(4)}, ${gps.lng.toFixed(4)}`
                    : 'Location will be captured when you submit proof.'}
              </Text>
            </View>

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
              <Text style={styles.primaryButtonText}>
                {isSubmitting ? 'Submitting...' : isCapturingGps ? 'Capturing GPS...' : 'Submit proof'}
              </Text>
            </TouchableOpacity>

            <TouchableOpacity disabled={isSubmitting} onPress={() => navigation.goBack()}>
              <Text style={styles.backText}>Cancel</Text>
            </TouchableOpacity>
          </>
        )}
      </View>
    </SafeAreaView>
  );
}

type LocalBiometricValidationRecommendation = 'approve' | 'manual_review' | 'reject';
type LocalBiometricRiskLevel = 'low' | 'medium' | 'high' | 'critical';

type LocalBiometricValidationResult = {
  recommendation: LocalBiometricValidationRecommendation;
  reasoning: string;
  flags: string[];
  scores: {
    liveness: number;
    authenticity: number; // 0..100 (SwiftUI displays 100 - deepfakeScore)
    gpsProximity: number;
  };
  riskLevel: LocalBiometricRiskLevel;
};

function computeLocalValidationResult({
  taskLat,
  taskLng,
  gpsLat,
  gpsLng,
  gpsAccuracyMeters,
  hasPhoto,
}: {
  taskLat: number;
  taskLng: number;
  gpsLat: number;
  gpsLng: number;
  gpsAccuracyMeters?: number;
  hasPhoto: boolean;
}): LocalBiometricValidationResult {
  if (!hasPhoto) {
    return {
      recommendation: 'reject',
      reasoning: 'A photo proof is required to verify completion.',
      flags: ['MISSING_PHOTO'],
      scores: { liveness: 20, authenticity: 10, gpsProximity: 30 },
      riskLevel: 'high',
    };
  }

  const latDiff = Math.abs(taskLat - gpsLat);
  const lonDiff = Math.abs(taskLng - gpsLng);
  const distanceApprox = Math.sqrt(latDiff * latDiff + lonDiff * lonDiff) * 111000;

  // Match SwiftUI LiveDataService thresholds for gpsScore.
  const gpsScore = (() => {
    if (distanceApprox < 50) return 0.98;
    if (distanceApprox < 100) return 0.9;
    if (distanceApprox < 500) return 0.7;
    if (distanceApprox < 1000) return 0.5;
    return 0.3;
  })();

  // Match SwiftUI's local random ranges (we only need plausible values for UI).
  const livenessScore = 0.85 + Math.random() * (0.99 - 0.85);
  const deepfakeScore = 0.01 + Math.random() * (0.15 - 0.01);

  const flags: string[] = [];
  if (gpsScore < 0.7) flags.push('GPS_DISTANCE_WARNING');
  if ((gpsAccuracyMeters ?? 0) > 30) flags.push('LOW_GPS_ACCURACY');
  if (deepfakeScore > 0.1) flags.push('DEEPFAKE_CHECK_NEEDED');

  const riskLevel: LocalBiometricRiskLevel = (() => {
    if (gpsScore > 0.85 && livenessScore > 0.9 && deepfakeScore < 0.1) return 'low';
    if (gpsScore > 0.6 && livenessScore > 0.8) return 'medium';
    if (gpsScore > 0.4) return 'high';
    return 'critical';
  })();

  const recommendation: LocalBiometricValidationRecommendation =
    riskLevel === 'low'
      ? 'approve'
      : riskLevel === 'critical'
        ? 'reject'
        : 'manual_review';

  const reasoning =
    recommendation === 'approve'
      ? 'Biometric proof validated. GPS coordinates match task location with high confidence.'
      : recommendation === 'manual_review'
        ? 'Some validation checks require human review.'
        : 'Validation failed. GPS coordinates too far from task location.';

  const livenessPct = Math.round(livenessScore * 100);
  const deepfakePct = Math.round(deepfakeScore * 100);
  const gpsProximityPct = Math.round(gpsScore * 100);
  const authenticityPct = 100 - deepfakePct; // SwiftUI displays 100 - deepfake

  return {
    recommendation,
    reasoning,
    flags,
    scores: {
      liveness: livenessPct,
      authenticity: authenticityPct,
      gpsProximity: gpsProximityPct,
    },
    riskLevel,
  };
}

function ValidationResultView({
  result,
  onContinue,
  onTryAgain,
  onSubmitAnyway,
}: {
  result: LocalBiometricValidationResult;
  onContinue: () => void;
  onTryAgain: () => void;
  onSubmitAnyway: () => void;
}) {
  const { recommendation, reasoning, flags, scores, riskLevel } = result;

  const headerConfig = useMemo(() => {
    switch (recommendation) {
      case 'approve':
        return { title: 'Proof Validated', subtitle: 'Your proof has been automatically verified', tone: 'success' as const };
      case 'manual_review':
        return { title: 'Manual Review Required', subtitle: 'The poster will review your submission', tone: 'warning' as const };
      case 'reject':
        return { title: 'Validation Failed', subtitle: 'Please try submitting again', tone: 'danger' as const };
    }
  }, [recommendation]);

  const toneToStatusBanner: Record<'success' | 'warning' | 'danger', 'success' | 'warning' | 'danger' | 'info'> = {
    success: 'success',
    warning: 'warning',
    danger: 'danger',
  };

  return (
    <ScrollView style={styles.validationRoot} contentContainerStyle={styles.validationScroll} showsVerticalScrollIndicator={false}>
      <View style={styles.validationHeaderCircle} />

      <View style={styles.validationHeaderContent}>
        <Text style={styles.validationTitle}>{headerConfig.title}</Text>
        <Text style={styles.validationSubtitle}>{headerConfig.subtitle}</Text>
      </View>

      <View style={styles.validationCard}>
        <StatusBanner tone={toneToStatusBanner[headerConfig.tone]} text={reasoning} />

        {flags.length ? (
          <View style={{ marginTop: SPACING[3] }}>
            <Text style={styles.validationSectionTitle}>Flags</Text>
            <View style={styles.validationFlagsWrap}>
              {flags.map((f) => (
                <View key={f} style={styles.validationFlagChip}>
                  <Text style={styles.validationFlagChipText}>
                    {titleCase(f.replaceAll('_', ' '))}
                  </Text>
                </View>
              ))}
            </View>
          </View>
        ) : null}

        <View style={{ marginTop: SPACING[3] }}>
          <Text style={styles.validationSectionTitle}>Validation Scores</Text>

          <ScoreBar label="Liveness" value={scores.liveness} />
          <ScoreBar label="Authenticity" value={scores.authenticity} />
          <ScoreBar label="GPS Proximity" value={scores.gpsProximity} />
        </View>

        <View style={styles.validationRiskRow}>
          <Text style={styles.validationRiskLabel}>Risk</Text>
          <View
            style={[
              styles.validationRiskBadge,
              riskLevel === 'low'
                ? styles.riskLow
                : riskLevel === 'medium'
                  ? styles.riskMedium
                  : riskLevel === 'critical'
                    ? styles.riskCritical
                    : styles.riskHigh,
            ]}
          >
            <Text style={styles.validationRiskText}>{riskLevel.toUpperCase()}</Text>
          </View>
        </View>
      </View>

      <View style={{ height: SPACING[3] }} />

      {/* SwiftUI actions mapping */}
      {recommendation === 'reject' ? (
        <>
          <TouchableOpacity style={styles.secondaryButton} onPress={onTryAgain} activeOpacity={0.85}>
            <Text style={styles.secondaryButtonText}>Try Again</Text>
          </TouchableOpacity>
          <TouchableOpacity style={styles.primaryButton} onPress={onSubmitAnyway} activeOpacity={0.85} >
            <Text style={styles.primaryButtonText}>Submit Anyway</Text>
          </TouchableOpacity>
        </>
      ) : (
        <TouchableOpacity style={styles.primaryButton} onPress={onContinue} activeOpacity={0.85} >
          <Text style={styles.primaryButtonText}>Continue to Success</Text>
        </TouchableOpacity>
      )}

      <View style={{ height: SPACING[8] }} />
    </ScrollView>
  );
}

function titleCase(s: string): string {
  // Minimal title-casing to match SwiftUI's `.capitalized` behavior.
  return s
    .split(' ')
    .filter(Boolean)
    .map((w) => w.slice(0, 1).toUpperCase() + w.slice(1).toLowerCase())
    .join(' ');
}

function ScoreBar({ label, value }: { label: string; value: number }) {
  const width = `${Math.max(0, Math.min(1, value / 100)) * 100}%`;

  return (
    <View style={{ marginTop: SPACING[2] }}>
      <View style={{ flexDirection: 'row', justifyContent: 'space-between', alignItems: 'baseline' }}>
        <Text style={styles.scoreBarLabel}>{label}</Text>
        <Text style={styles.scoreBarValue}>{Math.round(value)}%</Text>
      </View>
      <View style={styles.scoreBarTrack}>
        <View style={[styles.scoreBarFill, { width: width as any }]} />
      </View>
    </View>
  );
}

async function generateBiometricHash(lat: number, lng: number): Promise<string> {
  // SwiftUI parity: BiometricProofGenerator.generateHash(deviceId|timestamp|lat,lng) then base64.
  const deviceId = await getInstallationId();
  const timestampStr = new Date().toISOString();
  const locationStr = `${lat},${lng}`;
  const combined = `${deviceId}|${timestampStr}|${locationStr}`;
  return base64Encode(combined);
}

async function getInstallationId(): Promise<string> {
  const key = 'hx.installationId';
  const existing = await AsyncStorage.getItem(key);
  if (existing) return existing;

  // Approximation of iOS identifierForVendor; stable for the current install.
  const next = `${Date.now().toString(36)}-${Math.random().toString(36).slice(2, 10)}`;
  await AsyncStorage.setItem(key, next);
  return next;
}

function base64Encode(input: string): string {
  // RN typically doesn't ship with btoa; keep this dependency-free.
  const btoaFn = (globalThis as any)?.btoa as undefined | ((s: string) => string);
  if (typeof btoaFn === 'function') return btoaFn(input);

  // UTF-8 -> base64 (small polyfill)
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  const TextEncoderImpl: any = (globalThis as any).TextEncoder;
  if (!TextEncoderImpl) {
    // Fallback for runtimes without TextEncoder.
    // eslint-disable-next-line no-control-regex
    const utf8 = unescape(encodeURIComponent(input));
    const bytes = new Uint8Array(utf8.length);
    for (let i = 0; i < utf8.length; i++) bytes[i] = utf8.charCodeAt(i);
    return bytesToBase64(bytes);
  }

  const bytes = new TextEncoderImpl().encode(input) as Uint8Array;
  return bytesToBase64(bytes);
}

function bytesToBase64(bytes: Uint8Array): string {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
  let out = '';
  for (let i = 0; i < bytes.length; i += 3) {
    const a = bytes[i];
    const b = i + 1 < bytes.length ? bytes[i + 1] : 0;
    const c = i + 2 < bytes.length ? bytes[i + 2] : 0;

    const triple = (a << 16) | (b << 8) | c;

    const s1 = (triple >> 18) & 0x3f;
    const s2 = (triple >> 12) & 0x3f;
    const s3 = (triple >> 6) & 0x3f;
    const s4 = triple & 0x3f;

    const pad2 = i + 1 >= bytes.length;
    const pad3 = i + 2 >= bytes.length;

    out += chars[s1];
    out += chars[s2];
    out += pad2 ? '=' : chars[s3];
    out += pad3 ? '=' : chars[s4];
  }
  return out;
}

function RateTaskSheetModal({
  isVisible,
  onClose,
  taskId,
  taskTitle,
  otherUserName,
  tags,
  onDone,
}: {
  isVisible: boolean;
  onClose: () => void;
  taskId: string;
  taskTitle: string;
  otherUserName: string;
  tags: string[];
  onDone?: () => void;
}) {
  const [rating, setRating] = useState(0);
  const [review, setReview] = useState('');
  const [selectedTags, setSelectedTags] = useState<Set<string>>(new Set());
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [submitError, setSubmitError] = useState<string | null>(null);
  const [showSuccess, setShowSuccess] = useState(false);

  useEffect(() => {
    if (!isVisible) return;
    // Reset each time the modal is opened (SwiftUI sheet behavior).
    setRating(0);
    setReview('');
    setSelectedTags(new Set());
    setIsSubmitting(false);
    setSubmitError(null);
    setShowSuccess(false);
  }, [isVisible]);

  const ratingLabel = useMemo(() => {
    switch (rating) {
      case 1:
        return 'Poor';
      case 2:
        return 'Below Average';
      case 3:
        return 'Good';
      case 4:
        return 'Great';
      case 5:
        return 'Excellent!';
      default:
        return '';
    }
  }, [rating]);

  const submitRating = async () => {
    if (!rating || isSubmitting) return;
    setIsSubmitting(true);
    setSubmitError(null);
    try {
      await TRPCClient.shared.call<
        { taskId: string; stars: number; comment?: string | null; tags?: string[] | null },
        any
      >('rating', 'submitRating', 'mutation', {
        taskId,
        stars: rating,
        comment: review.trim().length ? review.trim() : null,
        tags: selectedTags.size ? Array.from(selectedTags) : null,
      } as any);
      setShowSuccess(true);
    } catch (e) {
      setSubmitError(e instanceof Error ? e.message : 'Failed to submit rating');
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <Modal visible={isVisible} animationType="slide" transparent={true}>
      <View style={styles.modalOverlay}>
        <View style={styles.modalSheet}>
          <View style={styles.modalHeader}>
            <Text style={styles.modalTitle}>Rate Experience</Text>
            <TouchableOpacity onPress={onClose} activeOpacity={0.85}>
              <Text style={styles.modalCancel}>Cancel</Text>
            </TouchableOpacity>
          </View>

          {showSuccess ? (
            <View style={styles.modalBody}>
              <View style={styles.ratingSuccessCircle} />
              <Text style={styles.modalSuccessTitle}>Rating Submitted</Text>
              <Text style={styles.modalSuccessSubtitle}>Thanks for your feedback!</Text>

              <TouchableOpacity
                style={styles.doneButton}
                onPress={() => {
                  onClose();
                  onDone?.();
                }}
                activeOpacity={0.85}
              >
                <Text style={styles.doneButtonText}>Done</Text>
              </TouchableOpacity>
            </View>
          ) : (
            <View style={styles.modalBody}>
              <Text style={styles.modalSectionTitle}>How was your experience?</Text>
              <Text style={styles.modalSubtext}>
                Rate {otherUserName} for "{taskTitle}"
              </Text>

              <View style={styles.starsRow}>
                {[1, 2, 3, 4, 5].map((s) => (
                  <TouchableOpacity key={s} onPress={() => setRating(s)} activeOpacity={0.85}>
                    <Text style={[styles.star, s <= rating ? styles.starActive : styles.starInactive]}>
                      ★
                    </Text>
                  </TouchableOpacity>
                ))}
              </View>

              {rating > 0 ? <Text style={styles.ratingLabel}>{ratingLabel}</Text> : null}

              <Text style={styles.modalSectionTitle}>What stood out? (optional)</Text>
              <View style={styles.tagsWrap}>
                {tags.map((tag) => {
                  const active = selectedTags.has(tag);
                  return (
                    <TouchableOpacity
                      key={tag}
                      onPress={() => {
                        const next = new Set(selectedTags);
                        if (active) next.delete(tag);
                        else next.add(tag);
                        setSelectedTags(next);
                      }}
                      style={[
                        styles.tagChip,
                        active ? styles.tagChipActive : styles.tagChipInactive,
                      ]}
                      activeOpacity={0.85}
                    >
                      <Text style={[styles.tagChipText, active ? styles.tagChipTextActive : null]}>
                        {tag}
                      </Text>
                    </TouchableOpacity>
                  );
                })}
              </View>

              <Text style={styles.modalSectionTitle}>Write a review (optional)</Text>
              <TextInput
                style={styles.reviewInput}
                placeholder="Share your experience..."
                placeholderTextColor="rgba(0,0,0,0.35)"
                value={review}
                onChangeText={(t) => setReview(t)}
                multiline
              />

              {submitError ? (
                <View style={styles.banner}>
                  <StatusBanner tone="danger" text={submitError} />
                </View>
              ) : null}

              <TouchableOpacity
                style={[styles.primaryButton, rating === 0 ? { backgroundColor: GRAY[300] } : null]}
                onPress={submitRating}
                disabled={rating === 0 || isSubmitting}
                activeOpacity={0.85}
              >
                <Text style={styles.primaryButtonText}>
                  {isSubmitting ? 'Submitting...' : 'Submit Rating'}
                </Text>
              </TouchableOpacity>
            </View>
          )}
        </View>
      </View>
    </Modal>
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
  gpsText: { fontSize: 13, fontWeight: '700', color: GRAY[600], lineHeight: 18 },
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

  successCard: { height: 90, width: 90, borderRadius: 45, backgroundColor: 'rgba(16,185,129,0.10)', borderWidth: 1, borderColor: 'rgba(16,185,129,0.25)', alignSelf: 'center', marginVertical: SPACING[4] },
  ratingPrompt: {
    marginTop: SPACING[4],
    flexDirection: 'row',
    alignItems: 'center',
    borderWidth: 1,
    borderColor: GRAY[200],
    borderRadius: 12,
    backgroundColor: '#fff',
    padding: SPACING[3],
  },
  ratingPromptStar: { color: '#F59E0B', fontSize: 20, fontWeight: '900', marginRight: SPACING[2] },
  ratingPromptTitle: { fontSize: 14, fontWeight: '900', color: GRAY[900] },
  ratingPromptSubtitle: { marginTop: 2, fontSize: 12, fontWeight: '700', color: GRAY[600] },
  ratingPromptChevron: { color: GRAY[500], fontSize: 18, fontWeight: '900', paddingLeft: SPACING[2] },

  doneButton: {
    marginTop: SPACING[6],
    height: 50,
    borderRadius: 12,
    backgroundColor: '#5B2DFF',
    alignItems: 'center',
    justifyContent: 'center',
    marginHorizontal: 0,
  },
  doneButtonText: { color: 'white', fontWeight: '900', fontSize: 16 },

  modalOverlay: { flex: 1, backgroundColor: 'rgba(0,0,0,0.45)', justifyContent: 'flex-end' },
  modalSheet: { backgroundColor: '#fff', borderTopLeftRadius: 18, borderTopRightRadius: 18, padding: SPACING[4], maxHeight: '80%' },
  modalHeader: { flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between', marginBottom: SPACING[2] },
  modalTitle: { fontSize: 16, fontWeight: '900', color: GRAY[900] },
  modalCancel: { color: GRAY[600], fontWeight: '900' },
  modalBody: { flex: 1 },
  modalSectionTitle: { marginTop: SPACING[2], fontSize: 13, fontWeight: '900', color: GRAY[900] },
  modalSubtext: { marginTop: 4, fontSize: 12, fontWeight: '700', color: GRAY[600], lineHeight: 18 },
  starsRow: { flexDirection: 'row', marginTop: SPACING[3] },
  star: { fontSize: 34, marginRight: SPACING[2] },
  starActive: { color: '#F59E0B' },
  starInactive: { color: GRAY[300] },
  ratingLabel: { marginTop: SPACING[2], color: '#5B2DFF', fontSize: 14, fontWeight: '900', alignSelf: 'center' },
  tagsWrap: { flexDirection: 'row', flexWrap: 'wrap', marginTop: SPACING[3] },
  tagChip: { borderRadius: 9999, paddingVertical: 8, paddingHorizontal: 14, marginRight: 10, marginBottom: 10, borderWidth: 1 },
  tagChipActive: { backgroundColor: '#5B2DFF', borderColor: '#5B2DFF' },
  tagChipInactive: { backgroundColor: 'rgba(91,45,255,0.08)', borderColor: GRAY[200] },
  tagChipText: { color: GRAY[700], fontSize: 12, fontWeight: '900' },
  tagChipTextActive: { color: '#fff' },
  reviewInput: { marginTop: SPACING[2], borderWidth: 1, borderColor: GRAY[200], borderRadius: 12, padding: SPACING[3], minHeight: 90, textAlignVertical: 'top', color: GRAY[900] },

  ratingSuccessCircle: { width: 100, height: 100, borderRadius: 50, alignSelf: 'center', backgroundColor: 'rgba(16,185,129,0.10)', borderWidth: 1, borderColor: 'rgba(16,185,129,0.25)', marginBottom: SPACING[2] },
  modalSuccessTitle: { textAlign: 'center', fontSize: 18, fontWeight: '900', color: GRAY[900], marginTop: SPACING[2] },
  modalSuccessSubtitle: { textAlign: 'center', fontSize: 13, fontWeight: '700', color: GRAY[600], marginTop: 4, lineHeight: 20 },

  secondaryButton: {
    height: 50,
    borderRadius: 12,
    backgroundColor: '#fff',
    borderWidth: 1,
    borderColor: GRAY[200],
    alignItems: 'center',
    justifyContent: 'center',
    marginBottom: 12,
  },
  secondaryButtonText: { color: GRAY[900], fontWeight: '900', fontSize: 16 },

  validationRoot: { flex: 1, backgroundColor: GRAY[50] },
  validationScroll: { paddingHorizontal: SPACING[4], paddingTop: SPACING[4], paddingBottom: 32 },
  validationHeaderCircle: {
    width: 90,
    height: 90,
    borderRadius: 45,
    backgroundColor: 'rgba(91,45,255,0.08)',
    alignSelf: 'center',
    marginTop: SPACING[2],
    marginBottom: SPACING[2],
    borderWidth: 1,
    borderColor: 'rgba(91,45,255,0.20)',
  },
  validationHeaderContent: { alignItems: 'center', marginBottom: SPACING[3] },
  validationTitle: { fontSize: 22, fontWeight: '900', color: GRAY[900], textAlign: 'center' },
  validationSubtitle: { marginTop: 6, fontSize: 13, fontWeight: '700', color: GRAY[600], textAlign: 'center', lineHeight: 20 },
  validationCard: {
    backgroundColor: '#fff',
    borderRadius: 16,
    borderWidth: 1,
    borderColor: GRAY[200],
    padding: SPACING[4],
  },
  validationSectionTitle: { fontSize: 13, fontWeight: '900', color: GRAY[900] },
  validationFlagsWrap: { flexDirection: 'row', flexWrap: 'wrap', marginTop: SPACING[2] },
  validationFlagChip: {
    marginRight: 10,
    marginBottom: 10,
    paddingHorizontal: 10,
    paddingVertical: 6,
    borderRadius: 9999,
    backgroundColor: 'rgba(239,68,68,0.10)',
    borderWidth: 1,
    borderColor: 'rgba(239,68,68,0.18)',
  },
  validationFlagChipText: { fontSize: 12, fontWeight: '900', color: GRAY[900] },

  validationRiskRow: { flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between', marginTop: SPACING[4] },
  validationRiskLabel: { fontSize: 13, fontWeight: '900', color: GRAY[600] },
  validationRiskBadge: {
    minWidth: 110,
    height: 40,
    borderRadius: 20,
    alignItems: 'center',
    justifyContent: 'center',
    paddingHorizontal: 12,
  },
  validationRiskText: { fontSize: 13, fontWeight: '900', color: '#fff' },
  riskLow: { backgroundColor: '#10B981' },
  riskMedium: { backgroundColor: '#F59E0B' },
  riskHigh: { backgroundColor: '#EF4444' },
  riskCritical: { backgroundColor: '#EF4444' },

  scoreBarLabel: { fontSize: 13, fontWeight: '900', color: GRAY[600] },
  scoreBarValue: { fontSize: 13, fontWeight: '900', color: GRAY[900] },
  scoreBarTrack: { height: 8, backgroundColor: GRAY[200], borderRadius: 4, overflow: 'hidden', marginTop: 8 },
  scoreBarFill: { height: '100%', backgroundColor: '#5B2DFF' },
});
