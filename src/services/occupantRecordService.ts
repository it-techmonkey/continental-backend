import { prisma } from '../lib/prisma';
import { CreateOccupantRecordRequest } from '../types/occupantRecord';

export class OccupantRecordService {
    /**
     * Create a new occupant record
     */
    static async createOccupantRecord(data: CreateOccupantRecordRequest) {
        try {
            // Derive sensible defaults if frontend omits schedule config
            const isOffPlanInput = (data.property_type || 'Rental') === 'OffPlan';
            const amountInput = isOffPlanInput ? data.emi : data.rent;
            const defaultFrequency = amountInput ? 'monthly' : undefined; // default monthly when amount exists

            // Derive count if not provided:
            // - OffPlan: if completion_date provided, compute months between now and completion, then divide by interval
            // - Rental: default to 12 months
            let derivedCount: number | undefined;
            if (amountInput) {
                if (isOffPlanInput && data.completion_date) {
                    const now = new Date();
                    const completion = new Date(data.completion_date);
                    const months = (completion.getFullYear() - now.getFullYear()) * 12 + (completion.getMonth() - now.getMonth());
                    const freq = (data.payment_frequency || defaultFrequency) as 'monthly' | 'quarterly' | 'yearly' | undefined;
                    const interval = freq === 'monthly' ? 1 : freq === 'quarterly' ? 3 : 12;
                    derivedCount = Math.max(1, Math.ceil((months > 0 ? months : 1) / interval));
                } else {
                    derivedCount = 12;
                }
            }

            const occupantRecord = await prisma.occupantRecord.create({
                data: {
                    name: data.name,
                    phone: data.phone,
                    email: data.email,
                    property_name: data.property_name,
                    developer_name: data.developer_name,
                    image_url: data.image_url,
                    bedrooms: data.bedrooms,
                    bathrooms: data.bathrooms,
                    furnishing: data.furnishing,
                    price: data.price,
                    city: data.city,
                    location: data.location,
                    locality: data.locality,
                    latitude: data.latitude,
                    longitude: data.longitude,
                    property_views: data.property_views,
                    amenities: data.amenities,
                    property_type: data.property_type || 'Rental',
                    home_type: data.home_type,
                    market: data.market,
                    handover: data.handover,
                    rent: data.rent,
                    emi: data.emi,
                    payment_frequency: (data.payment_frequency || defaultFrequency) as any,
                    rental_agreement: data.rental_agreement,
                    offplan_agreement: data.offplan_agreement,
                    payment_count: (data.payment_count ?? derivedCount),
                    completion_date: data.completion_date,
                    dld: data.dld,
                    quood: data.quood,
                    other_charges: data.other_charges,
                    penalties: data.penalties,
                },
                include: {
                    payments: {
                        select: {
                            status: true,
                            payment_date: true,
                            occupantRecordId: true,
                        },
                    },
                },
            });

            // Auto-generate payment schedule based on property type
            try {
                const isOffPlan = (occupantRecord.property_type === 'OffPlan');
                const frequency = occupantRecord.payment_frequency;
                const paymentCount = occupantRecord.payment_count ?? 0;

                if (paymentCount > 0 && frequency) {
                    // Calculate EMI for OffPlan: total price / payment count
                    let amount: number | null = null;
                    if (isOffPlan && occupantRecord.price && occupantRecord.price > 0) {
                        amount = Math.round(occupantRecord.price / paymentCount);
                    } else if (!isOffPlan && occupantRecord.rent && occupantRecord.rent > 0) {
                        amount = occupantRecord.rent;
                    }

                    if (amount && amount > 0) {
                        const intervalMonths = frequency === 'monthly' ? 1 : frequency === 'quarterly' ? 3 : 12;

                        const baseDate = occupantRecord.created_at ?? new Date();
                        const paymentsData: {
                            emi?: number;
                            rent?: number;
                            status: 'due' | 'paid' | 'overdue';
                            payment_date: Date;
                            occupantRecordId: number;
                        }[] = [];

                        for (let i = 0; i < paymentCount; i++) {
                            const dueDate = new Date(baseDate);
                            // Calculate months to add
                            const monthsToAdd = i * intervalMonths;
                            
                            // Get the day of month from the base date
                            const baseDay = dueDate.getDate();
                            
                            // Add months to the date
                            dueDate.setMonth(dueDate.getMonth() + monthsToAdd);
                            
                            // If the day has changed (e.g., Jan 31 -> Feb becomes Mar 3),
                            // set it back to the last valid day of the month
                            if (dueDate.getDate() !== baseDay) {
                                // Get the last day of the new month
                                const lastDayOfMonth = new Date(dueDate.getFullYear(), dueDate.getMonth() + 1, 0).getDate();
                                dueDate.setDate(lastDayOfMonth);
                            }

                            paymentsData.push({
                                ...(isOffPlan ? { emi: amount } : { rent: amount }),
                                status: 'due',
                                payment_date: dueDate,
                                occupantRecordId: occupantRecord.id,
                            });
                        }

                        if (paymentsData.length > 0) {
                            await prisma.payments.createMany({ data: paymentsData });
                        }
                    }
                }
            } catch (scheduleError) {
                // Log and continue; creation of occupant record should not fail due to schedule generation
                console.error('Auto-generate payments schedule error:', scheduleError);
            }

            return {
                success: true,
                message: 'Occupant record created successfully',
                data: {
                    id: occupantRecord.id,
                    name: occupantRecord.name,
                    phone: occupantRecord.phone,
                    email: occupantRecord.email,
                    property_name: occupantRecord.property_name,
                    developer_name: occupantRecord.developer_name,
                    image_url: occupantRecord.image_url,
                    property_type: occupantRecord.property_type,
                    market: occupantRecord.market,
                    price: occupantRecord.price,
                    rent: occupantRecord.rent,
                    emi: occupantRecord.emi,
                    city: occupantRecord.city,
                    location: occupantRecord.location,
                    latitude: occupantRecord.latitude,
                    longitude: occupantRecord.longitude,
                    bedrooms: occupantRecord.bedrooms,
                    bathrooms: occupantRecord.bathrooms,
                    furnishing: occupantRecord.furnishing,
                    property_views: occupantRecord.property_views,
                    amenities: occupantRecord.amenities,
                    handover: occupantRecord.handover,
                    payment_frequency: occupantRecord.payment_frequency,
                    rental_agreement: occupantRecord.rental_agreement,
                    offplan_agreement: occupantRecord.offplan_agreement,
                    payment_count: occupantRecord.payment_count,
                    completion_date: occupantRecord.completion_date,
                    payments: occupantRecord.payments,
                    created_at: occupantRecord.created_at,
                    updated_at: occupantRecord.updated_at,
                },
            };
        } catch (error) {
            console.error('Create occupant record error:', error);
            return {
                success: false,
                message: 'Failed to create occupant record',
                error: process.env.NODE_ENV === 'development' ? (error as Error).message : undefined,
            };
        }
    }

