import { Request, Response, NextFunction } from 'express';

interface RateLimitStore {
    [key: string]: { count: number; resetTime: number };
}

const store: RateLimitStore = {};

/**
 * Simple in-memory rate limiter middleware
 * @param windowMs - Time window in milliseconds
 * @param maxRequests - Maximum requests per window
 * @param message - Error message when limit exceeded
 */
export const rateLimit = (
    windowMs: number = 15 * 60 * 1000, // 15 minutes
    maxRequests: number = 100,
    message: string = 'Too many requests, please try again later'
) => {
    return (req: Request, res: Response, next: NextFunction): void => {
        const key = req.ip || req.socket.remoteAddress || 'unknown';
        const now = Date.now();

        if (!store[key] || now > store[key].resetTime) {
            store[key] = { count: 1, resetTime: now + windowMs };
            next();
            return;
        }

        store[key].count++;

        if (store[key].count > maxRequests) {
            res.status(429).json({
                success: false,
                message,
            });
            return;
        }

        next();
    };
};

/**
 * Strict rate limiter for auth endpoints (login/signup)
 * 10 requests per 15 minutes per IP
 */
export const authRateLimit = rateLimit(
    15 * 60 * 1000,
    10,
    'Too many authentication attempts, please try again in 15 minutes'
);

/**
 * General API rate limiter
 * 100 requests per 15 minutes per IP
 */
export const apiRateLimit = rateLimit(
    15 * 60 * 1000,
    100,
    'Too many requests, please try again later'
);
