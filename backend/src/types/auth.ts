export interface SignupRequest {
    email: string;
    password: string;
    name?: string;
    role?: 'USER' | 'ADMIN';
}

export interface LoginRequest {
    email: string;
    password: string;
}

export interface AuthResponse {
    success: boolean;
    message: string;
    data?: {
        user: {
            id: number;
            email: string;
            name: string | null;
            role: string;
        };
        token: string;
    };
}

export interface JWTPayload {
    userId: number;
    email: string;
    role: string;
}

