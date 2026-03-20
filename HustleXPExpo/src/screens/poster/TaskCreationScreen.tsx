import React, { useMemo, useState } from 'react';
import {
  KeyboardAvoidingView,
  Platform,
  StyleSheet,
  Text,
  TextInput,
  TouchableOpacity,
  View,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useNavigation } from '@react-navigation/native';
import { TRPCClient } from '../../network/trpcClient';
import { SPACING } from '../../../constants';
import { GRAY } from '../../../constants/colors';

export default function TaskCreationScreen() {
  const navigation = useNavigation<any>();

  const [title, setTitle] = useState('');
  const [description, setDescription] = useState('');
  const [payment, setPayment] = useState('');
  const [location, setLocation] = useState('');
  const [duration, setDuration] = useState('1 hr');

  const [isSubmitting, setIsSubmitting] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const parsedPayment = useMemo(() => {
    const n = Number(payment);
    return Number.isFinite(n) ? n : null;
  }, [payment]);

  const isValid =
    title.trim().length >= 5 &&
    description.trim().length > 0 &&
    location.trim().length > 0 &&
    parsedPayment !== null &&
    (parsedPayment ?? 0) > 0;

  const handleCreate = async () => {
    if (!isValid || isSubmitting) return;
    setIsSubmitting(true);
    setError(null);

    try {
      if (Platform.OS === 'web') {
        throw new Error('Escrow funding (Stripe PaymentSheet) is not supported on web preview. Run on iOS to fund escrow.');
      }

      const task = await TRPCClient.shared.call<
        {
          title: string;
          description: string;
          price: number;
          location: string;
          category?: string | null;
          mode: string;
          requiresProof: boolean;
          instantMode: boolean;
        },
        any
      >('task', 'create', 'mutation', {
        title: title.trim(),
        description: description.trim(),
        price: Math.round((parsedPayment ?? 0) * 100),
        location: location.trim(),
        category: null,
        mode: 'STANDARD',
        requiresProof: true,
        instantMode: false,
      } as any);

      // 1) Create escrow payment intent
      const paymentIntent = await TRPCClient.shared.call<{ taskId: string }, any>(
        'escrow',
        'createPaymentIntent',
        'mutation',
        { taskId: task.id }
      );

      // 2) Present Stripe PaymentSheet
      const stripe = await import('@stripe/stripe-react-native');
      await stripe.initPaymentSheet({
        paymentIntentClientSecret: paymentIntent.clientSecret,
      } as any);

      const result = await stripe.presentPaymentSheet();
      if (result?.error) {
        throw new Error(result.error.message ?? 'Payment failed');
      }

      // 3) Confirm escrow funding with the backend
      await TRPCClient.shared.call<
        { escrowId: string; stripePaymentIntentId: string },
        any
      >('escrow', 'confirmFunding', 'mutation', {
        escrowId: paymentIntent.escrowId,
        stripePaymentIntentId: paymentIntent.paymentIntentId,
      });

      navigation.goBack();
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Failed to create task');
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <SafeAreaView style={styles.root} edges={['top', 'bottom']}>
      <KeyboardAvoidingView
        behavior={Platform.OS === 'ios' ? 'padding' : undefined}
        style={styles.container}
      >
        <Text style={styles.title}>Post a Task</Text>
        <Text style={styles.subtitle}>Create the task, then fund escrow with Stripe.</Text>

        {error ? (
          <View style={styles.banner}>
            <Text style={styles.errorText}>{error}</Text>
          </View>
        ) : null}

        <View style={styles.field}>
          <Text style={styles.label}>Task title</Text>
          <TextInput
            value={title}
            onChangeText={(t) => {
              setTitle(t);
              setError(null);
            }}
            style={styles.input}
            placeholder="e.g., Help move couch"
            placeholderTextColor="rgba(0,0,0,0.35)"
          />
        </View>

        <View style={styles.field}>
          <Text style={styles.label}>Description</Text>
          <TextInput
            value={description}
            onChangeText={(t) => {
              setDescription(t);
              setError(null);
            }}
            style={[styles.input, { minHeight: 90, textAlignVertical: 'top' }]}
            placeholder="What needs to be done?"
            placeholderTextColor="rgba(0,0,0,0.35)"
            multiline
          />
        </View>

        <View style={styles.fieldRow}>
          <View style={[styles.field, { flex: 1 }]}>
            <Text style={styles.label}>Payment ($)</Text>
            <TextInput
              value={payment}
              onChangeText={(t) => {
                setPayment(t);
                setError(null);
              }}
              style={styles.input}
              placeholder="25"
              placeholderTextColor="rgba(0,0,0,0.35)"
              keyboardType="decimal-pad"
            />
          </View>
        </View>

        <View style={styles.field}>
          <Text style={styles.label}>Location</Text>
          <TextInput
            value={location}
            onChangeText={(t) => {
              setLocation(t);
              setError(null);
            }}
            style={styles.input}
            placeholder="Street or area"
            placeholderTextColor="rgba(0,0,0,0.35)"
          />
        </View>

        <View style={styles.field}>
          <Text style={styles.label}>Estimated duration</Text>
          <TextInput
            value={duration}
            onChangeText={(t) => setDuration(t)}
            style={styles.input}
            placeholder="1 hr"
            placeholderTextColor="rgba(0,0,0,0.35)"
          />
        </View>

        <TouchableOpacity
          style={[styles.primaryButton, (!isValid || isSubmitting) ? { opacity: 0.6 } : null]}
          disabled={!isValid || isSubmitting}
          onPress={handleCreate}
        >
          <Text style={styles.primaryButtonText}>
            {isSubmitting ? 'Funding...' : 'Create & Fund Escrow'}
          </Text>
        </TouchableOpacity>

        <TouchableOpacity disabled={isSubmitting} onPress={() => navigation.goBack()}>
          <Text style={styles.backText}>Cancel</Text>
        </TouchableOpacity>
      </KeyboardAvoidingView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  root: { flex: 1, backgroundColor: GRAY[50] },
  container: { flex: 1, paddingHorizontal: SPACING[4], paddingTop: SPACING[4] },
  title: { fontSize: 22, fontWeight: '800', color: GRAY[900], marginBottom: 8 },
  subtitle: { fontSize: 14, color: GRAY[600], marginBottom: SPACING[4], lineHeight: 20 },
  banner: {
    backgroundColor: '#FFE4E6',
    borderRadius: 12,
    padding: SPACING[3],
    marginBottom: SPACING[3],
  },
  errorText: { color: '#D32F2F', fontWeight: '700' },
  field: {
    backgroundColor: 'white',
    borderRadius: 12,
    padding: SPACING[3],
    marginBottom: SPACING[3],
  },
  fieldRow: { flexDirection: 'row', alignItems: 'center' },
  label: { fontSize: 13, fontWeight: '700', color: GRAY[700], marginBottom: 10 },
  input: { height: 44, color: GRAY[900], padding: 0 },
  primaryButton: {
    height: 52,
    borderRadius: 14,
    backgroundColor: '#5B2DFF',
    alignItems: 'center',
    justifyContent: 'center',
    marginTop: SPACING[2],
    marginBottom: SPACING[3],
  },
  primaryButtonText: { color: 'white', fontWeight: '900', fontSize: 16 },
  backText: { color: GRAY[600], fontWeight: '700', textAlign: 'center' },
});
