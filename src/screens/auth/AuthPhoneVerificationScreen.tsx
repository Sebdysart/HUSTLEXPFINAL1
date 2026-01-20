import React, { useState } from 'react';
import { View, Text, TextInput, Button, StyleSheet, TouchableOpacity, ActivityIndicator } from 'react-native';
import { useNavigation } from '@react-navigation/native';
import { NEUTRAL, SPACING, RADIUS, FONT_SIZE } from '../../constants';
import { verifyPhone } from '../../services/dataService';

export function AuthPhoneVerificationScreen() {
  const navigation = useNavigation();
  const [code, setCode] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [codeError, setCodeError] = useState<string | null>(null);

  const validateCode = (codeValue: string): boolean => {
    if (!codeValue) {
      setCodeError('Verification code is required');
      return false;
    }
    if (codeValue.length !== 6) {
      setCodeError('Code must be exactly 6 digits');
      return false;
    }
    if (!/^\d{6}$/.test(codeValue)) {
      setCodeError('Code must contain only digits');
      return false;
    }
    setCodeError(null);
    return true;
  };

  const handleVerify = async () => {
    setError(null);
    
    // Validate code
    if (!validateCode(code)) {
      return;
    }

    setIsLoading(true);
    try {
      // Note: For mock, we pass empty string for phone since it's not used in verification
      // In real app, phone would come from navigation params or user context
      const response = await verifyPhone('', code) as { success: boolean; data: any; error: string | null };
      
      if (response.success) {
        // Navigate to onboarding (phone verification typically happens before onboarding)
        // RootNavigator will handle routing based on user state
        navigation.navigate('OnboardingStack' as never);
      } else {
        setError(response.error || 'Invalid verification code. Please try again.');
      }
    } catch (err) {
      setError(err instanceof Error ? err.message : 'An unexpected error occurred');
    } finally {
      setIsLoading(false);
    }
  };

  const handleResend = () => {
    // Mock resend - just clear error and show message
    setError(null);
    setCode('');
    // In real app, this would trigger a new code to be sent
    console.log('Resend code requested');
  };

  return (
    <View style={styles.container}>
      <Text style={styles.instructionText}>
        Enter the 6-digit verification code sent to your phone
      </Text>
      <TextInput
        style={[styles.input, codeError && styles.inputError]}
        placeholder="Enter 6-digit code"
        value={code}
        onChangeText={(text) => {
          // Limit to 6 digits
          const digitsOnly = text.replace(/[^0-9]/g, '');
          if (digitsOnly.length <= 6) {
            setCode(digitsOnly);
            if (codeError) {
              validateCode(digitsOnly);
            }
          }
        }}
        onBlur={() => validateCode(code)}
        keyboardType="number-pad"
        maxLength={6}
        editable={!isLoading}
      />
      {codeError && <Text style={styles.errorText}>{codeError}</Text>}
      
      {error && <Text style={styles.errorText}>{error}</Text>}
      
      {isLoading ? (
        <ActivityIndicator size="large" color={NEUTRAL.TEXT} style={styles.loader} />
      ) : (
        <Button title="Verify" onPress={handleVerify} disabled={isLoading} />
      )}
      
      <TouchableOpacity onPress={handleResend} disabled={isLoading}>
        <Text style={[styles.link, isLoading && styles.linkDisabled]}>Resend code</Text>
      </TouchableOpacity>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    padding: SPACING[4],
    backgroundColor: NEUTRAL.BACKGROUND,
  },
  instructionText: {
    fontSize: FONT_SIZE.base,
    color: NEUTRAL.TEXT_SECONDARY,
    marginBottom: SPACING[6],
    textAlign: 'center',
  },
  input: {
    height: 48,
    borderWidth: 1,
    borderColor: NEUTRAL.BORDER,
    borderRadius: RADIUS.md,
    paddingHorizontal: SPACING[3],
    marginBottom: SPACING[2],
    fontSize: FONT_SIZE.base,
    color: NEUTRAL.TEXT,
    textAlign: 'center',
    letterSpacing: 8,
  },
  inputError: {
    borderColor: '#EF4444',
  },
  errorText: {
    color: '#EF4444',
    fontSize: FONT_SIZE.sm,
    marginBottom: SPACING[2],
    marginTop: -SPACING[2],
    textAlign: 'center',
  },
  loader: {
    marginVertical: SPACING[4],
  },
  link: {
    marginTop: SPACING[4],
    color: NEUTRAL.TEXT_SECONDARY,
    fontSize: FONT_SIZE.sm,
    textDecorationLine: 'underline',
    textAlign: 'center',
  },
  linkDisabled: {
    opacity: 0.5,
  },
});
