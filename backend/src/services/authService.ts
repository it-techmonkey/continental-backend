import { prisma } from '../lib/prisma';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { SignupRequest, LoginRequest, AuthResponse, JWTPayload } from '../types/auth';
import { Role } from '@prisma/client';

const JWT_SECRET = process.env.JWT_SECRET || 'your-secret-key-change-this';
const JWT_EXPIRES_IN = process.env.JWT_EXPIRES_IN || '7d';

// Type assertion for JWT options
interface JwtOptions {
    expiresIn?: string | number;
}

export class AuthService {
    /**
     * Sign up a new user
     */
    static async signup(userData: SignupRequest): Promise<AuthResponse> {
        try {
            const email = userData.email.trim().toLowerCase();
            const { password, name, role } = userData;

            // Check if user already exists
            const existingUser = await prisma.user.findUnique({
                where: { email },
                select: {
                    id: true,
                    email: true,
                    name: true,
                    password: true,
                    role: true,
                }
            });

            if (existingUser) {
                return {
                    success: false,
                    message: 'User with this email already exists'
                };
            }

            // Hash password
            const hashedPassword = await bcrypt.hash(password, 10);

            // Create user
            const user = await prisma.user.create({
                data: {
                    email,
                    password: hashedPassword,
                    name,
                    role: role?.toUpperCase() as Role || 'USER'
                },
                select: {
                    id: true,
                    email: true,
                    name: true,
                    role: true,
                }
            });

            // Generate token
            const token = this.generateToken({
                userId: user.id,
                email: user.email,
                role: user.role
            });

            return {
                success: true,
                message: 'User created successfully',
                data: {
                    user: {
                        id: user.id,
                        email: user.email,
                        name: user.name,
                        role: user.role
                    },
                    token
                }
            };
        } catch (error) {
            console.error('Signup error:', error);
            const dbUnavailable = error instanceof Error &&
                ((error as any).code === 'P1001' || (error as any).code === 'P1002');
            return {
                success: false,
                message: dbUnavailable ? 'Database unavailable' : 'Failed to create user'
            };
        }
    }

    /**
     * Login user
     */
    static async login(loginData: LoginRequest): Promise<AuthResponse> {
        try {
            const email = loginData.email.trim().toLowerCase();
            const { password } = loginData;

            // Find user
            const user = await prisma.user.findUnique({
                where: { email },
                select: {
                    id: true,
                    email: true,
                    name: true,
                    password: true,
                    role: true,
                }
            });

            if (!user) {
                return {
                    success: false,
                    message: 'Invalid email or password'
                };
            }

            // Verify password
            const isPasswordValid = await bcrypt.compare(password, user.password);

            if (!isPasswordValid) {
                return {
                    success: false,
                    message: 'Invalid email or password'
                };
            }

            // Generate token
            const token = this.generateToken({
                userId: user.id,
                email: user.email,
                role: user.role
            });

            return {
                success: true,
                message: 'Login successful',
                data: {
                    user: {
                        id: user.id,
                        email: user.email,
                        name: user.name,
                        role: user.role
                    },
                    token
                }
            };
        } catch (error) {
            console.error('Login error:', error);
            const dbUnavailable = error instanceof Error &&
                ((error as any).code === 'P1001' || (error as any).code === 'P1002');
            return {
                success: false,
                message: dbUnavailable ? 'Database unavailable' : 'Failed to login'
            };
        }
    }

    /**
     * Generate JWT token
     */
    private static generateToken(payload: JWTPayload): string {
        const expiresIn: string | number = JWT_EXPIRES_IN || '7d';
        return jwt.sign(payload, JWT_SECRET, { expiresIn } as any);
    }

    /**
     * Verify JWT token
     */
    static verifyToken(token: string): JWTPayload | null {
        try {
            return jwt.verify(token, JWT_SECRET) as JWTPayload;
        } catch (error) {
            return null;
        }
    }

    /**
     * Get user by ID
     */
    static async getUserById(userId: number) {
        return await prisma.user.findUnique({
            where: { id: userId },
            select: {
                id: true,
                email: true,
                name: true,
                phone: true,
                role: true,
                profileImage: true,
                createdAt: true
            }
        });
    }

    /**
     * Update user by ID
     */
    static async updateUserById(userId: number, data: { name?: string; phone?: string; profileImage?: string }) {
        return await prisma.user.update({
            where: { id: userId },
            data: {
                ...(data.name !== undefined && { name: data.name }),
                ...(data.phone !== undefined && { phone: data.phone }),
                ...(data.profileImage !== undefined && { profileImage: data.profileImage }),
            },
            select: {
                id: true,
                email: true,
                name: true,
                phone: true,
                role: true,
                profileImage: true,
                createdAt: true
            }
        });
    }
}

