/**
 * FeedbackScreen - Progress archetype (celebratory completion)
 * 
 * CHOSEN-STATE: "How'd it go?" not "Rate your experience"
 * Star rating, optional comment, celebratory "Done"
 */

import React, { useState } from 'react';
import { View, StyleSheet, Pressable } from 'react-native';
import { useNavigation } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import Animated, {
  useSharedValue,
  useAnimatedStyle,
  withSpring,
  withSequence,
  FadeIn,
  ZoomIn,
} from 'react-native-reanimated';
import { HScreen, HText, HButton, HInput } from '../../components/atoms';
import { hustleSpacing } from '../../theme/hustle-tokens';
import type { RootStackParamList } from '../../navigation/types';

type NavigationProp = NativeStackNavigationProp<RootStackParamList>;

export function FeedbackScreen() {
  const navigation = useNavigation<NavigationProp>();
  const [rating, setRating] = useState(0);
  const [comment, setComment] = useState('');
  const [submitted, setSubmitted] = useState(false);

  const handleSubmit = () => {
    console.log('Feedback submitted:', { rating, comment });
    setSubmitted(true);
  };

  const handleDone = () => {
    navigation.navigate('PosterHome');
  };

  if (submitted) {
    return (
      <HScreen ambient scroll={false}>
        <View style={styles.successContainer}>
          <Animated.View entering={ZoomIn.springify().damping(12)}>
            <HText variant="hero">🎉</HText>
          </Animated.View>

          <View style={styles.successSpacer} />

          <Animated.View entering={FadeIn.delay(300).duration(400)}>
            <HText variant="title1" center>
              Thanks!
            </HText>
            <View style={styles.textSpacer} />
            <HText variant="body" color="secondary" center>
              Your feedback helps the community
            </HText>
          </Animated.View>

          <View style={styles.buttonSpacer} />

          <Animated.View 
            entering={FadeIn.delay(600).duration(400)} 
            style={styles.buttonWrapper}
          >
            <HButton variant="success" size="lg" fullWidth onPress={handleDone}>
              Done
            </HButton>
          </Animated.View>
        </View>
      </HScreen>
    );
  }

  return (
    <HScreen
      ambient
      scroll={false}
      header={
        <Pressable onPress={() => navigation.goBack()} style={styles.backButton}>
          <HText variant="body" color="purple">← Back</HText>
        </Pressable>
      }
      footer={
        <HButton
          variant={rating > 0 ? 'success' : 'primary'}
          size="lg"
          fullWidth
          onPress={handleSubmit}
          disabled={rating === 0}
        >
          {rating > 0 ? 'Done' : 'Rate first'}
        </HButton>
      }
    >
      <View style={styles.content}>
        <Animated.View entering={FadeIn.duration(300)} style={styles.stepContainer}>
          <View style={styles.header}>
            <HText variant="title1" center>
              How'd it go?
            </HText>
            <View style={styles.headerSpacer} />
            <HText variant="body" color="secondary" center>
              Your rating helps everyone
            </HText>
          </View>

          <View style={styles.spacer} />

          {/* Star rating */}
          <View style={styles.starsContainer}>
            {[1, 2, 3, 4, 5].map((star) => (
              <StarButton
                key={star}
                filled={star <= rating}
                onPress={() => setRating(star)}
              />
            ))}
          </View>

          {/* Feedback text based on rating */}
          {rating > 0 && (
            <Animated.View entering={FadeIn.duration(200)} style={styles.ratingFeedback}>
              <HText variant="callout" color="purple" center>
                {getRatingText(rating)}
              </HText>
            </Animated.View>
          )}

          <View style={styles.spacer} />

          {/* Optional comment */}
          {rating > 0 && (
            <Animated.View entering={FadeIn.duration(300)}>
              <HInput
                label="Anything to add? (optional)"
                placeholder="Quick thought..."
                value={comment}
                onChangeText={setComment}
                multiline
                numberOfLines={2}
              />
            </Animated.View>
          )}
        </Animated.View>
      </View>
    </HScreen>
  );
}

function StarButton({
  filled,
  onPress,
}: {
  filled: boolean;
  onPress: () => void;
}) {
  const scale = useSharedValue(1);

  const handlePress = () => {
    scale.value = withSequence(
      withSpring(1.3, { damping: 10, stiffness: 400 }),
      withSpring(1, { damping: 15, stiffness: 400 })
    );
    onPress();
  };

  const animatedStyle = useAnimatedStyle(() => ({
    transform: [{ scale: scale.value }],
  }));

  return (
    <Pressable onPress={handlePress}>
      <Animated.View style={[styles.star, animatedStyle]}>
        <HText variant="hero" style={styles.starEmoji}>
          {filled ? '⭐' : '☆'}
        </HText>
      </Animated.View>
    </Pressable>
  );
}

function getRatingText(rating: number): string {
  switch (rating) {
    case 1:
      return "We'll look into it";
    case 2:
      return 'Noted — thanks for being honest';
    case 3:
      return 'Fair enough!';
    case 4:
      return 'Nice — glad it worked out';
    case 5:
      return 'Amazing! 🔥';
    default:
      return '';
  }
}

const styles = StyleSheet.create({
  content: {
    flex: 1,
    justifyContent: 'center',
  },
  stepContainer: {
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
  textSpacer: {
    height: hustleSpacing.sm,
  },
  backButton: {
    paddingVertical: hustleSpacing.sm,
  },
  starsContainer: {
    flexDirection: 'row',
    justifyContent: 'center',
    gap: hustleSpacing.md,
  },
  star: {
    padding: hustleSpacing.xs,
  },
  starEmoji: {
    fontSize: 40,
  },
  ratingFeedback: {
    marginTop: hustleSpacing.lg,
  },
  successContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: hustleSpacing.xl,
  },
  successSpacer: {
    height: hustleSpacing.xl,
  },
  buttonSpacer: {
    height: hustleSpacing['3xl'],
  },
  buttonWrapper: {
    width: '100%',
  },
});

export default FeedbackScreen;
