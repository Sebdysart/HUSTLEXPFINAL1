import React from 'react';
import { View, Text, Button, StyleSheet } from 'react-native';
import { useNavigation } from '@react-navigation/native';
import { NEUTRAL, SPACING, FONT_SIZE, FONT_WEIGHT } from '../../constants';

export function FramingScreen() {
  const navigation = useNavigation();

  const handleGetStarted = () => {
    console.log('Get Started button pressed');
    navigation.navigate('O2' as never);
  };

  return (
    <View style={styles.container}>
      <Text style={styles.logo}>HustleXP</Text>
      <Text style={styles.welcomeText}>Welcome to HustleXP</Text>
      <Button title="Get Started" onPress={handleGetStarted} />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: SPACING[4],
    backgroundColor: NEUTRAL.BACKGROUND,
  },
  logo: {
    fontSize: FONT_SIZE['4xl'],
    fontWeight: FONT_WEIGHT.bold,
    color: NEUTRAL.TEXT,
    marginBottom: SPACING[6],
  },
  welcomeText: {
    fontSize: FONT_SIZE.xl,
    color: NEUTRAL.TEXT_SECONDARY,
    marginBottom: SPACING[8],
    textAlign: 'center',
  },
});
