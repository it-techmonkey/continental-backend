import { S3Client, PutObjectCommand, GetObjectCommand } from '@aws-sdk/client-s3';
import { getSignedUrl } from '@aws-sdk/s3-request-presigner';
import crypto from 'crypto';

// S3 Configuration
const s3Client = new S3Client({
    region: process.env.region || process.env.AWS_REGION || 'us-east-1',
    credentials: {
        accessKeyId: process.env.access_key || process.env.AWS_ACCESS_KEY_ID || '',
        secretAccessKey: process.env.secret_key || process.env.AWS_SECRET_ACCESS_KEY || '',
    },
});

const BUCKET_NAME = process.env.bucket_name || process.env.AWS_BUCKET_NAME || '';

// S3 Folder structure
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
     * Upload file to S3
     */
    static async uploadFile(
        fileBuffer: Buffer,
        fileName: string,
        contentType: string,
        folder: string
    ): Promise<string> {
        try {
            const key = this.generateUniqueFileName(fileName, folder);

            const uploadCommand = new PutObjectCommand({
                Bucket: BUCKET_NAME,
                Key: key,
                Body: fileBuffer,
                ContentType: contentType,
                // Make it public readable
                ACL: 'public-read',
            });

            await s3Client.send(uploadCommand);

            // Return the public URL
            const region = process.env.region || process.env.AWS_REGION || 'us-east-1';
            const publicUrl = `https://${BUCKET_NAME}.s3.${region}.amazonaws.com/${key}`;
            return publicUrl;
        } catch (error) {
            console.error('S3 upload error:', error);
            throw new Error('Failed to upload file to S3');
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

        const region = process.env.region || process.env.AWS_REGION || 'us-east-1';
        const fileUrl = `https://${BUCKET_NAME}.s3.${region}.amazonaws.com/${key}`;

        return {
            uploadUrl,
            fileKey: key,
            fileUrl,
        };
    }

    /**
     * Get public URL from S3 key
     */
    static getPublicUrl(key: string): string {
        const region = process.env.region || process.env.AWS_REGION || 'us-east-1';
        return `https://${BUCKET_NAME}.s3.${region}.amazonaws.com/${key}`;
    }

    /**
     * Generate pre-signed URL for reading (if files are private)
     */
    static async generateReadUrl(key: string): Promise<string> {
        const command = new GetObjectCommand({
            Bucket: BUCKET_NAME,
            Key: key,
        });

        return await getSignedUrl(s3Client, command, { expiresIn: 3600 });
    }
}

