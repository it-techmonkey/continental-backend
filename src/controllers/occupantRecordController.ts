import { Request, Response } from 'express';
import { OccupantRecordService } from '../services/occupantRecordService';
import { CreateOccupantRecordRequest } from '../types/occupantRecord';
import { Furnishing, RentFrequency, PropertyType, Market } from '@prisma/client';

export class OccupantRecordController {
    /**
     * Handle creating a new occupant record
     */
    static async createOccupantRecord(req: Request, res: Response): Promise<void> {
        try {
            const {
                name,
                phone,
                email,
                property_name,
                developer_name,
                image_url,
                bedrooms,
                bathrooms,
                furnishing,
                price,
                city,
                location,
                latitude,
                longitude,
                property_views,
                amenities,
                property_type,
                market,
                handover,
                rent,
                emi,
                payment_frequency,
                rental_agreement,
                offplan_agreement,
                payment_count,
                completion_date,
            } = req.body;

            // Validate required fields
            if (!name || !phone || !property_name || !developer_name) {
                res.status(400).json({
                    success: false,
                    message: 'Name, phone, property name and developer name are required',
                });
                return;
            }

            // Validate enum values
            const validFurnishingValues = ['fully_furnished', 'partially_furnished', 'unfurnished', 'kitchen_appliances_only'];
            const validRentFrequencyValues = ['monthly', 'quarterly', 'yearly'];
            const validPropertyTypes = ['Rental', 'OffPlan'];
            const validMarkets = ['Primary', 'Secondary'];

            if (furnishing && !validFurnishingValues.includes(furnishing)) {
                res.status(400).json({
                    success: false,
                    message: `Invalid furnishing value. Must be one of: ${validFurnishingValues.join(', ')}`,
                });
                return;
            }

            if (payment_frequency && !validRentFrequencyValues.includes(payment_frequency)) {
                res.status(400).json({
                    success: false,
                    message: `Invalid payment frequency value. Must be one of: ${validRentFrequencyValues.join(', ')}`,
                });
                return;
            }

            if (property_type && !validPropertyTypes.includes(property_type)) {
                res.status(400).json({
                    success: false,
                    message: `Invalid property type value. Must be one of: ${validPropertyTypes.join(', ')}`,
                });
                return;
            }

            if (market && !validMarkets.includes(market)) {
                res.status(400).json({
                    success: false,
                    message: `Invalid market value. Must be one of: ${validMarkets.join(', ')}`,
                });
                return;
            }

            // Validate latitude and longitude if provided
            if (latitude !== undefined && (isNaN(latitude) || latitude < -90 || latitude > 90)) {
                res.status(400).json({
                    success: false,
                    message: 'Invalid latitude value',
                });
                return;
            }

            if (longitude !== undefined && (isNaN(longitude) || longitude < -180 || longitude > 180)) {
                res.status(400).json({
                    success: false,
                    message: 'Invalid longitude value',
                });
                return;
            }

            // Convert amenities to array if it's a string
            let amenitiesArray: string[] | undefined;
            if (amenities) {
                if (Array.isArray(amenities)) {
                    amenitiesArray = amenities;
                } else if (typeof amenities === 'string') {
                    // Support both comma-separated string and single string
                    amenitiesArray = [amenities];
                }
            }

            const occupantRecordData: CreateOccupantRecordRequest = {
                name,
                phone,
                email,
                property_name,
                developer_name,
                image_url,
                bedrooms,
                bathrooms,
                furnishing: furnishing as Furnishing | undefined,
                price,
                city,
                location,
                latitude,
                longitude,
                property_views,
                amenities: amenitiesArray,
                property_type: property_type as PropertyType | undefined,
                market: market as Market | undefined,
                handover: handover ? new Date(handover) : undefined,
                rent,
                emi,
                payment_frequency: payment_frequency as RentFrequency | undefined,
                rental_agreement,
                offplan_agreement,
                payment_count,
                completion_date: completion_date ? new Date(completion_date) : undefined,
            };

            const result = await OccupantRecordService.createOccupantRecord(occupantRecordData);

            if (result.success) {
                res.status(201).json(result);
            } else {
                res.status(400).json(result);
            }
        } catch (error) {
            console.error('Create occupant record controller error:', error);
            res.status(500).json({
                success: false,
                message: 'Internal server error',
            });
        }
    }

    /**
     * Get all occupant records with optional filters
     * Query params: property_type, market, city, search
     */
    static async getAllOccupantRecords(req: Request, res: Response): Promise<void> {
        try {
            const { property_type, market, city, search } = req.query;

            const filters = {
                property_type: property_type as string | undefined,
                market: market as string | undefined,
                city: city as string | undefined,
                search: search as string | undefined,
            };

            const result = await OccupantRecordService.getAllOccupantRecords(filters);

            if (result.success) {
                res.status(200).json(result);
            } else {
                res.status(400).json(result);
            }
        } catch (error) {
            console.error('Get occupant records controller error:', error);
            res.status(500).json({
                success: false,
                message: 'Internal server error',
            });
        }
    }

    /**
     * Get an occupant record by ID
     */
    static async getOccupantRecordById(req: Request, res: Response): Promise<void> {
        try {
            const recordId = parseInt(req.params.id);

            if (isNaN(recordId)) {
                res.status(400).json({
                    success: false,
                    message: 'Invalid record ID',
                });
                return;
            }

            const result = await OccupantRecordService.getOccupantRecordById(recordId);

            if (result.success) {
                res.status(200).json(result);
            } else {
                res.status(404).json(result);
            }
        } catch (error) {
            console.error('Get occupant record by ID controller error:', error);
            res.status(500).json({
                success: false,
                message: 'Internal server error',
            });
        }
    }

