import { Request, Response } from 'express';
import { AuthService } from '../services/authService';
import { SignupRequest, LoginRequest } from '../types/auth';

export class AuthController {
    /**
     * Handle user signup
     */
    static async signup(req: Request, res: Response): Promise<void> {
        try {
            const { email, password, name, role } = req.body;

            // Validate input
            if (!email || !password) {
                res.status(400).json({
                    success: false,
                    message: 'Email and password are required'
                });
                return;
            }

            // Validate email format
            const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            if (!emailRegex.test(email)) {
                res.status(400).json({
                    success: false,
                    message: 'Invalid email format'
                });
                return;
            }

            // Validate password length
            if (password.length < 6) {
                res.status(400).json({
                    success: false,
                    message: 'Password must be at least 6 characters'
                });
                return;
            }

            const signupData: SignupRequest = {
                email,
                password,
                name: name || undefined,
                role
            };

            const result = await AuthService.signup(signupData);

            if (result.success) {
                res.status(201).json(result);
            } else {
                res.status(400).json(result);
            }
        } catch (error) {
            console.error('Signup controller error:', error);
            res.status(500).json({
                success: false,
                message: 'Internal server error'
            });
        }
    }

    /**
     * Handle user login
     */
    static async login(req: Request, res: Response): Promise<void> {
        try {
            const { email, password } = req.body;

            // Validate input
            if (!email || !password) {
                res.status(400).json({
                    success: false,
                    message: 'Email and password are required'
                });
                return;
            }

            const loginData: LoginRequest = {
                email,
                password
            };

            const result = await AuthService.login(loginData);

            if (result.success) {
                res.status(200).json(result);
            } else {
                res.status(401).json(result);
            }
        } catch (error) {
            console.error('Login controller error:', error);
            res.status(500).json({
                success: false,
                message: 'Internal server error'
            });
        }
    }

    /**
     * Get current user profile
     */
    static async getProfile(req: Request, res: Response): Promise<void> {
        try {
            const userId = req.user?.userId;

            if (!userId) {
                res.status(401).json({
                    success: false,
                    message: 'Unauthorized'
                });
                return;
            }

            const user = await AuthService.getUserById(userId);

            if (!user) {
                res.status(404).json({
                    success: false,
                    message: 'User not found'
                });
                return;
            }

            res.status(200).json({
                success: true,
                data: user
            });
        } catch (error) {
            console.error('Get profile error:', error);
            res.status(500).json({
                success: false,
                message: 'Internal server error'
            });
        }
    }

    /**
     * Update current user profile
     */
    static async updateProfile(req: Request, res: Response): Promise<void> {
        try {
            const userId = req.user?.userId;

            if (!userId) {
                res.status(401).json({
                    success: false,
                    message: 'Unauthorized'
                });
                return;
            }

            const { name, phone, profileImage } = req.body;

            const updatedUser = await AuthService.updateUserById(userId, { name, phone, profileImage });

            if (!updatedUser) {
                res.status(404).json({
                    success: false,
                    message: 'User not found'
                });
                return;
            }

            res.status(200).json({
                success: true,
                message: 'Profile updated successfully',
                data: updatedUser
            });
        } catch (error) {
            console.error('Update profile error:', error);
            res.status(500).json({
                success: false,
                message: 'Internal server error'
            });
        }
    }
}