    /**
     * Get all occupant records with optional filters
     */
    static async getAllOccupantRecords(filters?: {
        property_type?: string;
        market?: string;
        city?: string;
        search?: string;
    }) {
        try {
            const where: any = {};

            if (filters?.property_type) {
                where.property_type = filters.property_type;
            }

            if (filters?.market) {
                where.market = filters.market;
            }

            if (filters?.city) {
                where.city = { contains: filters.city, mode: 'insensitive' };
            }

            if (filters?.search) {
                where.OR = [
                    { property_name: { contains: filters.search, mode: 'insensitive' } },
                    { developer_name: { contains: filters.search, mode: 'insensitive' } },
                    { location: { contains: filters.search, mode: 'insensitive' } },
                ];
            }

            const occupantRecords = await prisma.occupantRecord.findMany({
                where,
                include: {
                    payments: {
                        select: {
                            status: true,
                            payment_date: true,
                            occupantRecordId: true,
                        },
                    },
                },
                orderBy: {
                    created_at: 'desc',
                },
            });

            // Reorder fields in response
            const orderedRecords = occupantRecords.map(record => ({
                id: record.id,
                name: record.name,
                phone: record.phone,
                email: record.email,
                property_name: record.property_name,
                developer_name: record.developer_name,
                image_url: record.image_url,
                property_type: record.property_type,
                market: record.market,
                // price: record.price,
                rent: record.rent,
                emi: record.emi,
                // payment_frequency: record.payment_frequency,
                // payment_count: record.payment_count,
                // city: record.city,
                // location: record.location,
                latitude: record.latitude,
                longitude: record.longitude,
                // bedrooms: record.bedrooms,
                // bathrooms: record.bathrooms,
                // furnishing: record.furnishing,
                // property_views: record.property_views,
                // amenities: record.amenities,
                // handover: record.handover,
                // rental_agreement: record.rental_agreement,
                // offplan_agreement: record.offplan_agreement,
                // completion_date: record.completion_date,
                payments: record.payments,
                created_at: record.created_at,
                updated_at: record.updated_at,
            }));

            return {
                success: true,
                message: 'Occupant records retrieved successfully',
                data: {
                    records: orderedRecords,
                    total: orderedRecords.length,
                },
            };
        } catch (error) {
            console.error('Get occupant records error:', error);
            return {
                success: false,
                message: 'Failed to retrieve occupant records',
            };
        }
    }

