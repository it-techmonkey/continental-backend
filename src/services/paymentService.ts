import { prisma } from '../lib/prisma';
import { CreatePaymentRequest } from '../types/payment';

export class PaymentService {
    /**
     * Create a new payment
     */
    static async createPayment(data: CreatePaymentRequest) {
        try {
            const payment = await prisma.payments.create({
                data: {
                    emi: data.emi,
                    rent: data.rent,
                    status: data.status || 'due',
                    payment_date: data.payment_date,
                    payment_proof: data.payment_proof,
                    mode_of_payment: data.mode_of_payment || 'online',
                    occupantRecordId: data.occupantRecordId,
                },
            });

            return {
                success: true,
                message: 'Payment created successfully',
                data: payment,
            };
        } catch (error) {
            console.error('Create payment error:', error);
            return {
                success: false,
                message: 'Failed to create payment',
                error: process.env.NODE_ENV === 'development' ? (error as Error).message : undefined,
            };
        }
    }

    /**
     * Get all payments with optional filters
     */
    static async getAllPayments(filters?: {
        status?: string;
    }) {
        try {
            const where: any = {};

            if (filters?.status) {
                where.status = filters.status;
            }

            const payments = await prisma.payments.findMany({
                where,
                orderBy: {
                    payment_date: 'asc', // Most recent upcoming payment_date first (ascending = earliest dates first, nulls last)
                },
            });

            return {
                success: true,
                message: 'Payments retrieved successfully',
                data: {
                    payments,
                    total: payments.length,
                },
            };
        } catch (error) {
            console.error('Get payments error:', error);
            return {
                success: false,
                message: 'Failed to retrieve payments',
            };
        }
    }

    /**
     * Get a single payment by ID
     */
    static async getPaymentById(paymentId: number) {
        try {
            const payment = await prisma.payments.findUnique({
                where: { id: paymentId },
            });

            if (!payment) {
                return {
                    success: false,
                    message: 'Payment not found',
                };
            }

            return {
                success: true,
                message: 'Payment retrieved successfully',
                data: payment,
            };
        } catch (error) {
            console.error('Get payment by ID error:', error);
            return {
                success: false,
                message: 'Failed to retrieve payment',
            };
        }
    }

    /**
     * Update a payment
     */
    static async updatePayment(paymentId: number, data: Partial<CreatePaymentRequest>) {
        try {
            const existingPayment = await prisma.payments.findUnique({
                where: { id: paymentId },
            });

            if (!existingPayment) {
                return {
                    success: false,
                    message: 'Payment not found',
                };
            }

            const updatedPayment = await prisma.payments.update({
                where: { id: paymentId },
                data: {
                    emi: data.emi,
                    rent: data.rent,
                    status: data.status,
                    payment_date: data.payment_date,
                    payment_proof: data.payment_proof,
                    mode_of_payment: data.mode_of_payment,
                    occupantRecordId: data.occupantRecordId,
                },
            });

            return {
                success: true,
                message: 'Payment updated successfully',
                data: updatedPayment,
            };
        } catch (error) {
            console.error('Update payment error:', error);
            return {
                success: false,
                message: 'Failed to update payment',
            };
        }
    }

    /**
     * Delete a payment
     */
    static async deletePayment(paymentId: number) {
        try {
            const existingPayment = await prisma.payments.findUnique({
                where: { id: paymentId },
            });

            if (!existingPayment) {
                return {
                    success: false,
                    message: 'Payment not found',
                };
            }

            await prisma.payments.delete({
                where: { id: paymentId },
            });

            return {
                success: true,
                message: 'Payment deleted successfully',
            };
        } catch (error) {
            console.error('Delete payment error:', error);
            return {
                success: false,
                message: 'Failed to delete payment',
            };
        }
    }
}

