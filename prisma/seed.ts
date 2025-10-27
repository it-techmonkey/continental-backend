import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
    // Create sample users
    const user1 = await prisma.user.upsert({
        where: { email: 'john@example.com' },
        update: {},
        create: {
            email: 'john@example.com',
            name: 'John Doe',
        },
    });

    const user2 = await prisma.user.upsert({
        where: { email: 'jane@example.com' },
        update: {},
        create: {
            email: 'jane@example.com',
            name: 'Jane Smith',
        },
    });

    // Create sample posts
    await prisma.post.upsert({
        where: { id: 1 },
        update: {},
        create: {
            title: 'Welcome to Continental Backend',
            content: 'This is the first post created by the seed script.',
            published: true,
            authorId: user1.id,
        },
    });

    await prisma.post.upsert({
        where: { id: 2 },
        update: {},
        create: {
            title: 'Getting Started with Prisma',
            content: 'Learn how to use Prisma ORM with PostgreSQL.',
            published: true,
            authorId: user2.id,
        },
    });

    console.log('Seed data created successfully!');
}

main()
    .catch((e) => {
        console.error(e);
        process.exit(1);
    })
    .finally(async () => {
        await prisma.$disconnect();
    });
