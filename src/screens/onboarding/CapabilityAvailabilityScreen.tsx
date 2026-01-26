/**
 * CapabilityAvailabilityScreen - Availability schedule
 */

import React, { useState } from 'react';
import { View, StyleSheet, TouchableOpacity } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { Button, Text, Spacing } from '../../components';
import { theme } from '../../theme';

const DAYS = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const TIMES = ['Morning', 'Afternoon', 'Evening'];

export function CapabilityAvailabilityScreen() {
  const insets = useSafeAreaInsets();
  const [availability, setAvailability] = useState<Record<string, string[]>>({});

  const toggle = (day: string, time: string) => {
    setAvailability(prev => {
      const dayTimes = prev[day] || [];
      const updated = dayTimes.includes(time)
        ? dayTimes.filter(t => t !== time)
        : [...dayTimes, time];
      return { ...prev, [day]: updated };
    });
  };

  const isSelected = (day: string, time: string) => 
    (availability[day] || []).includes(time);

  return (
    <View style={[styles.container, { paddingTop: insets.top, paddingBottom: insets.bottom }]}>
      <View style={styles.content}>
        <Text variant="title1" color="primary" align="center">
          When are you available?
        </Text>
        <Spacing size={8} />
        <Text variant="body" color="secondary" align="center">
          Tap to select your typical availability
        </Text>

        <Spacing size={32} />

        {/* Header row */}
        <View style={styles.row}>
          <View style={styles.dayLabel} />
          {TIMES.map(t => (
            <Text key={t} variant="caption" color="secondary" style={styles.timeLabel}>
              {t.slice(0, 3)}
            </Text>
          ))}
        </View>

        {/* Day rows */}
        {DAYS.map(day => (
          <View key={day} style={styles.row}>
            <Text variant="body" color="primary" style={styles.dayLabel}>{day}</Text>
            {TIMES.map(time => (
              <TouchableOpacity
                key={time}
                style={[styles.cell, isSelected(day, time) && styles.cellSelected]}
                onPress={() => toggle(day, time)}
              />
            ))}
          </View>
        ))}
      </View>

      <View style={styles.footer}>
        <Button variant="primary" size="lg" onPress={() => console.log(availability)}>
          Continue
        </Button>
        <Spacing size={12} />
        <Button variant="ghost" size="sm" onPress={() => console.log('skip')}>
          Set up later
        </Button>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: theme.colors.surface.primary },
  content: { flex: 1, paddingHorizontal: theme.spacing[4], paddingTop: theme.spacing[8] },
  row: { flexDirection: 'row', alignItems: 'center', marginBottom: theme.spacing[2] },
  dayLabel: { width: 50 },
  timeLabel: { flex: 1, textAlign: 'center' },
  cell: {
    flex: 1,
    height: 40,
    backgroundColor: theme.colors.surface.secondary,
    marginHorizontal: 4,
    borderRadius: theme.radii.sm,
  },
  cellSelected: { backgroundColor: theme.colors.brand.primary },
  footer: { paddingHorizontal: theme.spacing[4], paddingBottom: theme.spacing[4] },
});

export default CapabilityAvailabilityScreen;
