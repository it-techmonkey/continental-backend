import { Router } from 'express';
import { LeadController } from '../controllers/leadController';
import { authenticate, isAdmin } from '../middleware/authMiddleware';

const router = Router();

/**
 * @route   POST /api/leads
 * @desc    Create a new lead
 * @access  Public
 */
router.post('/', LeadController.createLead);

/**
 * @route   GET /api/leads
 * @desc    Get all leads
 * @access  Private (Admin only)
 */
router.get('/', authenticate, isAdmin, LeadController.getAllLeads);

/**
 * @route   GET /api/leads/dashboard
 * @desc    Get dashboard counts for leads
 * @access  Private (Admin only)
 */
router.get('/dashboard', authenticate, isAdmin, LeadController.getDashboardStats);

/**
 * @route   GET /api/leads/:id
 * @desc    Get a single lead by ID
 * @access  Private (Admin only)
 */
router.get('/:id', authenticate, isAdmin, LeadController.getLeadById);

/**
 * @route   PUT /api/leads/:id
 * @desc    Update a lead by ID
 * @access  Private (Admin only)
 */
router.put('/:id', authenticate, isAdmin, LeadController.updateLead);

export default router;

