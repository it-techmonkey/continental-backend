import { PaymentStatus, PaymentMode } from '@prisma/client';

export interface CreatePaymentRequest {
    emi?: number;
    rent?: number;
    status?: PaymentStatus;
    payment_date?: Date;
    payment_proof?: string;
    mode_of_payment?: PaymentMode;
    occupantRecordId?: number;
}

export interface PaymentResponse {
    success: boolean;
    message: string;
    data?: {
        id: number;
        emi?: number;
        rent?: number;
        status: PaymentStatus;
        payment_date?: Date;
        payment_proof?: string;
        mode_of_payment: PaymentMode;
        occupantRecordId?: number;
        created_at?: Date;
        updated_at?: Date;
    };
}

