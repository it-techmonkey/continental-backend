# Continental Backend

A Node.js + TypeScript backend server built with Express.js, PostgreSQL, and Prisma ORM.

## Features

- ✅ TypeScript for type safety
- ✅ Express.js for web framework
- ✅ PostgreSQL database
- ✅ Prisma ORM for database management
- ✅ **JWT-based Authentication** 🔐
- ✅ **User & Admin Role Management** 👤
- ✅ **Secure Password Hashing** 🔒
- ✅ CORS enabled
- ✅ Helmet for security headers
- ✅ Environment variables support
- ✅ Health check endpoint with database status
- ✅ Error handling middleware
- ✅ Hot reload with tsx
- ✅ Database seeding support

## Quick Start

### 1. Install Dependencies

```bash
npm install
```

### 2. Setup Database

Make sure you have PostgreSQL installed and running. Then create a `.env` file in the root directory:

```env
# Server Configuration
PORT=3500
NODE_ENV=development

# Database Configuration
DATABASE_URL="postgresql://username:password@localhost:5432/continental_db?schema=public"

# JWT Configuration (for future use)
JWT_SECRET=your_super_secret_jwt_key_change_this_in_production
JWT_EXPIRES_IN=24h

# API Configuration
API_VERSION=v1
```

### 3. Setup Database Schema

```bash
# Generate Prisma client
npm run db:generate

# Push schema to database
npm run db:push

# (Optional) Seed the database with sample data
npm run db:seed
```

### 4. Run the Server

For development (with hot reload):
```bash
npm run dev
```

For production:
```bash
npm run build
npm start
```

## Available Scripts

- `npm run dev` - Start development server with hot reload
- `npm run build` - Build TypeScript to JavaScript
- `npm start` - Start production server
- `npm run clean` - Clean build directory
- `npm run db:generate` - Generate Prisma client
- `npm run db:push` - Push schema changes to database
- `npm run db:migrate` - Run database migrations
- `npm run db:studio` - Open Prisma Studio
- `npm run db:seed` - Seed database with sample data

## API Endpoints

### Public Endpoints
- `GET /health` - Health check endpoint
- `GET /api` - API information endpoint
- `POST /api/auth/signup` - Register a new user
- `POST /api/auth/login` - Login and get JWT token

### Protected Endpoints (Requires JWT Token)
- `GET /api/auth/profile` - Get current user profile

**For detailed authentication documentation, see [AUTHENTICATION.md](./AUTHENTICATION.md)**

## Project Structure

```
continental-backend/
├── src/
│   ├── controllers/
│   │   └── authController.ts    # Authentication controllers
│   ├── services/
│   │   └── authService.ts       # Business logic for auth
│   ├── routes/
│   │   └── authRoutes.ts        # Authentication routes
│   ├── middleware/
│   │   └── authMiddleware.ts    # JWT verification middleware
│   ├── types/
│   │   └── auth.ts              # TypeScript types
│   ├── lib/
│   │   └── prisma.ts            # Prisma client configuration
│   └── index.ts                  # Main server file
├── prisma/
│   ├── schema.prisma            # Database schema
│   └── seed.ts                  # Database seeding script
├── dist/                         # Compiled JavaScript (generated)
├── package.json
├── tsconfig.json
├── .env                          # Environment variables (create this)
├── AUTHENTICATION.md             # Authentication documentation
└── README.md
```

## Technologies Used

- **Node.js** - Runtime environment
- **TypeScript** - Programming language
- **Express.js** - Web framework
- **PostgreSQL** - Database
- **Prisma** - Database ORM
- **JWT** - JSON Web Tokens for authentication
- **bcrypt** - Password hashing
- **CORS** - Cross-origin resource sharing
- **Helmet** - Security middleware
- **dotenv** - Environment variables
- **tsx** - TypeScript execution and hot reload

## Requirements

- Node.js >= 18.0.0
- npm >= 8.0.0
- PostgreSQL >= 12.0.0

## Development

### 1) Start Postgres via Docker

We include a `docker-compose.yml` for a local Postgres and Adminer UI.

Commands:

```bash
cd backend-continental
docker compose up -d
```

This exposes Postgres on `localhost:5432` and Adminer on `http://localhost:8080`.

### 2) Configure environment

Create a `.env` file in `backend-continental/` (same folder as `package.json`) with:

```
DATABASE_URL="postgresql://postgres:postgres@localhost:5432/continental?schema=public"
JWT_SECRET="replace_with_strong_secret"
NODE_ENV=development
PORT=3500
```

If you have a hosted Postgres URL, paste it into `DATABASE_URL` instead and the app will use that.

### 3) Install deps and run migrations

```bash
npm i
npm run db:generate
npm run db:migrate
```

Optionally open Prisma Studio:

```bash
npm run db:studio
```

### 4) Start the server

For dev with hot-reload:

```bash
npm run dev
```

Build and start:

```bash
npm run build
npm start
```

The server runs on `http://localhost:3500` by default. You can change the port by setting the `PORT` environment variable.

## Deploy on Render

This repo now includes `render.yaml` in `backend/` for one-click Render Blueprint deploy.

### Option A: Blueprint deploy (recommended)

1. Push your repo to GitHub.
2. In Render, click **New +** -> **Blueprint**.
3. Select the repository and branch.
4. Render reads `backend/render.yaml` and creates:
   - a web service `continental-backend`
   - a Postgres database `continental-postgres`
5. After first deploy, open the service **Shell** and run:
   - `npx prisma migrate deploy`
   - `npm run db:seed` (optional, if you want demo users/data)

### Option B: Manual service setup

- Root Directory: `backend`
- Build Command: `npm install && npm run db:generate && npm run build`
- Start Command: `npm start`
- Health Check Path: `/health`

Set these env vars:
- `NODE_ENV=production`
- `DATABASE_URL=<Render Postgres connection string>`
- `JWT_SECRET=<strong random value>`
- `JWT_EXPIRES_IN=7d`
- `AWS_REGION`, `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_BUCKET_NAME` (if uploads are used)

### Environment files

- Copy `.env.example` to `.env` for local development:
  - `cp .env.example .env`
- Never commit real secrets in `.env`.

## Database Setup

1. Install PostgreSQL on your system
2. Create a database named `continental_db`
3. Update the `DATABASE_URL` in your `.env` file with your PostgreSQL credentials
4. Run `npm run db:generate` to generate the Prisma client
5. Run `npm run db:push` to create the database schema
6. Optionally run `npm run db:seed` to populate with sample data
