import { Request, Response } from 'express';
import { S3Service, S3_FOLDERS } from '../services/s3Service';

export class UploadController {
    /**
     * Upload property image
     */
    static async uploadPropertyImage(req: Request, res: Response): Promise<void> {
        try {
            const file = req.file;
            if (!file) {
                res.status(400).json({ success: false, message: 'No file uploaded' });
                return;
            }

            const url = await S3Service.uploadFile(
                file.buffer,
                file.originalname,
                file.mimetype,
                S3_FOLDERS.PROPERTY_IMAGES
            );

            res.status(200).json({
                success: true,
                message: 'Image uploaded successfully',
                data: { url },
            });
        } catch (error) {
            console.error('Upload property image error:', error);
            res.status(500).json({ success: false, message: 'Failed to upload image' });
        }
    }

    /**
     * Upload agreement (PDF or image)
     */
    static async uploadAgreement(req: Request, res: Response): Promise<void> {
        try {
            const file = req.file;
            if (!file) {
                res.status(400).json({ success: false, message: 'No file uploaded' });
                return;
            }

            const url = await S3Service.uploadFile(
                file.buffer,
                file.originalname,
                file.mimetype,
                S3_FOLDERS.AGREEMENTS
            );

            res.status(200).json({
                success: true,
                message: 'Agreement uploaded successfully',
                data: { url },
            });
        } catch (error) {
            console.error('Upload agreement error:', error);
            res.status(500).json({ success: false, message: 'Failed to upload agreement' });
        }
    }

    /**
     * Upload user profile image
     */
    static async uploadProfileImage(req: Request, res: Response): Promise<void> {
        try {
            const file = req.file;
            if (!file) {
                res.status(400).json({ success: false, message: 'No file uploaded' });
                return;
            }

            const url = await S3Service.uploadFile(
                file.buffer,
                file.originalname,
                file.mimetype,
                S3_FOLDERS.USER_PROFILES
            );

            res.status(200).json({
                success: true,
                message: 'Profile image uploaded successfully',
                data: { url },
            });
        } catch (error) {
            console.error('Upload profile image error:', error);
            res.status(500).json({ success: false, message: 'Failed to upload profile image' });
        }
    }

    /**
     * Upload payment proof
     */
    static async uploadPaymentProof(req: Request, res: Response): Promise<void> {
        try {
            const file = req.file;
            if (!file) {
                res.status(400).json({ success: false, message: 'No file uploaded' });
                return;
            }

            const url = await S3Service.uploadFile(
                file.buffer,
                file.originalname,
                file.mimetype,
                S3_FOLDERS.PAYMENT_PROOFS
            );

            res.status(200).json({
                success: true,
                message: 'Payment proof uploaded successfully',
                data: { url },
            });
        } catch (error) {
            console.error('Upload payment proof error:', error);
            res.status(500).json({ success: false, message: 'Failed to upload payment proof' });
        }
    }
}

