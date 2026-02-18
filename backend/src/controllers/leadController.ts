import { Request, Response } from 'express';
import { LeadService } from '../services/leadService';
import { CreateLeadRequest } from '../types/lead';

export class LeadController {
    /**
     * Handle creating a new lead
     */
    static async createLead(req: Request, res: Response): Promise<void> {
        try {
            const { name, phone, email, propertyId, projectName, developerName, type, price, message, notes } = req.body;

            // Validate input
            if (!name || !phone) {
                res.status(400).json({
                    success: false,
                    message: 'Name and phone are required'
                });
                return;
            }

            // Validate phone format (basic check)
            if (phone.length < 6) {
                res.status(400).json({
                    success: false,
                    message: 'Invalid phone number'
                });
                return;
            }

            // Validate email format if provided
            if (email) {
                const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
                if (!emailRegex.test(email)) {
                    res.status(400).json({
                        success: false,
                        message: 'Invalid email format'
                    });
                    return;
                }
            }

            const leadData: CreateLeadRequest = {
                name,
                phone,
                email: email || undefined,
                propertyId: propertyId || undefined,
                projectName: projectName || undefined,
                developerName: developerName || undefined,
                type: type || undefined,
                price: price || undefined,
                message: message || undefined,
                notes: notes || undefined,
            };

            const result = await LeadService.createLead(leadData);

            if (result.success) {
                res.status(201).json(result);
            } else {
                res.status(400).json(result);
            }
        } catch (error) {
            console.error('Create lead controller error:', error);
            res.status(500).json({
                success: false,
                message: 'Internal server error'
            });
        }
    }

    /**
     * Get dashboard stats
     */
    static async getDashboardStats(req: Request, res: Response): Promise<void> {
        try {
            const result = await LeadService.getDashboardStats();

            if (result.success) {
                res.status(200).json(result);
            } else {
                res.status(400).json(result);
            }
        } catch (error) {
            console.error('Get dashboard stats controller error:', error);
            res.status(500).json({
                success: false,
                message: 'Internal server error'
            });
        }
    }

    /**
     * Get all leads with optional filters
     * Query params: status, type, search
     */
    static async getAllLeads(req: Request, res: Response): Promise<void> {
        try {
            const { status, type, search } = req.query;

            const filters = {
                status: status as string | undefined,
                type: type as string | undefined,
                search: search as string | undefined,
            };

            const result = await LeadService.getAllLeads(filters);

            if (result.success) {
                res.status(200).json(result);
            } else {
                res.status(400).json(result);
            }
        } catch (error) {
            console.error('Get leads controller error:', error);
            res.status(500).json({
                success: false,
                message: 'Internal server error'
            });
        }
    }

    /**
     * Get a lead by ID
     */
    static async getLeadById(req: Request, res: Response): Promise<void> {
        try {
            const leadId = parseInt(req.params.id);

            if (isNaN(leadId)) {
                res.status(400).json({
                    success: false,
                    message: 'Invalid lead ID'
                });
                return;
            }

            const result = await LeadService.getLeadById(leadId);

            if (result.success) {
                res.status(200).json(result);
            } else {
                res.status(404).json(result);
            }
        } catch (error) {
            console.error('Get lead by ID controller error:', error);
            res.status(500).json({
                success: false,
                message: 'Internal server error'
            });
        }
    }

    /**
     * Update a lead
     */
    static async updateLead(req: Request, res: Response): Promise<void> {
        try {
            const leadId = parseInt(req.params.id);

            if (isNaN(leadId)) {
                res.status(400).json({
                    success: false,
                    message: 'Invalid lead ID'
                });
                return;
            }

            const {
                name,
                phone,
                email,
                propertyId,
                projectName,
                developerName,
                type,
                price,
                message,
                notes,
                status
            } = req.body;

            // Validate email format if provided
            if (email) {
                const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
                if (!emailRegex.test(email)) {
                    res.status(400).json({
                        success: false,
                        message: 'Invalid email format'
                    });
                    return;
                }
            }

            const leadData: Partial<CreateLeadRequest> = {
                name,
                phone,
                email: email || undefined,
                propertyId: propertyId || undefined,
                projectName: projectName || undefined,
                developerName: developerName || undefined,
                type: type || undefined,
                price: price || undefined,
                message: message || undefined,
                notes: notes || undefined,
                status: status || undefined,
            };

            const result = await LeadService.updateLead(leadId, leadData);

            if (result.success) {
                res.status(200).json(result);
            } else {
                res.status(404).json(result);
            }
        } catch (error) {
            console.error('Update lead controller error:', error);
            res.status(500).json({
                success: false,
                message: 'Internal server error'
            });
        }
    }
}

