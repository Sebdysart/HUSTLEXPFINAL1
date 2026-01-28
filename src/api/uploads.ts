/**
 * Uploads API - Image and file upload handling
 */

import { api, ApiResponse } from './client';

interface UploadResult {
  id: string;
  url: string;
  thumbnail?: string;
  size: number;
  mimeType: string;
}

interface UploadProgress {
  loaded: number;
  total: number;
  percentage: number;
}

type ProgressCallback = (progress: UploadProgress) => void;

const API_BASE_URL = __DEV__
  ? 'http://localhost:3000/api'
  : 'https://api.hustlexp.com';

/**
 * Upload a single image
 */
export async function uploadImage(
  uri: string,
  onProgress?: ProgressCallback
): Promise<ApiResponse<UploadResult>> {
  try {
    // Get file info from URI
    const filename = uri.split('/').pop() || 'image.jpg';
    const match = /\.(\w+)$/.exec(filename);
    const type = match ? `image/${match[1]}` : 'image/jpeg';

    // Create form data
    const formData = new FormData();
    formData.append('file', {
      uri,
      name: filename,
      type,
    } as any);

    // Use XMLHttpRequest for progress tracking
    return new Promise((resolve) => {
      const xhr = new XMLHttpRequest();

      xhr.upload.onprogress = (event) => {
        if (event.lengthComputable && onProgress) {
          onProgress({
            loaded: event.loaded,
            total: event.total,
            percentage: Math.round((event.loaded / event.total) * 100),
          });
        }
      };

      xhr.onload = () => {
        if (xhr.status >= 200 && xhr.status < 300) {
          try {
            const data = JSON.parse(xhr.responseText);
            resolve({
              data,
              status: xhr.status,
              ok: true,
            });
          } catch {
            resolve({
              data: null as any,
              status: xhr.status,
              ok: false,
              error: 'Invalid response',
            });
          }
        } else {
          resolve({
            data: null as any,
            status: xhr.status,
            ok: false,
            error: `Upload failed: ${xhr.status}`,
          });
        }
      };

      xhr.onerror = () => {
        resolve({
          data: null as any,
          status: 0,
          ok: false,
          error: 'Network error',
        });
      };

      xhr.open('POST', `${API_BASE_URL}/uploads/image`);
      xhr.setRequestHeader('Content-Type', 'multipart/form-data');
      // Auth token would be added here
      xhr.send(formData);
    });
  } catch (error) {
    return {
      data: null as any,
      status: 0,
      ok: false,
      error: error instanceof Error ? error.message : 'Upload failed',
    };
  }
}

/**
 * Upload multiple images
 */
export async function uploadImages(
  uris: string[],
  onProgress?: (index: number, progress: UploadProgress) => void
): Promise<ApiResponse<UploadResult[]>> {
  const results: UploadResult[] = [];
  const errors: string[] = [];

  for (let i = 0; i < uris.length; i++) {
    const result = await uploadImage(uris[i], (progress) => {
      onProgress?.(i, progress);
    });

    if (result.ok && result.data) {
      results.push(result.data);
    } else {
      errors.push(result.error || `Failed to upload image ${i + 1}`);
    }
  }

  if (errors.length === uris.length) {
    return {
      data: [],
      status: 500,
      ok: false,
      error: errors.join(', '),
    };
  }

  return {
    data: results,
    status: 200,
    ok: true,
    error: errors.length > 0 ? `${errors.length} upload(s) failed` : undefined,
  };
}

/**
 * Delete an uploaded image
 */
export async function deleteImage(imageId: string): Promise<ApiResponse<void>> {
  return api.delete(`/uploads/image/${imageId}`);
}

/**
 * Get presigned upload URL (for direct S3 upload)
 */
export async function getPresignedUrl(
  filename: string,
  contentType: string
): Promise<ApiResponse<{ uploadUrl: string; publicUrl: string }>> {
  return api.post('/uploads/presigned', { filename, contentType });
}

export const uploadsApi = {
  uploadImage,
  uploadImages,
  deleteImage,
  getPresignedUrl,
};