    /**
     * Get a single occupant record by ID
     */
    static async getOccupantRecordById(recordId: number) {
        try {
            const record = await prisma.occupantRecord.findUnique({
                where: { id: recordId },
                include: {
                    payments: {
                        select: {
                            status: true,
                            payment_date: true,
                            occupantRecordId: true,
                        },
                    },
                },
            });

            if (!record) {
                return {
                    success: false,
                    message: 'Occupant record not found',
                };
            }

            return {
                success: true,
                message: 'Occupant record retrieved successfully',
                data: {
                    id: record.id,
                    name: record.name,
                    phone: record.phone,
                    email: record.email,
                    property_name: record.property_name,
                    developer_name: record.developer_name,
                    image_url: record.image_url,
                    property_type: record.property_type,
                    home_type: record.home_type,
                    market: record.market,
                    price: record.price,
                    rent: record.rent,
                    emi: record.emi,
                    payment_count: record.payment_count,
                    payment_frequency: record.payment_frequency,
                    city: record.city,
                    location: record.location,
                    locality: record.locality,
                    latitude: record.latitude,
                    longitude: record.longitude,
                    bedrooms: record.bedrooms,
                    bathrooms: record.bathrooms,
                    furnishing: record.furnishing,
                    property_views: record.property_views,
                    amenities: record.amenities,
                    handover: record.handover,
                    rental_agreement: record.rental_agreement,
                    offplan_agreement: record.offplan_agreement,
                    completion_date: record.completion_date,
                    dld: record.dld,
                    quood: record.quood,
                    other_charges: record.other_charges,
                    penalties: record.penalties,
                    payments: record.payments,
                    created_at: record.created_at,
                    updated_at: record.updated_at,
                },
            };
        } catch (error) {
            console.error('Get occupant record by ID error:', error);
            return {
                success: false,
                message: 'Failed to retrieve occupant record',
            };
        }
    }

