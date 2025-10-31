import { PropertyType, Market, RentFrequency, Furnishing } from '@prisma/client';

export interface CreateOccupantRecordRequest {
    name: string;
    phone: string;
    email?: string;
    property_name: string;
    developer_name: string;
    image_url?: string;
    property_type?: PropertyType;
    home_type?: string;
    market?: Market;
    price?: number;
    rent?: number;
    emi?: number;
    city?: string;
    location?: string;
    locality?: string;
    latitude?: number;
    longitude?: number;
    bedrooms?: number;
    bathrooms?: number;
    furnishing?: Furnishing;
    property_views?: string;
    amenities?: string[];
    handover?: Date;
    payment_frequency?: RentFrequency;
    rental_agreement?: string;
    offplan_agreement?: string;
    payment_count?: number;
    completion_date?: Date;
}

export interface OccupantRecordResponse {
    success: boolean;
    message: string;
    data?: {
        id: number;
        name: string;
        phone: string;
        email?: string;
        property_name: string;
        developer_name: string;
        image_url?: string;
        property_type: PropertyType;
        home_type?: string;
        market?: Market;
        bedrooms?: number;
        bathrooms?: number;
        furnishing?: Furnishing;
        price?: number;
        city?: string;
        location?: string;
        locality?: string;
        latitude?: number;
        longitude?: number;
        property_views?: string;
        amenities?: string[];
        handover?: Date;
        rent?: number;
        emi?: number;
        payment_frequency?: RentFrequency;
        rental_agreement?: string;
        offplan_agreement?: string;
        payment_count?: number;
        completion_date?: Date;
        created_at: Date;
        updated_at: Date;
    };
}

