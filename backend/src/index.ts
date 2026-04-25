import express, { Request, Response, NextFunction } from 'express';
import cors from 'cors';
import helmet from 'helmet';
import dotenv from 'dotenv';
import { prisma } from './lib/prisma';
import authRoutes from './routes/authRoutes';
import leadRoutes from './routes/leadRoutes';
import occupantRecordRoutes from './routes/occupantRecordRoutes';
import paymentRoutes from './routes/paymentRoutes';
import uploadRoutes from './routes/uploadRoutes';

// Load environment variables
dotenv.config();

const app = express();
const PORT = process.env.PORT || 3500;

// Middleware
app.use(helmet());
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Health check endpoint
app.get('/health', async (req: Request, res: Response) => {
    try {
        // Check database connection
        await prisma.$queryRaw`SELECT 1`;

        res.status(200).json({
            status: 'OK',
            message: 'Server is running',
            database: 'Connected',
            timestamp: new Date().toISOString(),
            uptime: process.uptime()
        });
    } catch (error) {
        const errorMessage = error instanceof Error ? error.message : String(error);
        res.status(503).json({
            status: 'ERROR',
            message: 'Server is running but database is not connected',
            database: 'Disconnected',
            error: process.env.NODE_ENV === 'production' ? undefined : errorMessage,
            timestamp: new Date().toISOString(),
            uptime: process.uptime()
        });
    }
});

// API routes
app.get('/api', (req: Request, res: Response) => {
    res.json({
        message: 'Welcome to Continental Backend API',
        version: '1.0.0',
        endpoints: {
            health: '/health',
            api: '/api',
            auth: {
                signup: '/api/auth/signup',
                login: '/api/auth/login',
                profile: '/api/auth/profile'
            },
            leads: {
                create: '/api/leads (POST)',
                getAll: '/api/leads (GET) - Admin only',
                getById: '/api/leads/:id (GET) - Admin only',
                update: '/api/leads/:id (PUT) - Admin only'
            },
            occupantRecords: {
                create: '/api/occupant-records (POST)',
                getAll: '/api/occupant-records (GET) - Admin only',
                getById: '/api/occupant-records/:id (GET) - Admin only',
                update: '/api/occupant-records/:id (PUT) - Admin only',
                delete: '/api/occupant-records/:id (DELETE) - Admin only'
            },
            payments: {
                create: '/api/payments (POST) - Admin only',
                getAll: '/api/payments (GET) - Admin only',
                getById: '/api/payments/:id (GET) - Admin only',
                update: '/api/payments/:id (PUT) - Admin only',
                delete: '/api/payments/:id (DELETE) - Admin only'
            }
        }
    });
});

// Authentication routes
app.use('/api/auth', authRoutes);

// Lead routes
app.use('/api/leads', leadRoutes);

// Occupant Record routes
app.use('/api/occupant-records', occupantRecordRoutes);

// Payment routes
app.use('/api/payments', paymentRoutes);

// Upload routes
app.use('/api/upload', uploadRoutes);

// Error handling middleware
app.use((err: Error, req: Request, res: Response, next: NextFunction) => {
    console.error(err.stack);
    res.status(500).json({
        error: 'Something went wrong!',
        message: process.env.NODE_ENV === 'development' ? err.message : 'Internal server error'
    });
});

// 404 handler
app.use('*', (req: Request, res: Response) => {
    res.status(404).json({
        error: 'Route not found',
        message: `Cannot ${req.method} ${req.originalUrl}`
    });
});

// Start server
const server = app.listen(PORT, () => {
    console.log(`🚀 Server is running on port ${PORT}`);
    // console.log(`📊 Health check: http://localhost:${PORT}/health`);
    // console.log(`🔗 API endpoint: http://localhost:${PORT}/api`);
});

// Graceful shutdown
process.on('SIGTERM', async () => {
    console.log('SIGTERM received, shutting down gracefully');
    server.close(() => {
        console.log('Process terminated');
    });
    await prisma.$disconnect();
});

process.on('SIGINT', async () => {
    console.log('SIGINT received, shutting down gracefully');
    server.close(() => {
        console.log('Process terminated');
    });
    await prisma.$disconnect();
});

export default app;