    /**
     * Update an occupant record
     */
    static async updateOccupantRecord(recordId: number, data: Partial<CreateOccupantRecordRequest>) {
        try {
            const existingRecord = await prisma.occupantRecord.findUnique({
                where: { id: recordId },
            });

            if (!existingRecord) {
                return {
                    success: false,
                    message: 'Occupant record not found',
                };
            }

            // Build update data object, only including fields that are explicitly provided
            const updateData: any = {};
            
            if (data.name !== undefined) updateData.name = data.name;
            if (data.phone !== undefined) updateData.phone = data.phone;
            if (data.email !== undefined) updateData.email = data.email;
            if (data.property_name !== undefined) updateData.property_name = data.property_name;
            if (data.developer_name !== undefined) updateData.developer_name = data.developer_name;
            if (data.image_url !== undefined) updateData.image_url = data.image_url;
            if (data.bedrooms !== undefined) updateData.bedrooms = data.bedrooms;
            if (data.bathrooms !== undefined) updateData.bathrooms = data.bathrooms;
            if (data.furnishing !== undefined) updateData.furnishing = data.furnishing;
            if (data.price !== undefined) updateData.price = data.price;
            if (data.city !== undefined) updateData.city = data.city;
            if (data.location !== undefined) updateData.location = data.location;
            if (data.locality !== undefined) updateData.locality = data.locality;
            if (data.latitude !== undefined) updateData.latitude = data.latitude;
            if (data.longitude !== undefined) updateData.longitude = data.longitude;
            if (data.property_views !== undefined) updateData.property_views = data.property_views;
            if (data.amenities !== undefined) updateData.amenities = data.amenities;
            if (data.property_type !== undefined) updateData.property_type = data.property_type;
            if (data.home_type !== undefined) updateData.home_type = data.home_type;
            if (data.market !== undefined) updateData.market = data.market;
            if (data.handover !== undefined) updateData.handover = data.handover;
            if (data.rent !== undefined) updateData.rent = data.rent;
            if (data.emi !== undefined) updateData.emi = data.emi;
            if (data.payment_frequency !== undefined) updateData.payment_frequency = data.payment_frequency;
            if (data.rental_agreement !== undefined) updateData.rental_agreement = data.rental_agreement;
            if (data.offplan_agreement !== undefined) updateData.offplan_agreement = data.offplan_agreement;
            if (data.payment_count !== undefined) updateData.payment_count = data.payment_count;
            if (data.completion_date !== undefined) updateData.completion_date = data.completion_date;
            // Only update charge fields if they are explicitly provided (including null to clear)
            if (data.dld !== undefined) updateData.dld = data.dld;
            if (data.quood !== undefined) updateData.quood = data.quood;
            if (data.other_charges !== undefined) updateData.other_charges = data.other_charges;
            if (data.penalties !== undefined) updateData.penalties = data.penalties;

            const updatedRecord = await prisma.occupantRecord.update({
                where: { id: recordId },
                include: {
                    payments: {
                        select: {
                            status: true,
                            payment_date: true,
                            occupantRecordId: true,
                        },
                    },
                },
                data: updateData,
            });

            return {
                success: true,
                message: 'Occupant record updated successfully',
                data: {
                    id: updatedRecord.id,
                    name: updatedRecord.name,
                    phone: updatedRecord.phone,
                    email: updatedRecord.email,
                    property_name: updatedRecord.property_name,
                    developer_name: updatedRecord.developer_name,
                    image_url: updatedRecord.image_url,
                    property_type: updatedRecord.property_type,
                    home_type: updatedRecord.home_type,
                    market: updatedRecord.market,
                    price: updatedRecord.price,
                    rent: updatedRecord.rent,
                    emi: updatedRecord.emi,
                    city: updatedRecord.city,
                    location: updatedRecord.location,
                    latitude: updatedRecord.latitude,
                    longitude: updatedRecord.longitude,
                    bedrooms: updatedRecord.bedrooms,
                    bathrooms: updatedRecord.bathrooms,
                    furnishing: updatedRecord.furnishing,
                    property_views: updatedRecord.property_views,
                    amenities: updatedRecord.amenities,
                    handover: updatedRecord.handover,
                    payment_frequency: updatedRecord.payment_frequency,
                    rental_agreement: updatedRecord.rental_agreement,
                    offplan_agreement: updatedRecord.offplan_agreement,
                    payment_count: updatedRecord.payment_count,
                    completion_date: updatedRecord.completion_date,
                    dld: updatedRecord.dld ?? null,
                    quood: updatedRecord.quood ?? null,
                    other_charges: updatedRecord.other_charges ?? null,
                    penalties: updatedRecord.penalties ?? null,
                    payments: updatedRecord.payments,
                    created_at: updatedRecord.created_at,
                    updated_at: updatedRecord.updated_at,
                },
            };
        } catch (error) {
            console.error('Update occupant record error:', error);
            return {
                success: false,
                message: 'Failed to update occupant record',
            };
        }
    }

