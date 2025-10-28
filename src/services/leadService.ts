import { prisma } from '../lib/prisma';
import { CreateLeadRequest } from '../types/lead';

export class LeadService {
    /**
     * Create a new lead
     */
    static async createLead(leadData: CreateLeadRequest) {
        try {
            const lead = await prisma.lead.create({
                data: {
                    name: leadData.name,
                    phone: leadData.phone,
                    email: leadData.email,
                    propertyId: leadData.propertyId,
                    projectName: leadData.projectName,
                    developerName: leadData.developerName,
                    type: leadData.type,
                    price: leadData.price,
                    message: leadData.message,
                    notes: leadData.notes,
                },
            });

            return {
                success: true,
                message: 'Lead created successfully',
                data: lead,
            };
        } catch (error) {
            console.error('Create lead error:', error);
            return {
                success: false,
                message: 'Failed to create lead',
            };
        }
    }

    /**
     * Get all leads
     */
    static async getAllLeads() {
        try {
            const leads = await prisma.lead.findMany({
                orderBy: {
                    createdAt: 'desc',
                },
            });

            return {
                success: true,
                message: 'Leads retrieved successfully',
                data: {
                    leads,
                    total: leads.length,
                },
            };
        } catch (error) {
            console.error('Get leads error:', error);
            return {
                success: false,
                message: 'Failed to retrieve leads',
            };
        }
    }

    /**
     * Update a lead by ID
     */
    static async updateLead(leadId: number, leadData: Partial<CreateLeadRequest>) {
        try {
            // Check if lead exists
            const existingLead = await prisma.lead.findUnique({
                where: { id: leadId }
            });

            if (!existingLead) {
                return {
                    success: false,
                    message: 'Lead not found'
                };
            }

            // Update lead
            const lead = await prisma.lead.update({
                where: { id: leadId },
                data: {
                    name: leadData.name,
                    phone: leadData.phone,
                    email: leadData.email,
                    propertyId: leadData.propertyId,
                    projectName: leadData.projectName,
                    developerName: leadData.developerName,
                    type: leadData.type,
                    price: leadData.price,
                    message: leadData.message,
                    notes: leadData.notes,
                    status: leadData.status,
                },
            });

            return {
                success: true,
                message: 'Lead updated successfully',
                data: lead,
            };
        } catch (error) {
            console.error('Update lead error:', error);
            return {
                success: false,
                message: 'Failed to update lead',
            };
        }
    }

    /**
     * Get a single lead by ID
     */
    static async getLeadById(leadId: number) {
        try {
            const lead = await prisma.lead.findUnique({
                where: { id: leadId }
            });

            if (!lead) {
                return {
                    success: false,
                    message: 'Lead not found'
                };
            }

            return {
                success: true,
                message: 'Lead retrieved successfully',
                data: lead,
            };
        } catch (error) {
            console.error('Get lead by ID error:', error);
            return {
                success: false,
                message: 'Failed to retrieve lead',
            };
        }
    }
}
