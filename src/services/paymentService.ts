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

            // Update OccupantRecord's offplan_agreement if provided
            if (data.offplan_agreement && data.occupantRecordId) {
                await prisma.occupantRecord.update({
                    where: { id: data.occupantRecordId },
                    data: {
                        offplan_agreement: data.offplan_agreement,
                    },
                });
            }

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
        property_type?: 'Rental' | 'OffPlan';
        dedupe?: boolean;
    }) {
        try {
            const where: any = {};

            if (filters?.status) {
                where.status = filters.status;
            }

            const payments = await prisma.payments.findMany({
                where: {
                    ...where,
                    ...(filters?.property_type
                        ? { OccupantRecord: { property_type: filters.property_type } }
                        : {}),
                },
                include: {
                    OccupantRecord: {
                        select: {
                            property_type: true,
                            name: true,
                            property_name: true,
                            developer_name: true,
                            phone: true,
                            email: true,
                        },
                    },
                },
                orderBy: {
                    payment_date: 'asc',
                },
            });

            // Transform the response to flatten occupant record fields
            const transformedPayments = payments.map(payment => ({
                id: payment.id,
                emi: payment.emi,
                rent: payment.rent,
                status: payment.status,
                payment_date: payment.payment_date,
                payment_proof: payment.payment_proof,
                mode_of_payment: payment.mode_of_payment,
                occupantRecordId: payment.occupantRecordId,
                property_type: payment.OccupantRecord?.property_type || null,
                name: payment.OccupantRecord?.name || null,
                property_name: payment.OccupantRecord?.property_name || null,
                developer_name: payment.OccupantRecord?.developer_name || null,
                phone: payment.OccupantRecord?.phone || null,
                email: payment.OccupantRecord?.email || null,
            }));

            let list = transformedPayments;
            if (filters?.dedupe !== false) {
                const seen = new Set<number>();
                list = transformedPayments.filter(p => {
                    if (p.occupantRecordId == null) return true;
                    if (seen.has(p.occupantRecordId)) return false;
                    seen.add(p.occupantRecordId);
                    return true;
                });
            }

            return {
                success: true,
                message: 'Payments retrieved successfully',
                data: {
                    payments: list,
                    total: list.length,
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
     * Get all payments by occupant record
     */
    static async getPaymentsByOccupant(occupantRecordId: number) {
        try {
            const payments = await prisma.payments.findMany({
                where: { occupantRecordId },
                orderBy: { payment_date: 'asc' },
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
            console.error('Get payments by occupant error:', error);
            return {
                success: false,
                message: 'Failed to retrieve payments by occupant',
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
                include: {
                    OccupantRecord: {
                        select: {
                            property_type: true,
                            name: true,
                            property_name: true,
                            developer_name: true,
                            phone: true,
                            email: true,
                            image_url: true,
                            completion_date: true,
                            rental_agreement: true,
                            offplan_agreement: true,
                        },
                    },
                },
            });

            if (!payment) {
                return {
                    success: false,
                    message: 'Payment not found',
                };
            }

            // Transform the response to flatten occupant record fields
            const transformedPayment = {
                id: payment.id,
                emi: payment.emi,
                rent: payment.rent,
                status: payment.status,
                payment_date: payment.payment_date,
                payment_proof: payment.payment_proof,
                mode_of_payment: payment.mode_of_payment,
                occupantRecordId: payment.occupantRecordId,
                property_type: payment.OccupantRecord?.property_type || null,
                name: payment.OccupantRecord?.name || null,
                property_name: payment.OccupantRecord?.property_name || null,
                developer_name: payment.OccupantRecord?.developer_name || null,
                phone: payment.OccupantRecord?.phone || null,
                email: payment.OccupantRecord?.email || null,
                image_url: payment.OccupantRecord?.image_url || null,
                completion_date: payment.OccupantRecord?.completion_date || null,
                rental_agreement: payment.OccupantRecord?.rental_agreement || null,
                offplan_agreement: payment.OccupantRecord?.offplan_agreement || null,
            };

            return {
                success: true,
                message: 'Payment retrieved successfully',
                data: transformedPayment,
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

