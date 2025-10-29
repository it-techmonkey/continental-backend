import { Router } from 'express';
import { PaymentController } from '../controllers/paymentController';
import { authenticate, isAdmin } from '../middleware/authMiddleware';

const router = Router();

/**
 * @route   POST /api/payments
 * @desc    Create a new payment
 * @access  Private (Admin only)
 */
router.post('/', authenticate, isAdmin, PaymentController.createPayment);

/**
 * @route   GET /api/payments
 * @desc    Get all payments
 * @access  Private (Admin only)
 */
router.get('/', authenticate, isAdmin, PaymentController.getAllPayments);

/**
 * @route   GET /api/payments/:id
 * @desc    Get a single payment by ID
 * @access  Private (Admin only)
 */
router.get('/:id', authenticate, isAdmin, PaymentController.getPaymentById);

/**
 * @route   PUT /api/payments/:id
 * @desc    Update a payment by ID
 * @access  Private (Admin only)
 */
router.put('/:id', authenticate, isAdmin, PaymentController.updatePayment);

/**
 * @route   DELETE /api/payments/:id
 * @desc    Delete a payment by ID
 * @access  Private (Admin only)
 */
router.delete('/:id', authenticate, isAdmin, PaymentController.deletePayment);

export default router;

