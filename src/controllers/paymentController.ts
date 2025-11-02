import { Request, Response } from 'express';
import { PaymentService } from '../services/paymentService';
import { CreatePaymentRequest } from '../types/payment';
import { PaymentStatus, PaymentMode } from '@prisma/client';

export class PaymentController {
    /**
     * Handle creating a new payment
     */
    static async createPayment(req: Request, res: Response): Promise<void> {
        try {
            const {
                emi,
                rent,
                status,
                payment_date,
                payment_proof,
                mode_of_payment,
                occupantRecordId,
                offplan_agreement,
            } = req.body;

            // Validate enum values
            const validStatusValues = ['due', 'paid', 'overdue'];
            const validPaymentModeValues = ['online', 'offline', 'cheque'];

            if (status && !validStatusValues.includes(status)) {
                res.status(400).json({
                    success: false,
                    message: `Invalid status value. Must be one of: ${validStatusValues.join(', ')}`,
                });
                return;
            }

            if (mode_of_payment && !validPaymentModeValues.includes(mode_of_payment)) {
                res.status(400).json({
                    success: false,
                    message: `Invalid payment mode value. Must be one of: ${validPaymentModeValues.join(', ')}`,
                });
                return;
            }

            // Validate that either emi or rent is provided
            if (!emi && !rent) {
                res.status(400).json({
                    success: false,
                    message: 'Either emi or rent must be provided',
                });
                return;
            }

            const paymentData: CreatePaymentRequest = {
                emi,
                rent,
                status: status as PaymentStatus | undefined,
                payment_date: payment_date ? new Date(payment_date) : undefined,
                payment_proof,
                mode_of_payment: mode_of_payment as PaymentMode | undefined,
                occupantRecordId: occupantRecordId ? parseInt(occupantRecordId) : undefined,
                offplan_agreement,
            };

            const result = await PaymentService.createPayment(paymentData);

            if (result.success) {
                res.status(201).json(result);
            } else {
                res.status(400).json(result);
            }
        } catch (error) {
            console.error('Create payment controller error:', error);
            res.status(500).json({
                success: false,
                message: 'Internal server error',
            });
        }
    }

    /**
     * Get all payments with optional filters
     * Query params: status
     */
    static async getAllPayments(req: Request, res: Response): Promise<void> {
        try {
            const { status, property_type, dedupe } = req.query;

            const filters = {
                status: status as string | undefined,
                property_type: property_type as 'Rental' | 'OffPlan' | undefined,
                dedupe: dedupe === 'false' ? false : true,
            };

            const result = await PaymentService.getAllPayments(filters);

            if (result.success) {
                res.status(200).json(result);
            } else {
                res.status(400).json(result);
            }
        } catch (error) {
            console.error('Get payments controller error:', error);
            res.status(500).json({
                success: false,
                message: 'Internal server error',
            });
        }
    }

    /**
     * Get a payment by ID
     */
    static async getPaymentById(req: Request, res: Response): Promise<void> {
        try {
            const paymentId = parseInt(req.params.id);

            if (isNaN(paymentId)) {
                res.status(400).json({
                    success: false,
                    message: 'Invalid payment ID',
                });
                return;
            }

            const result = await PaymentService.getPaymentById(paymentId);

            if (result.success) {
                res.status(200).json(result);
            } else {
                res.status(404).json(result);
            }
        } catch (error) {
            console.error('Get payment by ID controller error:', error);
            res.status(500).json({
                success: false,
                message: 'Internal server error',
            });
        }
    }

    /**
     * Get all payments for a specific occupant record
     */
    static async getPaymentsByOccupant(req: Request, res: Response): Promise<void> {
        try {
            const recordId = parseInt(req.params.id);

            if (isNaN(recordId)) {
                res.status(400).json({
                    success: false,
                    message: 'Invalid occupant record ID',
                });
                return;
            }

            const result = await PaymentService.getPaymentsByOccupant(recordId);

            if (result.success) {
                res.status(200).json(result);
            } else {
                res.status(404).json(result);
            }
        } catch (error) {
            console.error('Get payments by occupant controller error:', error);
            res.status(500).json({
                success: false,
                message: 'Internal server error',
            });
        }
    }

    /**
     * Update a payment
     */
    static async updatePayment(req: Request, res: Response): Promise<void> {
        try {
            const paymentId = parseInt(req.params.id);

            if (isNaN(paymentId)) {
                res.status(400).json({
                    success: false,
                    message: 'Invalid payment ID',
                });
                return;
            }

            const {
                emi,
                rent,
                status,
                payment_date,
                payment_proof,
                mode_of_payment,
                occupantRecordId,
            } = req.body;

            // Validate enum values
            const validStatusValues = ['due', 'paid', 'overdue'];
            const validPaymentModeValues = ['online', 'offline', 'cheque'];

            if (status && !validStatusValues.includes(status)) {
                res.status(400).json({
                    success: false,
                    message: `Invalid status value. Must be one of: ${validStatusValues.join(', ')}`,
                });
                return;
            }

            if (mode_of_payment && !validPaymentModeValues.includes(mode_of_payment)) {
                res.status(400).json({
                    success: false,
                    message: `Invalid payment mode value. Must be one of: ${validPaymentModeValues.join(', ')}`,
                });
                return;
            }

            const paymentData: Partial<CreatePaymentRequest> = {
                emi,
                rent,
                status: status as PaymentStatus | undefined,
                payment_date: payment_date ? new Date(payment_date) : undefined,
                payment_proof,
                mode_of_payment: mode_of_payment as PaymentMode | undefined,
                occupantRecordId: occupantRecordId ? parseInt(occupantRecordId) : undefined,
            };

            const result = await PaymentService.updatePayment(paymentId, paymentData);

            if (result.success) {
                res.status(200).json(result);
            } else {
                res.status(404).json(result);
            }
        } catch (error) {
            console.error('Update payment controller error:', error);
            res.status(500).json({
                success: false,
                message: 'Internal server error',
            });
        }
    }

    /**
     * Delete a payment
     */
    static async deletePayment(req: Request, res: Response): Promise<void> {
        try {
            const paymentId = parseInt(req.params.id);

            if (isNaN(paymentId)) {
                res.status(400).json({
                    success: false,
                    message: 'Invalid payment ID',
                });
                return;
            }

            const result = await PaymentService.deletePayment(paymentId);

            if (result.success) {
                res.status(200).json(result);
            } else {
                res.status(404).json(result);
            }
        } catch (error) {
            console.error('Delete payment controller error:', error);
            res.status(500).json({
                success: false,
                message: 'Internal server error',
            });
        }
    }
}