    /**
     * Update an occupant record
     */
    static async updateOccupantRecord(req: Request, res: Response): Promise<void> {
        try {
            const recordId = parseInt(req.params.id);

            if (isNaN(recordId)) {
                res.status(400).json({
                    success: false,
                    message: 'Invalid record ID',
                });
                return;
            }

            const {
                name,
                phone,
                email,
                property_name,
                developer_name,
                image_url,
                bedrooms,
                bathrooms,
                furnishing,
                price,
                city,
                location,
                latitude,
                longitude,
                property_views,
                amenities,
                property_type,
                market,
                handover,
                rent,
                emi,
                payment_frequency,
                rental_agreement,
                offplan_agreement,
                payment_count,
                completion_date,
            } = req.body;

            // Validate enum values
            const validFurnishingValues = ['fully_furnished', 'partially_furnished', 'unfurnished', 'kitchen_appliances_only'];
            const validRentFrequencyValues = ['monthly', 'quarterly', 'yearly'];
            const validPropertyTypes = ['Rental', 'OffPlan'];
            const validMarkets = ['Primary', 'Secondary'];

            if (furnishing && !validFurnishingValues.includes(furnishing)) {
                res.status(400).json({
                    success: false,
                    message: `Invalid furnishing value. Must be one of: ${validFurnishingValues.join(', ')}`,
                });
                return;
            }

            if (payment_frequency && !validRentFrequencyValues.includes(payment_frequency)) {
                res.status(400).json({
                    success: false,
                    message: `Invalid rent frequency value. Must be one of: ${validRentFrequencyValues.join(', ')}`,
                });
                return;
            }

            if (property_type && !validPropertyTypes.includes(property_type)) {
                res.status(400).json({
                    success: false,
                    message: `Invalid property type value. Must be one of: ${validPropertyTypes.join(', ')}`,
                });
                return;
            }

            if (market && !validMarkets.includes(market)) {
                res.status(400).json({
                    success: false,
                    message: `Invalid market value. Must be one of: ${validMarkets.join(', ')}`,
                });
                return;
            }

            // Validate latitude and longitude if provided
            if (latitude !== undefined && (isNaN(latitude) || latitude < -90 || latitude > 90)) {
                res.status(400).json({
                    success: false,
                    message: 'Invalid latitude value',
                });
                return;
            }

            if (longitude !== undefined && (isNaN(longitude) || longitude < -180 || longitude > 180)) {
                res.status(400).json({
                    success: false,
                    message: 'Invalid longitude value',
                });
                return;
            }

            // Convert amenities to array if it's a string
            let amenitiesArray: string[] | undefined;
            if (amenities) {
                if (Array.isArray(amenities)) {
                    amenitiesArray = amenities;
                } else if (typeof amenities === 'string') {
                    amenitiesArray = [amenities];
                }
            }

            const occupantRecordData: Partial<CreateOccupantRecordRequest> = {
                name,
                phone,
                email,
                property_name,
                developer_name,
                image_url,
                bedrooms,
                bathrooms,
                furnishing: furnishing as Furnishing | undefined,
                price,
                city,
                location,
                latitude,
                longitude,
                property_views,
                amenities: amenitiesArray,
                property_type: property_type as PropertyType | undefined,
                market: market as Market | undefined,
                handover: handover ? new Date(handover) : undefined,
                rent,
                emi,
                payment_frequency: payment_frequency as RentFrequency | undefined,
                rental_agreement,
                offplan_agreement,
                payment_count,
                completion_date: completion_date ? new Date(completion_date) : undefined,
            };

            const result = await OccupantRecordService.updateOccupantRecord(recordId, occupantRecordData);

            if (result.success) {
                res.status(200).json(result);
            } else {
                res.status(404).json(result);
            }
        } catch (error) {
            console.error('Update occupant record controller error:', error);
            res.status(500).json({
                success: false,
                message: 'Internal server error',
            });
        }
    }

    /**
     * Delete an occupant record
     */
    static async deleteOccupantRecord(req: Request, res: Response): Promise<void> {
        try {
            const recordId = parseInt(req.params.id);

            if (isNaN(recordId)) {
                res.status(400).json({
                    success: false,
                    message: 'Invalid record ID',
                });
                return;
            }

            const result = await OccupantRecordService.deleteOccupantRecord(recordId);

            if (result.success) {
                res.status(200).json(result);
            } else {
                res.status(404).json(result);
            }
        } catch (error) {
            console.error('Delete occupant record controller error:', error);
            res.status(500).json({
                success: false,
                message: 'Internal server error',
            });
        }
    }

    /**
     * Get dashboard statistics
     */
    static async getDashboardStats(req: Request, res: Response): Promise<void> {
        try {
            const result = await OccupantRecordService.getDashboardStats();

            if (result.success) {
                res.status(200).json(result);
            } else {
                res.status(400).json(result);
            }
        } catch (error) {
            console.error('Get dashboard stats controller error:', error);
            res.status(500).json({
                success: false,
                message: 'Internal server error',
            });
        }
    }

    /**
     * Get occupant records for maps with filtered fields
     * Query params: property_type, search
     */
    static async getOccupantRecordsForMaps(req: Request, res: Response): Promise<void> {
        try {
            const { property_type, search } = req.query;

            const filters = {
                property_type: property_type as string | undefined,
                search: search as string | undefined,
            };

            const result = await OccupantRecordService.getOccupantRecordsForMaps(filters);

            if (result.success) {
                res.status(200).json(result);
            } else {
                res.status(400).json(result);
            }
        } catch (error) {
            console.error('Get occupant records for maps controller error:', error);
            res.status(500).json({
                success: false,
                message: 'Internal server error',
            });
        }
    }
}

