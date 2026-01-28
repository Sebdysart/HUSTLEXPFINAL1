/**
 * ImagePicker - Photo capture and selection component
 * 
 * Features:
 * - Camera capture
 * - Gallery selection
 * - Multiple image support
 * - Image preview with delete
 * - Compression for upload
 */

import React, { useState } from 'react';
import {
  StyleSheet,
  View,
  TouchableOpacity,
  Text,
  Image,
  ScrollView,
  Alert,
} from 'react-native';
import {
  launchCamera,
  launchImageLibrary,
  ImagePickerResponse,
  Asset,
  CameraOptions,
  ImageLibraryOptions,
} from 'react-native-image-picker';
import { colors, typography } from '../theme';

interface ImagePickerProps {
  images: string[];
  onImagesChange: (images: string[]) => void;
  maxImages?: number;
  showLabels?: boolean;
  label?: string;
  required?: boolean;
}

const commonOptions: CameraOptions & ImageLibraryOptions = {
  mediaType: 'photo',
  quality: 0.8,
  maxWidth: 1200,
  maxHeight: 1200,
  includeBase64: false,
};

export const ImagePicker: React.FC<ImagePickerProps> = ({
  images,
  onImagesChange,
  maxImages = 5,
  showLabels = true,
  label = 'Photos',
  required = false,
}) => {
  const [loading, setLoading] = useState(false);

  const handleResponse = (response: ImagePickerResponse) => {
    setLoading(false);

    if (response.didCancel) {
      return;
    }

    if (response.errorCode) {
      Alert.alert('Error', response.errorMessage || 'Failed to pick image');
      return;
    }

    if (response.assets && response.assets.length > 0) {
      const newImages = response.assets
        .filter((asset): asset is Asset & { uri: string } => !!asset.uri)
        .map((asset) => asset.uri);

      const combined = [...images, ...newImages].slice(0, maxImages);
      onImagesChange(combined);
    }
  };

  const takePhoto = () => {
    if (images.length >= maxImages) {
      Alert.alert('Limit Reached', `Maximum ${maxImages} photos allowed`);
      return;
    }

    setLoading(true);
    launchCamera(commonOptions, handleResponse);
  };

  const pickFromGallery = () => {
    if (images.length >= maxImages) {
      Alert.alert('Limit Reached', `Maximum ${maxImages} photos allowed`);
      return;
    }

    setLoading(true);
    launchImageLibrary(
      {
        ...commonOptions,
        selectionLimit: maxImages - images.length,
      },
      handleResponse
    );
  };

  const removeImage = (index: number) => {
    Alert.alert('Remove Photo', 'Are you sure you want to remove this photo?', [
      { text: 'Cancel', style: 'cancel' },
      {
        text: 'Remove',
        style: 'destructive',
        onPress: () => {
          const newImages = [...images];
          newImages.splice(index, 1);
          onImagesChange(newImages);
        },
      },
    ]);
  };

  const showOptions = () => {
    Alert.alert('Add Photo', 'Choose an option', [
      { text: 'Take Photo', onPress: takePhoto },
      { text: 'Choose from Gallery', onPress: pickFromGallery },
      { text: 'Cancel', style: 'cancel' },
    ]);
  };

  return (
    <View style={styles.container}>
      {showLabels && (
        <Text style={styles.label}>
          {label}
          {required && <Text style={styles.required}> *</Text>}
        </Text>
      )}

      <ScrollView
        horizontal
        showsHorizontalScrollIndicator={false}
        contentContainerStyle={styles.scrollContent}
      >
        {/* Add button */}
        {images.length < maxImages && (
          <TouchableOpacity
            style={styles.addButton}
            onPress={showOptions}
            disabled={loading}
          >
            <Text style={styles.addIcon}>📷</Text>
            <Text style={styles.addText}>
              {loading ? 'Loading...' : 'Add Photo'}
            </Text>
            <Text style={styles.countText}>
              {images.length}/{maxImages}
            </Text>
          </TouchableOpacity>
        )}

        {/* Image previews */}
        {images.map((uri, index) => (
          <View key={uri} style={styles.imageContainer}>
            <Image source={{ uri }} style={styles.image} />
            <TouchableOpacity
              style={styles.removeButton}
              onPress={() => removeImage(index)}
            >
              <Text style={styles.removeIcon}>✕</Text>
            </TouchableOpacity>
            <View style={styles.indexBadge}>
              <Text style={styles.indexText}>{index + 1}</Text>
            </View>
          </View>
        ))}
      </ScrollView>

      {showLabels && (
        <Text style={styles.helperText}>
          Add photos of the task location or requirements
        </Text>
      )}
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    marginBottom: 16,
  },
  label: {
    ...typography.subhead,
    color: colors.text.primary,
    marginBottom: 8,
    fontWeight: '600',
  },
  required: {
    color: colors.error,
  },
  scrollContent: {
    paddingVertical: 4,
    gap: 12,
  },
  addButton: {
    width: 100,
    height: 100,
    backgroundColor: colors.surface.secondary,
    borderRadius: 12,
    borderWidth: 2,
    borderStyle: 'dashed',
    borderColor: colors.surface.tertiary,
    justifyContent: 'center',
    alignItems: 'center',
  },
  addIcon: {
    fontSize: 24,
    marginBottom: 4,
  },
  addText: {
    ...typography.caption,
    color: colors.text.secondary,
    fontWeight: '500',
  },
  countText: {
    ...typography.caption,
    color: colors.text.tertiary,
    fontSize: 10,
    marginTop: 2,
  },
  imageContainer: {
    width: 100,
    height: 100,
    borderRadius: 12,
    overflow: 'hidden',
    position: 'relative',
  },
  image: {
    width: '100%',
    height: '100%',
    resizeMode: 'cover',
  },
  removeButton: {
    position: 'absolute',
    top: 4,
    right: 4,
    backgroundColor: colors.error,
    width: 24,
    height: 24,
    borderRadius: 12,
    justifyContent: 'center',
    alignItems: 'center',
  },
  removeIcon: {
    color: colors.text.primary,
    fontSize: 12,
    fontWeight: 'bold',
  },
  indexBadge: {
    position: 'absolute',
    bottom: 4,
    left: 4,
    backgroundColor: 'rgba(0,0,0,0.6)',
    width: 20,
    height: 20,
    borderRadius: 10,
    justifyContent: 'center',
    alignItems: 'center',
  },
  indexText: {
    ...typography.caption,
    color: colors.text.primary,
    fontSize: 10,
    fontWeight: 'bold',
  },
  helperText: {
    ...typography.caption,
    color: colors.text.tertiary,
    marginTop: 8,
  },
});

export default ImagePicker;
