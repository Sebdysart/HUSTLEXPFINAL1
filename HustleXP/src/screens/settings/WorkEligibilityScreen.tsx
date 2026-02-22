/**
 * WORK ELIGIBILITY SCREEN
 * 
 * Shows user's capability profile, eligibility status, and verification progress.
 * Allows users to complete license, insurance, and background check verifications.
 * 
 * Constitutional Reference: ARCHITECTURE.md §11-13
 * Backend Integration: /trpc/verification.getEligibility, /trpc/capabilityProfile.get
 */

import React, { useEffect, useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  TouchableOpacity,
  ActivityIndicator,
  Alert,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useNavigation } from '@react-navigation/native';

// Types matching backend schema
interface CapabilityProfile {
  userId: string;
  trustTier: number;
  riskClearance: string[];
  insuranceValid: boolean;
  insuranceExpiresAt: string | null;
  backgroundCheckValid: boolean;
  backgroundCheckExpiresAt: string | null;
  locationState: string;
  verifiedTrades: VerifiedTrade[];
}

interface VerifiedTrade {
  trade: string;
  state: string;
  verifiedAt: string;
  expiresAt: string | null;
}

interface EligibilityStatus {
  profile: CapabilityProfile | null;
  eligibleTaskCount: number;
  canAccessHighRisk: boolean;
  canAccessCriticalRisk: boolean;
  missingVerifications: string[];
}

