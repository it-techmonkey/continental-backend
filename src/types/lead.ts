import { LeadStatus } from '@prisma/client';

export interface CreateLeadRequest {
    name: string;
    phone: string;
    email?: string;
    propertyId?: string;
    projectName?: string;
    developerName?: string;
    type?: string;
    price?: number;
    message?: string;
    notes?: string;
    status?: LeadStatus;
}

export interface LeadResponse {
    success: boolean;
    message: string;
    data?: {
        id: number;
        name: string;
        phone: string;
        email: string | null;
        propertyId: string | null;
        status: LeadStatus;
        message: string | null;
        createdAt: Date;
        updatedAt: Date;
    };
}

export interface LeadsListResponse {
    success: boolean;
    message: string;
    data?: {
        leads: Array<{
            id: number;
            name: string;
            phone: string;
            email: string | null;
            propertyId: string | null;
            status: LeadStatus;
            message: string | null;
            createdAt: Date;
            updatedAt: Date;
        }>;
        total: number;
    };
}
