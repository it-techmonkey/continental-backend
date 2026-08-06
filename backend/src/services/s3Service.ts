import { S3Client, PutObjectCommand, GetObjectCommand } from '@aws-sdk/client-s3';
import { getSignedUrl } from '@aws-sdk/s3-request-presigner';
import crypto from 'crypto';

// Cloudflare R2 configuration (S3-compatible API)
const R2_ACCOUNT_ID = process.env.R2_ACCOUNT_ID || '';
const R2_ACCESS_KEY_ID = process.env.R2_ACCESS_KEY_ID || '';
const R2_SECRET_ACCESS_KEY = process.env.R2_SECRET_ACCESS_KEY || '';
const BUCKET_NAME = process.env.R2_BUCKET_NAME || '';

// Public base URL for reading objects. Either the bucket's r2.dev subdomain
// or a custom domain bound to the bucket. No trailing slash.
const R2_PUBLIC_URL = (process.env.R2_PUBLIC_URL || '').replace(/\/+$/, '');

// Fail fast at boot rather than on the first upload: an unconfigured bucket
// previously surfaced as an opaque 500 with no indication of the real cause.
const missing = [
    ['R2_ACCOUNT_ID', R2_ACCOUNT_ID],
    ['R2_ACCESS_KEY_ID', R2_ACCESS_KEY_ID],
    ['R2_SECRET_ACCESS_KEY', R2_SECRET_ACCESS_KEY],
    ['R2_BUCKET_NAME', BUCKET_NAME],
    ['R2_PUBLIC_URL', R2_PUBLIC_URL],
].filter(([, value]) => !value).map(([name]) => name);

if (missing.length > 0) {
    console.warn(
        `[r2] Missing environment variables: ${missing.join(', ')}. ` +
        'Upload endpoints will fail until these are set.'
    );
}

// R2 ignores the region but the SDK requires one; 'auto' is the documented value.
const s3Client = new S3Client({
    region: 'auto',
    endpoint: `https://${R2_ACCOUNT_ID}.r2.cloudflarestorage.com`,
    credentials: {
        accessKeyId: R2_ACCESS_KEY_ID,
        secretAccessKey: R2_SECRET_ACCESS_KEY,
    },
});

// Storage folder structure
export const S3_FOLDERS = {
    USER_PROFILES: 'user-profiles',
    AGREEMENTS: 'agreements',
    PROPERTY_IMAGES: 'property-images',
    PAYMENT_PROOFS: 'payment-proofs',
};

export class S3Service {
    /**
     * Generate a unique filename
     */
    static generateUniqueFileName(originalFileName: string, folder: string): string {
        const extension = originalFileName.split('.').pop();
        const uniqueId = crypto.randomBytes(16).toString('hex');
        const timestamp = Date.now();
        return `${folder}/${timestamp}-${uniqueId}.${extension}`;
    }

    /**
     * Upload file to R2
     */
    static async uploadFile(
        fileBuffer: Buffer,
        fileName: string,
        contentType: string,
        folder: string
    ): Promise<string> {
        if (missing.length > 0) {
            throw new Error(`R2 is not configured. Missing: ${missing.join(', ')}`);
        }

        try {
            const key = this.generateUniqueFileName(fileName, folder);

            // No ACL: R2 does not support per-object ACLs. Public reads are
            // granted by enabling public access on the bucket itself.
            const uploadCommand = new PutObjectCommand({
                Bucket: BUCKET_NAME,
                Key: key,
                Body: fileBuffer,
                ContentType: contentType,
            });

            await s3Client.send(uploadCommand);

            return this.getPublicUrl(key);
        } catch (error) {
            console.error('R2 upload error:', error);
            throw new Error('Failed to upload file to R2');
        }
    }

    /**
     * Generate pre-signed URL for direct client upload (alternative approach)
     */
    static async generatePresignedUrl(fileName: string, contentType: string, folder: string): Promise<{
        uploadUrl: string;
        fileKey: string;
        fileUrl: string;
    }> {
        const key = this.generateUniqueFileName(fileName, folder);

        const command = new PutObjectCommand({
            Bucket: BUCKET_NAME,
            Key: key,
            ContentType: contentType,
        });

        const uploadUrl = await getSignedUrl(s3Client, command, { expiresIn: 3600 }); // 1 hour expiry

        return {
            uploadUrl,
            fileKey: key,
            fileUrl: this.getPublicUrl(key),
        };
    }

    /**
     * Get public URL from object key
     */
    static getPublicUrl(key: string): string {
        return `${R2_PUBLIC_URL}/${key}`;
    }

    /**
     * Generate pre-signed URL for reading (if the bucket is private)
     */
    static async generateReadUrl(key: string): Promise<string> {
        const command = new GetObjectCommand({
            Bucket: BUCKET_NAME,
            Key: key,
        });

        return await getSignedUrl(s3Client, command, { expiresIn: 3600 });
    }
}