    /**
     * Delete an occupant record
     */
    static async deleteOccupantRecord(recordId: number) {
        try {
            const existingRecord = await prisma.occupantRecord.findUnique({
                where: { id: recordId },
            });

            if (!existingRecord) {
                return {
                    success: false,
                    message: 'Occupant record not found',
                };
            }

            await prisma.occupantRecord.delete({
                where: { id: recordId },
            });

            return {
                success: true,
                message: 'Occupant record deleted successfully',
            };
        } catch (error) {
            console.error('Delete occupant record error:', error);
            return {
                success: false,
                message: 'Failed to delete occupant record',
            };
        }
    }

    /**
     * Get dashboard statistics
     */
    static async getDashboardStats() {
        try {
            const [
                totalRented,
                rentalsDue,
                rentalAmountDue,
                vacantProperties,
                totalOffPlan,
                totalProperties
            ] = await Promise.all([
                // Total properties rented
                prisma.occupantRecord.count({
                    where: { property_type: 'Rental' }
                }),
                // Rentals due (assuming payment_count < total_installments or similar logic)
                prisma.occupantRecord.count({
                    where: {
                        property_type: 'Rental',
                        payment_frequency: { not: null }
                    }
                }),
                // Rental Amount Due (sum of rent for active rentals)
                prisma.occupantRecord.aggregate({
                    where: {
                        property_type: 'Rental',
                        rent: { not: null }
                    },
                    _sum: { rent: true }
                }),
                // Vacant properties (properties with no rent or payment_count = 0)
                prisma.occupantRecord.count({
                    where: {
                        OR: [
                            { rent: null },
                            { payment_count: 0 }
                        ]
                    }
                }),
                // Total off plan properties
                prisma.occupantRecord.count({
                    where: { property_type: 'OffPlan' }
                }),
                // Total properties
                prisma.occupantRecord.count()
            ]);

            // Calculate EMI amount due (sum of unpaid EMIs for OffPlan payments)
            const emiAggregate = await prisma.payments.aggregate({
                where: {
                    status: { in: ['due', 'overdue'] },
                    emi: { not: null }
                },
                _sum: { emi: true }
            });

            return {
                success: true,
                message: 'Dashboard stats retrieved successfully',
                data: {
                    total_properties_rented: totalRented,
                    rentals_due: rentalsDue,
                    rental_amount_due: rentalAmountDue._sum.rent || 0,
                    vacant_properties: vacantProperties,
                    total_off_plan_properties: totalOffPlan,
                    emi_amount_due: emiAggregate._sum.emi || 0
                }
            };
        } catch (error) {
            console.error('Get dashboard stats error:', error);
            return {
                success: false,
                message: 'Failed to retrieve dashboard stats',
            };
        }
    }

    /**
     * Get occupant records for maps with filtered fields
     */
    static async getOccupantRecordsForMaps(filters?: {
        property_type?: string;
        search?: string;
    }) {
        try {
            const where: any = {};

            if (filters?.property_type) {
                where.property_type = filters.property_type;
            }

            if (filters?.search) {
                where.property_name = { contains: filters.search, mode: 'insensitive' };
            }

            const records = await prisma.occupantRecord.findMany({
                where,
                select: {
                    id: true,
                    developer_name: true,
                    property_name: true,
                    price: true,
                    image_url: true,
                    property_type: true,
                    location: true,
                    longitude: true,
                    latitude: true,
                },
                orderBy: {
                    created_at: 'desc',
                },
            });

            return {
                success: true,
                message: 'Occupant records for maps retrieved successfully',
                data: {
                    records,
                    total: records.length,
                },
            };
        } catch (error) {
            console.error('Get occupant records for maps error:', error);
            return {
                success: false,
                message: 'Failed to retrieve occupant records for maps',
            };
        }
    }
}

