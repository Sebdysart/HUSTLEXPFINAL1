/**
 * CapabilityToolsScreen - What do you have?
 * 
 * CHOSEN-STATE: Unlocking capabilities, not interrogating
 * One decision: What equipment do you have?
 */

import React, { useState } from 'react';
import { View, StyleSheet, Pressable } from 'react-native';
import { useNavigation } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import Animated, {
  useSharedValue,
  useAnimatedStyle,
  withSpring,
} from 'react-native-reanimated';
import { HScreen, HText, HButton, HCard, HTextButton } from '../../components/atoms';
import { hustleSpacing } from '../../theme/hustle-tokens';
import type { RootStackParamList } from '../../navigation/types';

type NavigationProp = NativeStackNavigationProp<RootStackParamList>;

type ToolOption = {
  id: string;
  emoji: string;
  label: string;
};

const TOOLS: ToolOption[] = [
  { id: 'basic', emoji: '🔧', label: 'Basic tools' },
  { id: 'power', emoji: '🔌', label: 'Power tools' },
  { id: 'cleaning', emoji: '🧹', label: 'Cleaning gear' },
  { id: 'garden', emoji: '🌱', label: 'Garden tools' },
  { id: 'none', emoji: '✋', label: 'Just me' },
];

export function CapabilityToolsScreen() {
  const navigation = useNavigation<NavigationProp>();
  const [selected, setSelected] = useState<string[]>([]);

  const toggleTool = (id: string) => {
    if (id === 'none') {
      setSelected(['none']);
    } else {
      setSelected(prev => {
        const filtered = prev.filter(i => i !== 'none');
        return filtered.includes(id) 
          ? filtered.filter(i => i !== id)
          : [...filtered, id];
      });
    }
  };

  const handleContinue = () => {
    navigation.goBack();
  };

  const handleSkip = () => {
    navigation.goBack();
  };

  return (
    <HScreen
      ambient
      scroll={false}
      footer={
        <View style={styles.footer}>
          <HButton 
            variant="primary" 
            size="lg" 
            fullWidth 
            onPress={handleContinue}
          >
            Continue
          </HButton>
          <HTextButton onPress={handleSkip}>
            Skip for now
          </HTextButton>
        </View>
      }
    >
      <View style={styles.content}>
        <View style={styles.header}>
          <HText variant="title1" center>
            What do you have?
          </HText>
          <View style={styles.headerSpacer} />
          <HText variant="body" color="secondary" center>
            More tools = more task types
          </HText>
        </View>

        <View style={styles.spacer} />

        <View style={styles.grid}>
          {TOOLS.map((tool) => (
            <ToolChip
              key={tool.id}
              emoji={tool.emoji}
              label={tool.label}
              selected={selected.includes(tool.id)}
              onPress={() => toggleTool(tool.id)}
            />
          ))}
        </View>

        {selected.length > 0 && !selected.includes('none') && (
          <View style={styles.feedback}>
            <HText variant="caption" color="purple" center>
              Nice setup — more tasks unlocked
            </HText>
          </View>
        )}
      </View>
    </HScreen>
  );
}

function ToolChip({ 
  emoji, 
  label, 
  selected, 
  onPress 
}: { 
  emoji: string; 
  label: string; 
  selected: boolean; 
  onPress: () => void;
}) {
  const scale = useSharedValue(1);

  const handlePressIn = () => {
    scale.value = withSpring(0.95, { damping: 20, stiffness: 400 });
  };

  const handlePressOut = () => {
    scale.value = withSpring(1, { damping: 15, stiffness: 400 });
  };

  const animatedStyle = useAnimatedStyle(() => ({
    transform: [{ scale: scale.value }],
  }));

  return (
    <Pressable
      onPress={onPress}
      onPressIn={handlePressIn}
      onPressOut={handlePressOut}
      style={styles.chipWrapper}
    >
      <Animated.View style={animatedStyle}>
        <HCard 
          variant={selected ? 'outlined' : 'default'} 
          padding="md"
        >
          <View style={styles.chipContent}>
            <HText variant="title2">{emoji}</HText>
            <HText 
              variant="callout" 
              color={selected ? 'primary' : 'secondary'}
              center
            >
              {label}
            </HText>
          </View>
        </HCard>
      </Animated.View>
    </Pressable>
  );
}

const styles = StyleSheet.create({
  content: {
    flex: 1,
    justifyContent: 'center',
  },
  header: {
    alignItems: 'center',
  },
  headerSpacer: {
    height: hustleSpacing.sm,
  },
  spacer: {
    height: hustleSpacing['2xl'],
  },
  grid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    justifyContent: 'space-between',
  },
  chipWrapper: {
    width: '48%',
    marginBottom: hustleSpacing.md,
  },
  chipContent: {
    alignItems: 'center',
    paddingVertical: hustleSpacing.md,
    gap: hustleSpacing.xs,
  },
  feedback: {
    marginTop: hustleSpacing.lg,
  },
  footer: {
    gap: hustleSpacing.sm,
  },
});

export default CapabilityToolsScreen;