export default function WorkEligibilityScreen() {
  const navigation = useNavigation();
  const [loading, setLoading] = useState(true);
  const [eligibility, setEligibility] = useState<EligibilityStatus | null>(null);
  const [error, setError] = useState<string | null>(null);

  // Fetch eligibility data from backend
  useEffect(() => {
    fetchEligibility();
  }, []);

  const fetchEligibility = async () => {
    try {
      setLoading(true);
      setError(null);

      // TODO: Replace with actual tRPC call
      // const response = await trpc.verification.getEligibility.query();
      // const profile = await trpc.capabilityProfile.get.query();
      // const taskCount = await trpc.feed.getEligibleTaskCount.query();

      // Mock data for now - will be replaced with real API
      const mockData: EligibilityStatus = {
        profile: {
          userId: 'user-123',
          trustTier: 2,
          riskClearance: ['low', 'medium'],
          insuranceValid: false,
          insuranceExpiresAt: null,
          backgroundCheckValid: false,
          backgroundCheckExpiresAt: null,
          locationState: 'WA',
          verifiedTrades: [
            {
              trade: 'Handyman',
              state: 'WA',
              verifiedAt: new Date().toISOString(),
              expiresAt: null,
            },
          ],
        },
        eligibleTaskCount: 15,
        canAccessHighRisk: false,
        canAccessCriticalRisk: false,
        missingVerifications: ['insurance', 'background_check'],
      };

      // Simulate API delay
      setTimeout(() => {
        setEligibility(mockData);
        setLoading(false);
      }, 500);
    } catch (err: any) {
      setError(err.message || 'Failed to load eligibility data');
      setLoading(false);
    }
  };

  const handleVerifyLicense = () => {
    // Navigate to license verification flow
    Alert.alert(
      'License Verification',
      'You will be guided through the license verification process.',
      [
        { text: 'Cancel', style: 'cancel' },
        { text: 'Continue', onPress: () => console.log('Start license verification') },
      ]
    );
  };

  const handleVerifyInsurance = () => {
    Alert.alert(
      'Insurance Verification',
      'Upload your Certificate of Insurance (COI) to verify coverage.',
      [
        { text: 'Cancel', style: 'cancel' },
        { text: 'Upload COI', onPress: () => console.log('Upload COI') },
      ]
    );
  };

  const handleBackgroundCheck = () => {
    Alert.alert(
      'Background Check',
      'Complete a background check to access high-risk tasks. Cost: $25',
      [
        { text: 'Cancel', style: 'cancel' },
        { text: 'Start ($25)', onPress: () => console.log('Start background check') },
      ]
    );
  };

  const getTrustTierName = (tier: number): string => {
    const tiers: Record<number, string> = {
      1: 'Rookie',
      2: 'Verified',
      3: 'Trusted',
      4: 'Elite',
      5: 'Master',
    };
    return tiers[tier] || 'Unknown';
  };

  const getTrustTierColor = (tier: number): string => {
    const colors: Record<number, string> = {
      1: '#94a3b8', // slate-400
      2: '#22c55e', // green-500
      3: '#3b82f6', // blue-500
      4: '#a855f7', // purple-500
      5: '#f59e0b', // amber-500
    };
    return colors[tier] || '#94a3b8';
  };

  if (loading) {
    return (
      <SafeAreaView style={styles.container}>
        <View style={styles.loadingContainer}>
          <ActivityIndicator size="large" color="#22c55e" />
          <Text style={styles.loadingText}>Loading eligibility...</Text>
        </View>
      </SafeAreaView>
    );
  }

  if (error) {
    return (
      <SafeAreaView style={styles.container}>
        <View style={styles.errorContainer}>
          <Text style={styles.errorText}>{error}</Text>
          <TouchableOpacity style={styles.retryButton} onPress={fetchEligibility}>
            <Text style={styles.retryButtonText}>Retry</Text>
          </TouchableOpacity>
        </View>
      </SafeAreaView>
    );
  }

  if (!eligibility?.profile) {
    return (
      <SafeAreaView style={styles.container}>
        <View style={styles.errorContainer}>
          <Text style={styles.errorText}>No eligibility data found</Text>
        </View>
      </SafeAreaView>
    );
  }

  const { profile } = eligibility;

  return (
    <SafeAreaView style={styles.container}>
      <ScrollView style={styles.scrollView}>
        {/* Header */}
        <View style={styles.header}>
          <Text style={styles.title}>Work Eligibility</Text>
          <Text style={styles.subtitle}>
            Manage your verifications to access more tasks
          </Text>
        </View>

        {/* Trust Tier Card */}
        <View style={styles.card}>
          <Text style={styles.cardTitle}>Trust Tier</Text>
          <View style={styles.tierRow}>
            <View
              style={[
                styles.tierBadge,
                { backgroundColor: getTrustTierColor(profile.trustTier) },
              ]}
            >
              <Text style={styles.tierBadgeText}>
                {getTrustTierName(profile.trustTier)}
              </Text>
            </View>
            <Text style={styles.tierLevel}>Level {profile.trustTier} of 5</Text>
          </View>
          <Text style={styles.tierDescription}>
            {profile.trustTier === 1 && 'Complete tasks to build trust and unlock higher-paying gigs.'}
            {profile.trustTier === 2 && 'You can access low and medium-risk tasks. Complete more tasks to reach Trusted tier.'}
            {profile.trustTier >= 3 && 'You have access to most tasks on the platform.'}
          </Text>
        </View>

        {/* Risk Clearance */}
        <View style={styles.card}>
          <Text style={styles.cardTitle}>Risk Clearance</Text>
          <View style={styles.riskContainer}>
            {['low', 'medium', 'high', 'critical'].map((risk) => {
              const hasClearance = profile.riskClearance.includes(risk);
              return (
                <View
                  key={risk}
                  style={[
                    styles.riskBadge,
                    hasClearance ? styles.riskBadgeActive : styles.riskBadgeInactive,
                  ]}
                >
                  <Text
                    style={[
                      styles.riskBadgeText,
                      hasClearance ? styles.riskBadgeTextActive : styles.riskBadgeTextInactive,
                    ]}
                  >
                    {risk.charAt(0).toUpperCase() + risk.slice(1)}
                  </Text>
                </View>
              );
            })}
          </View>
          <Text style={styles.riskDescription}>
            You can accept tasks marked as: {profile.riskClearance.join(', ')}
          </Text>
        </View>

        {/* Verified Trades */}
        <View style={styles.card}>
          <Text style={styles.cardTitle}>Verified Trades</Text>
          {profile.verifiedTrades.length > 0 ? (
            profile.verifiedTrades.map((trade, index) => (
              <View key={index} style={styles.tradeItem}>
                <View style={styles.tradeIcon}>
                  <Text style={styles.tradeIconText}>✓</Text>
                </View>
                <View style={styles.tradeInfo}>
                  <Text style={styles.tradeName}>{trade.trade}</Text>
                  <Text style={styles.tradeLocation}>{trade.state}</Text>
                </View>
              </View>
            ))
          ) : (
            <Text style={styles.emptyText}>No verified trades yet</Text>
          )}
          <TouchableOpacity style={styles.addButton} onPress={handleVerifyLicense}>
            <Text style={styles.addButtonText}>+ Add License</Text>
          </TouchableOpacity>
        </View>

        {/* Insurance */}
        <View style={styles.card}>
          <Text style={styles.cardTitle}>Insurance</Text>
          <View style={styles.verificationRow}>
            <View
              style={[
                styles.statusIcon,
                profile.insuranceValid ? styles.statusIconSuccess : styles.statusIconPending,
              ]}
            >
              <Text style={styles.statusIconText}>
                {profile.insuranceValid ? '✓' : '○'}
              </Text>
            </View>
            <View style={styles.verificationInfo}>
              <Text style={styles.verificationName}>General Liability Insurance</Text>
              <Text
                style={[
                  styles.verificationStatus,
                  profile.insuranceValid ? styles.statusSuccess : styles.statusPending,
                ]}
              >
                {profile.insuranceValid ? 'Verified' : 'Not Verified'}
              </Text>
              {profile.insuranceExpiresAt && (
                <Text style={styles.expiryText}>
                  Expires: {new Date(profile.insuranceExpiresAt).toLocaleDateString()}
                </Text>
              )}
            </View>
          </View>
          {!profile.insuranceValid && (
            <TouchableOpacity
              style={styles.verifyButton}
              onPress={handleVerifyInsurance}
            >
              <Text style={styles.verifyButtonText}>Verify Insurance</Text>
            </TouchableOpacity>
          )}
        </View>

        {/* Background Check */}
        <View style={styles.card}>
          <Text style={styles.cardTitle}>Background Check</Text>
          <View style={styles.verificationRow}>
            <View
              style={[
                styles.statusIcon,
                profile.backgroundCheckValid ? styles.statusIconSuccess : styles.statusIconPending,
              ]}
            >
              <Text style={styles.statusIconText}>
                {profile.backgroundCheckValid ? '✓' : '○'}
              </Text>
            </View>
            <View style={styles.verificationInfo}>
              <Text style={styles.verificationName}>Criminal Background Check</Text>
              <Text
                style={[
                  styles.verificationStatus,
                  profile.backgroundCheckValid ? styles.statusSuccess : styles.statusPending,
                ]}
              >
                {profile.backgroundCheckValid ? 'Verified' : 'Not Verified'}
              </Text>
              {profile.backgroundCheckExpiresAt && (
                <Text style={styles.expiryText}>
                  Expires: {new Date(profile.backgroundCheckExpiresAt).toLocaleDateString()}
                </Text>
              )}
            </View>
          </View>
          {!profile.backgroundCheckValid && (
            <TouchableOpacity
              style={styles.verifyButton}
              onPress={handleBackgroundCheck}
            >
              <Text style={styles.verifyButtonText}>Start Background Check ($25)</Text>
            </TouchableOpacity>
          )}
        </View>

        {/* Eligible Tasks Summary */}
        <View style={styles.card}>
          <Text style={styles.cardTitle}>Your Eligibility</Text>
          <View style={styles.statsContainer}>
            <View style={styles.statItem}>
              <Text style={styles.statNumber}>{eligibility.eligibleTaskCount}</Text>
              <Text style={styles.statLabel}>Tasks Available</Text>
            </View>
            <View style={styles.statDivider} />
            <View style={styles.statItem}>
              <Text style={styles.statNumber}>{profile.locationState}</Text>
              <Text style={styles.statLabel}>Work State</Text>
            </View>
          </View>
        </View>

        {/* Upgrade Path */}
        <View style={[styles.card, styles.upgradeCard]}>
          <Text style={styles.cardTitle}>Unlock More Opportunities</Text>
          <Text style={styles.upgradeText}>
            To access high-risk tasks and increase your earnings:
          </Text>
          <View style={styles.upgradeList}>
            {!profile.insuranceValid && (
              <Text style={styles.upgradeItem}>• Verify your insurance</Text>
            )}
            {!profile.backgroundCheckValid && (
              <Text style={styles.upgradeItem}>• Complete background check</Text>
            )}
            <Text style={styles.upgradeItem}>• Complete 5 more tasks to reach Trusted tier</Text>
          </View>
        </View>
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f8fafc',
  },
  loadingContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  loadingText: {
    marginTop: 16,
    fontSize: 16,
    color: '#64748b',
  },
  errorContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 24,
  },
  errorText: {
    fontSize: 16,
    color: '#ef4444',
    textAlign: 'center',
    marginBottom: 16,
  },
  retryButton: {
    backgroundColor: '#22c55e',
    paddingHorizontal: 24,
    paddingVertical: 12,
    borderRadius: 8,
  },
  retryButtonText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: '600',
  },
  scrollView: {
    flex: 1,
  },
  header: {
    padding: 24,
    backgroundColor: '#fff',
    borderBottomWidth: 1,
    borderBottomColor: '#e2e8f0',
  },
  title: {
    fontSize: 28,
    fontWeight: '700',
    color: '#0f172a',
  },
  subtitle: {
    fontSize: 16,
    color: '#64748b',
    marginTop: 4,
  },
  card: {
    backgroundColor: '#fff',
    marginHorizontal: 16,
    marginTop: 16,
    padding: 20,
    borderRadius: 12,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.05,
    shadowRadius: 2,
    elevation: 2,
  },
  cardTitle: {
    fontSize: 18,
    fontWeight: '600',
    color: '#0f172a',
    marginBottom: 16,
  },
  tierRow: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 12,
  },
  tierBadge: {
    paddingHorizontal: 16,
    paddingVertical: 8,
    borderRadius: 20,
  },
  tierBadgeText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: '700',
  },
  tierLevel: {
    marginLeft: 12,
    fontSize: 14,
    color: '#64748b',
  },
  tierDescription: {
    fontSize: 14,
    color: '#64748b',
    lineHeight: 20,
  },
  riskContainer: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 8,
    marginBottom: 12,
  },
  riskBadge: {
    paddingHorizontal: 12,
    paddingVertical: 6,
    borderRadius: 16,
    borderWidth: 1,
  },
  riskBadgeActive: {
    backgroundColor: '#dcfce7',
    borderColor: '#22c55e',
  },
  riskBadgeInactive: {
    backgroundColor: '#f1f5f9',
    borderColor: '#e2e8f0',
  },
  riskBadgeText: {
    fontSize: 12,
    fontWeight: '600',
  },
  riskBadgeTextActive: {
    color: '#166534',
  },
  riskBadgeTextInactive: {
    color: '#94a3b8',
  },
  riskDescription: {
    fontSize: 14,
    color: '#64748b',
  },
  tradeItem: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingVertical: 12,
    borderBottomWidth: 1,
    borderBottomColor: '#f1f5f9',
  },
  tradeIcon: {
    width: 32,
    height: 32,
    borderRadius: 16,
    backgroundColor: '#dcfce7',
    justifyContent: 'center',
    alignItems: 'center',
  },
  tradeIconText: {
    color: '#22c55e',
    fontSize: 16,
    fontWeight: '700',
  },
  tradeInfo: {
    marginLeft: 12,
  },
  tradeName: {
    fontSize: 16,
    fontWeight: '600',
    color: '#0f172a',
  },
  tradeLocation: {
    fontSize: 14,
    color: '#64748b',
  },
  emptyText: {
    fontSize: 14,
    color: '#94a3b8',
    fontStyle: 'italic',
    paddingVertical: 12,
  },
  addButton: {
    marginTop: 12,
    paddingVertical: 12,
    borderWidth: 1,
    borderColor: '#22c55e',
    borderRadius: 8,
    alignItems: 'center',
  },
  addButtonText: {
    color: '#22c55e',
    fontSize: 16,
    fontWeight: '600',
  },
  verificationRow: {
    flexDirection: 'row',
    alignItems: 'flex-start',
  },
  statusIcon: {
    width: 40,
    height: 40,
    borderRadius: 20,
    justifyContent: 'center',
    alignItems: 'center',
  },
  statusIconSuccess: {
    backgroundColor: '#dcfce7',
  },
  statusIconPending: {
    backgroundColor: '#f1f5f9',
  },
  statusIconText: {
    fontSize: 20,
    fontWeight: '700',
  },
  verificationInfo: {
    marginLeft: 12,
    flex: 1,
  },
  verificationName: {
    fontSize: 16,
    fontWeight: '600',
    color: '#0f172a',
  },
  verificationStatus: {
    fontSize: 14,
    marginTop: 2,
  },
  statusSuccess: {
    color: '#22c55e',
  },
  statusPending: {
    color: '#94a3b8',
  },
  expiryText: {
    fontSize: 12,
    color: '#94a3b8',
    marginTop: 2,
  },
  verifyButton: {
    marginTop: 16,
    backgroundColor: '#0f172a',
    paddingVertical: 12,
    borderRadius: 8,
    alignItems: 'center',
  },
  verifyButtonText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: '600',
  },
  statsContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-around',
    paddingVertical: 8,
  },
  statItem: {
    alignItems: 'center',
    flex: 1,
  },
  statNumber: {
    fontSize: 32,
    fontWeight: '700',
    color: '#0f172a',
  },
  statLabel: {
    fontSize: 14,
    color: '#64748b',
    marginTop: 4,
  },
  statDivider: {
    width: 1,
    height: 40,
    backgroundColor: '#e2e8f0',
  },
  upgradeCard: {
    backgroundColor: '#f0fdf4',
    borderWidth: 1,
    borderColor: '#bbf7d0',
    marginBottom: 24,
  },
  upgradeText: {
    fontSize: 14,
    color: '#166534',
    marginBottom: 12,
  },
  upgradeList: {
    gap: 8,
  },
  upgradeItem: {
    fontSize: 14,
    color: '#166534',
    lineHeight: 20,
  },
});
