import express from 'express';
import upload from '../middleware/uploadMiddleware';
import { UploadController } from '../controllers/uploadController';
import { authenticate } from '../middleware/authMiddleware';

const router = express.Router();

/**
 * @route   POST /api/upload/property-image
 * @desc    Upload property image to S3
 * @access  Private (Admin only)
 */
router.post(
    '/property-image',
    authenticate,
    upload.single('image'),
    UploadController.uploadPropertyImage
);

/**
 * @route   POST /api/upload/agreement
 * @desc    Upload agreement (PDF or image) to S3
 * @access  Private (Admin only)
 */
router.post(
    '/agreement',
    authenticate,
    upload.single('file'),
    UploadController.uploadAgreement
);

/**
 * @route   POST /api/upload/profile-image
 * @desc    Upload user profile image to S3
 * @access  Private
 */
router.post(
    '/profile-image',
    authenticate,
    upload.single('image'),
    UploadController.uploadProfileImage
);

/**
 * @route   POST /api/upload/payment-proof
 * @desc    Upload payment proof to S3
 * @access  Private (Admin only)
 */
router.post(
    '/payment-proof',
    authenticate,
    upload.single('image'),
    UploadController.uploadPaymentProof
);

export default router;

