# Continental Backend

A Node.js + TypeScript backend server built with Express.js, PostgreSQL, and Prisma ORM.

## Features

- ✅ TypeScript for type safety
- ✅ Express.js for web framework
- ✅ PostgreSQL database
- ✅ Prisma ORM for database management
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

- `GET /health` - Health check endpoint
- `GET /api` - API information endpoint

## Project Structure

```
continental-backend/
├── src/
│   ├── lib/
│   │   └── prisma.ts     # Prisma client configuration
│   └── index.ts          # Main server file
├── prisma/
│   ├── schema.prisma     # Database schema
│   └── seed.ts           # Database seeding script
├── dist/                 # Compiled JavaScript (generated)
├── package.json
├── tsconfig.json
├── .env                  # Environment variables (create this)
└── README.md
```

## Technologies Used

- **Node.js** - Runtime environment
- **TypeScript** - Programming language
- **Express.js** - Web framework
- **PostgreSQL** - Database
- **Prisma** - Database ORM
- **CORS** - Cross-origin resource sharing
- **Helmet** - Security middleware
- **dotenv** - Environment variables
- **tsx** - TypeScript execution and hot reload

## Requirements

- Node.js >= 18.0.0
- npm >= 8.0.0
- PostgreSQL >= 12.0.0

## Development

The server runs on `http://localhost:3500` by default. You can change the port by setting the `PORT` environment variable.

## Database Setup

1. Install PostgreSQL on your system
2. Create a database named `continental_db`
3. Update the `DATABASE_URL` in your `.env` file with your PostgreSQL credentials
4. Run `npm run db:generate` to generate the Prisma client
5. Run `npm run db:push` to create the database schema
6. Optionally run `npm run db:seed` to populate with sample data
