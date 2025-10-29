import { Router } from 'express';
import { OccupantRecordController } from '../controllers/occupantRecordController';
import { authenticate, isAdmin } from '../middleware/authMiddleware';

const router = Router();

/**
 * @route   POST /api/occupant-records
 * @desc    Create a new occupant record
 * @access  Public (can be changed to Private if needed)
 */
router.post('/', OccupantRecordController.createOccupantRecord);

/**
 * @route   GET /api/occupant-records
 * @desc    Get all occupant records
 * @access  Private (Admin only)
 */
router.get('/', authenticate, isAdmin, OccupantRecordController.getAllOccupantRecords);

/**
 * @route   GET /api/occupant-records/dashboard
 * @desc    Get dashboard statistics for occupant records
 * @access  Private (Admin only)
 */
router.get('/dashboard', authenticate, isAdmin, OccupantRecordController.getDashboardStats);

/**
 * @route   GET /api/occupant-records/maps
 * @desc    Get occupant records for maps with filtered fields
 * @access  Private (Admin only)
 */
router.get('/maps', authenticate, isAdmin, OccupantRecordController.getOccupantRecordsForMaps);

/**
 * @route   GET /api/occupant-records/:id
 * @desc    Get a single occupant record by ID
 * @access  Private (Admin only)
 */
router.get('/:id', authenticate, isAdmin, OccupantRecordController.getOccupantRecordById);

/**
 * @route   PUT /api/occupant-records/:id
 * @desc    Update an occupant record by ID
 * @access  Private (Admin only)
 */
router.put('/:id', authenticate, isAdmin, OccupantRecordController.updateOccupantRecord);

/**
 * @route   DELETE /api/occupant-records/:id
 * @desc    Delete an occupant record by ID
 * @access  Private (Admin only)
 */
router.delete('/:id', authenticate, isAdmin, OccupantRecordController.deleteOccupantRecord);

export default router;

