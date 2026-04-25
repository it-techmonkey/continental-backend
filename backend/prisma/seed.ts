import { PrismaClient } from '@prisma/client';
import bcrypt from 'bcryptjs';

const prisma = new PrismaClient();

async function main() {
    console.log('🌱 Starting seed process...');

    // Clear existing data (optional - commented out to preserve existing data)
    // await prisma.payments.deleteMany();
    // await prisma.occupantRecord.deleteMany();
    // await prisma.lead.deleteMany();
    // await prisma.user.deleteMany();

    // Create Admin Users
    console.log('👤 Creating users...');
    await prisma.user.upsert({
        where: { email: 'admin@continental.com' },
        update: {},
        create: {
            email: 'admin@continental.com',
            name: 'Ahmed Al-Mansouri',
            password: await bcrypt.hash('admin123', 10),
            role: 'ADMIN',
        },
        select: { id: true },
    });

    await prisma.user.upsert({
        where: { email: 'sarah.manager@continental.com' },
        update: {},
        create: {
            email: 'sarah.manager@continental.com',
            name: 'Sarah Hassan',
            password: await bcrypt.hash('manager123', 10),
            role: 'ADMIN',
        },
        select: { id: true },
    });

    await prisma.user.upsert({
        where: { email: 'mohammed.ali@example.com' },
        update: {},
        create: {
            email: 'mohammed.ali@example.com',
            name: 'Mohammed Ali',
            password: await bcrypt.hash('user123', 10),
            role: 'USER',
        },
        select: { id: true },
    });

    console.log('✅ Users created');

    // Create Leads
    console.log('📋 Creating leads...');
    const leads = [
        {
            name: 'Fatima Al-Zahra',
            phone: '+971501234567',
            email: 'fatima.alzahra@email.com',
            propertyId: 'PROP-001',
            projectName: 'Dubai Marina Residences',
            developerName: 'Emaar Properties',
            type: 'Apartment',
            price: 2500000,
            status: 'ACTIVE' as const,
            message: 'Interested in 2-bedroom apartment with sea view',
            notes: 'Follow-up scheduled for next week',
        },
        {
            name: 'Khalid Bin Rashid',
            phone: '+971502345678',
            email: 'khalid.rashid@email.com',
            propertyId: 'PROP-002',
            projectName: 'Palm Jumeirah Villa',
            developerName: 'Nakheel',
            type: 'Villa',
            price: 8500000,
            status: 'ACTIVE' as const,
            message: 'Looking for waterfront villa',
            notes: 'Budget approved, ready to proceed',
        },
        {
            name: 'Layla Ahmed',
            phone: '+971503456789',
            email: 'layla.ahmed@email.com',
            propertyId: 'PROP-003',
            projectName: 'Business Bay Towers',
            developerName: 'Dubai Properties',
            type: 'Penthouse',
            price: 12000000,
            status: 'DUE' as const,
            message: 'Need information on payment plans',
            notes: 'Awaiting document verification',
        },
        {
            name: 'Omar Al-Mazrouei',
            phone: '+971504567890',
            email: null,
            propertyId: 'PROP-004',
            projectName: 'Jumeirah Heights',
            developerName: 'Meraas',
            type: 'Studio',
            price: 980000,
            status: 'LOST' as const,
            message: null,
            notes: 'Customer found alternative property',
        },
    ];

    for (const lead of leads) {
        await prisma.lead.create({ data: lead });
    }
    console.log('✅ Leads created');

    // Create Rental Occupant Records
    console.log('🏠 Creating Rental Occupant Records...');
    const rentalRecords = [
        {
            name: 'Hassan Ibrahim',
            phone: '+971501111111',
            email: 'hassan.ibrahim@email.com',
            property_name: 'Downtown Dubai Apartment - Unit 301',
            developer_name: 'Emaar Properties',
            image_url: 'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00',
            bedrooms: 2,
            bathrooms: 2,
            furnishing: 'fully_furnished' as const,
            price: 180000,
            city: 'Dubai',
            location: 'Downtown Dubai, Sheikh Mohammed Bin Rashid Blvd',
            latitude: 25.1972,
            longitude: 55.2794,
            property_views: 'Burj Khalifa View',
            amenities: ['Swimming Pool', 'Gym', 'Parking', 'Security', 'Balcony'],
            property_type: 'Rental' as const,
            market: 'Primary' as const,
            rent: 8500.00,
            payment_frequency: 'monthly' as const,
            rental_agreement: '12-month lease agreement signed',
            payment_count: 3,
            payments: {
                create: [
                    {
                        rent: 8500,
                        status: 'paid' as const,
                        payment_date: new Date('2024-01-15'),
                        payment_proof: 'receipt_jan_2024.pdf',
                        mode_of_payment: 'online' as const,
                    },
                    {
                        rent: 8500,
                        status: 'paid' as const,
                        payment_date: new Date('2024-02-15'),
                        payment_proof: 'receipt_feb_2024.pdf',
                        mode_of_payment: 'online' as const,
                    },
                    {
                        rent: 8500,
                        status: 'due' as const,
                        payment_date: null,
                        payment_proof: null,
                        mode_of_payment: 'online' as const,
                    },
                ],
            },
        },
        {
            name: 'Aisha Mohammed',
            phone: '+971502222222',
            email: 'aisha.mohammed@email.com',
            property_name: 'JBR Beachfront Villa',
            developer_name: 'Dubai Properties',
            image_url: 'https://images.unsplash.com/photo-1613490493576-7fde63acd811',
            bedrooms: 4,
            bathrooms: 4,
            furnishing: 'partially_furnished' as const,
            price: 320000,
            city: 'Dubai',
            location: 'Jumeirah Beach Residence, The Walk',
            latitude: 25.0768,
            longitude: 55.1365,
            property_views: 'Sea View, Beach Access',
            amenities: ['Private Beach', 'Swimming Pool', 'Gym', 'Parking', 'Garden', 'Maid Room'],
            property_type: 'Rental' as const,
            market: 'Secondary' as const,
            rent: 28000.00,
            payment_frequency: 'quarterly' as const,
            rental_agreement: '24-month lease with renewable option',
            payment_count: 4,
            payments: {
                create: [
                    {
                        rent: 84000,
                        status: 'paid' as const,
                        payment_date: new Date('2024-02-01'),
                        payment_proof: 'receipt_q1_2024.pdf',
                        mode_of_payment: 'cash' as const,
                    },
                    {
                        rent: 84000,
                        status: 'paid' as const,
                        payment_date: new Date('2024-05-01'),
                        payment_proof: 'receipt_q2_2024.pdf',
                        mode_of_payment: 'cash' as const,
                    },
                    {
                        rent: 84000,
                        status: 'overdue' as const,
                        payment_date: null,
                        payment_proof: null,
                        mode_of_payment: 'online' as const,
                    },
                    {
                        rent: 84000,
                        status: 'due' as const,
                        payment_date: null,
                        payment_proof: null,
                        mode_of_payment: 'online' as const,
                    },
                ],
            },
        },
        {
            name: 'Youssef Al-Zaabi',
            phone: '+971503333333',
            email: 'youssef.zaabi@email.com',
            property_name: 'Business Bay Studio',
            developer_name: 'DAMAC Properties',
            image_url: 'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267',
            bedrooms: 0,
            bathrooms: 1,
            furnishing: 'unfurnished' as const,
            price: 55000,
            city: 'Dubai',
            location: 'Business Bay, Al Khaleej Street',
            latitude: 25.1869,
            longitude: 55.2649,
            property_views: 'City View',
            amenities: ['Gym', 'Parking', 'Reception', 'Elevator'],
            property_type: 'Rental' as const,
            market: 'Primary' as const,
            rent: 4500.00,
            payment_frequency: 'monthly' as const,
            rental_agreement: '6-month contract',
            payment_count: 2,
            payments: {
                create: [
                    {
                        rent: 4500,
                        status: 'paid' as const,
                        payment_date: new Date('2024-03-10'),
                        payment_proof: 'receipt_mar_2024.pdf',
                        mode_of_payment: 'online' as const,
                    },
                    {
                        rent: 4500,
                        status: 'due' as const,
                        payment_date: null,
                        payment_proof: null,
                        mode_of_payment: 'online' as const,
                    },
                ],
            },
        },
    ];

    for (const record of rentalRecords) {
        await prisma.occupantRecord.create({
            data: record,
        });
    }
    console.log('✅ Rental Occupant Records created');

    // Create OffPlan Occupant Records
    console.log('🏗️ Creating OffPlan Occupant Records...');
    const offplanRecords = [
        {
            name: 'Majed Al-Otaiba',
            phone: '+971504444444',
            email: 'majed.otaiba@email.com',
            property_name: 'Palm Jumeirah OffPlan Villa - Phase 2',
            developer_name: 'Nakheel',
            image_url: 'https://images.unsplash.com/photo-1600585154340-be6161a56a0c',
            bedrooms: 5,
            bathrooms: 5,
            furnishing: null,
            price: 12500000,
            city: 'Dubai',
            location: 'Palm Jumeirah, Frond K',
            latitude: 25.1123,
            longitude: 55.1392,
            property_views: 'Ocean View, Private Beach',
            amenities: ['Private Beach', 'Swimming Pool', 'Gym', 'Parking', 'Garden', 'Dock', 'Water Sports'],
            property_type: 'OffPlan' as const,
            market: 'Primary' as const,
            handover: new Date('2025-12-31'),
            completion_date: new Date('2025-10-15'),
            emi: 52000,
            offplan_agreement: 'Off-plan purchase agreement with 70% loan approved',
            payment_count: 12,
            payments: {
                create: [
                    {
                        emi: 52000,
                        status: 'paid' as const,
                        payment_date: new Date('2024-01-05'),
                        payment_proof: 'emi_jan_2024.pdf',
                        mode_of_payment: 'online' as const,
                    },
                    {
                        emi: 52000,
                        status: 'paid' as const,
                        payment_date: new Date('2024-02-05'),
                        payment_proof: 'emi_feb_2024.pdf',
                        mode_of_payment: 'online' as const,
                    },
                    {
                        emi: 52000,
                        status: 'paid' as const,
                        payment_date: new Date('2024-03-05'),
                        payment_proof: 'emi_mar_2024.pdf',
                        mode_of_payment: 'online' as const,
                    },
                    {
                        emi: 52000,
                        status: 'paid' as const,
                        payment_date: new Date('2024-04-05'),
                        payment_proof: 'emi_apr_2024.pdf',
                        mode_of_payment: 'online' as const,
                    },
                    {
                        emi: 52000,
                        status: 'paid' as const,
                        payment_date: new Date('2024-05-05'),
                        payment_proof: 'emi_may_2024.pdf',
                        mode_of_payment: 'online' as const,
                    },
                    {
                        emi: 52000,
                        status: 'due' as const,
                        payment_date: null,
                        payment_proof: null,
                        mode_of_payment: 'online' as const,
                    },
                ],
            },
        },
        {
            name: 'Noura Al-Dhaheri',
            phone: '+971505555555',
            email: 'noura.dhaheri@email.com',
            property_name: 'Dubai Creek Harbour - The Residences',
            developer_name: 'Emaar Properties',
            image_url: 'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9',
            bedrooms: 3,
            bathrooms: 3,
            furnishing: null,
            price: 3200000,
            city: 'Dubai',
            location: 'Dubai Creek Harbour, Ras Al Khor',
            latitude: 25.2048,
            longitude: 55.3342,
            property_views: 'Creek View, Dubai Skyline',
            amenities: ['Swimming Pool', 'Gym', 'Parking', 'Garden', 'Children Play Area', 'Retail'],
            property_type: 'OffPlan' as const,
            market: 'Primary' as const,
            handover: new Date('2026-06-30'),
            completion_date: new Date('2026-04-30'),
            emi: 18500,
            offplan_agreement: 'Installment plan: 80% construction linked, 20% on completion',
            payment_count: 24,
            payments: {
                create: [
                    {
                        emi: 18500,
                        status: 'paid' as const,
                        payment_date: new Date('2024-02-15'),
                        payment_proof: 'emi_feb_2024.pdf',
                        mode_of_payment: 'online' as const,
                    },
                    {
                        emi: 18500,
                        status: 'paid' as const,
                        payment_date: new Date('2024-03-15'),
                        payment_proof: 'emi_mar_2024.pdf',
                        mode_of_payment: 'online' as const,
                    },
                    {
                        emi: 18500,
                        status: 'paid' as const,
                        payment_date: new Date('2024-04-15'),
                        payment_proof: 'emi_apr_2024.pdf',
                        mode_of_payment: 'cash' as const,
                    },
                    {
                        emi: 18500,
                        status: 'paid' as const,
                        payment_date: new Date('2024-05-15'),
                        payment_proof: 'emi_may_2024.pdf',
                        mode_of_payment: 'online' as const,
                    },
                    {
                        emi: 18500,
                        status: 'overdue' as const,
                        payment_date: null,
                        payment_proof: null,
                        mode_of_payment: 'online' as const,
                    },
                    {
                        emi: 18500,
                        status: 'due' as const,
                        payment_date: null,
                        payment_proof: null,
                        mode_of_payment: 'online' as const,
                    },
                ],
            },
        },
        {
            name: 'Sultan Al-Mazrouei',
            phone: '+971506666666',
            email: 'sultan.mazrouei@email.com',
            property_name: 'Dubai Hills Estate - Villa Cluster',
            developer_name: 'Emaar Properties',
            image_url: 'https://images.unsplash.com/photo-1600566753190-17f0baa2a6c3',
            bedrooms: 6,
            bathrooms: 6,
            furnishing: null,
            price: 9800000,
            city: 'Dubai',
            location: 'Dubai Hills Estate, Al Khail Road',
            latitude: 25.0997,
            longitude: 55.2785,
            property_views: 'Golf Course View, Park View',
            amenities: ['Golf Course', 'Swimming Pool', 'Gym', 'Parking', 'Garden', 'BBQ Area', 'Community Center'],
            property_type: 'OffPlan' as const,
            market: 'Primary' as const,
            handover: new Date('2025-09-15'),
            completion_date: new Date('2025-08-01'),
            emi: 42000,
            offplan_agreement: 'Construction milestone payment plan - 25% down, 75% on installments',
            payment_count: 18,
            payments: {
                create: [
                    {
                        emi: 42000,
                        status: 'paid' as const,
                        payment_date: new Date('2023-12-10'),
                        payment_proof: 'emi_dec_2023.pdf',
                        mode_of_payment: 'cash' as const,
                    },
                    {
                        emi: 42000,
                        status: 'paid' as const,
                        payment_date: new Date('2024-01-10'),
                        payment_proof: 'emi_jan_2024.pdf',
                        mode_of_payment: 'online' as const,
                    },
                    {
                        emi: 42000,
                        status: 'paid' as const,
                        payment_date: new Date('2024-02-10'),
                        payment_proof: 'emi_feb_2024.pdf',
                        mode_of_payment: 'online' as const,
                    },
                    {
                        emi: 42000,
                        status: 'paid' as const,
                        payment_date: new Date('2024-03-10'),
                        payment_proof: 'emi_mar_2024.pdf',
                        mode_of_payment: 'online' as const,
                    },
                    {
                        emi: 42000,
                        status: 'paid' as const,
                        payment_date: new Date('2024-04-10'),
                        payment_proof: 'emi_apr_2024.pdf',
                        mode_of_payment: 'cash' as const,
                    },
                    {
                        emi: 42000,
                        status: 'paid' as const,
                        payment_date: new Date('2024-05-10'),
                        payment_proof: 'emi_may_2024.pdf',
                        mode_of_payment: 'online' as const,
                    },
                    {
                        emi: 42000,
                        status: 'paid' as const,
                        payment_date: new Date('2024-06-10'),
                        payment_proof: 'emi_jun_2024.pdf',
                        mode_of_payment: 'online' as const,
                    },
                    {
                        emi: 42000,
                        status: 'due' as const,
                        payment_date: null,
                        payment_proof: null,
                        mode_of_payment: 'online' as const,
                    },
                ],
            },
        },
        {
            name: 'Fahad Al-Suwaidi',
            phone: '+971507777777',
            email: 'fahad.suwaidi@email.com',
            property_name: 'Al Barari Second Home',
            developer_name: 'Al Barari',
            image_url: 'https://images.unsplash.com/photo-1600585154084-4e5fe7c39198',
            bedrooms: 4,
            bathrooms: 4,
            furnishing: null,
            price: 6500000,
            city: 'Dubai',
            location: 'Al Barari, Al Khail Road',
            latitude: 25.0658,
            longitude: 55.3033,
            property_views: 'Garden View, Lake View',
            amenities: ['Swimming Pool', 'Gym', 'Parking', 'Garden', 'BBQ Area', 'Nature Trails'],
            property_type: 'OffPlan' as const,
            market: 'Secondary' as const,
            handover: new Date('2026-03-31'),
            completion_date: new Date('2026-02-15'),
            emi: 28000,
            offplan_agreement: 'Flexible payment plan available - early bird discount applied',
            payment_count: 30,
            payments: {
                create: [
                    {
                        emi: 28000,
                        status: 'paid' as const,
                        payment_date: new Date('2024-03-20'),
                        payment_proof: 'emi_mar_2024.pdf',
                        mode_of_payment: 'online' as const,
                    },
                    {
                        emi: 28000,
                        status: 'paid' as const,
                        payment_date: new Date('2024-04-20'),
                        payment_proof: 'emi_apr_2024.pdf',
                        mode_of_payment: 'online' as const,
                    },
                    {
                        emi: 28000,
                        status: 'paid' as const,
                        payment_date: new Date('2024-05-20'),
                        payment_proof: 'emi_may_2024.pdf',
                        mode_of_payment: 'online' as const,
                    },
                    {
                        emi: 28000,
                        status: 'due' as const,
                        payment_date: null,
                        payment_proof: null,
                        mode_of_payment: 'online' as const,
                    },
                ],
            },
        },
    ];

    for (const record of offplanRecords) {
        await prisma.occupantRecord.create({
            data: record,
        });
    }
    console.log('✅ OffPlan Occupant Records created');

    console.log('\n✨ Seed completed successfully!');
    console.log('\n📊 Summary:');
    console.log(`   - Users: 3 (2 Admin, 1 User)`);
    console.log(`   - Leads: ${leads.length}`);
    console.log(`   - Rental Occupant Records: ${rentalRecords.length}`);
    console.log(`   - OffPlan Occupant Records: ${offplanRecords.length}`);
    console.log('\n🔑 Login Credentials:');
    console.log('   Admin: admin@continental.com / admin123');
    console.log('   Manager: sarah.manager@continental.com / manager123');
    console.log('   User: mohammed.ali@example.com / user123');
}

main()
    .catch((e) => {
        console.error('❌ Error during seeding:', e);
        process.exit(1);
    })
    .finally(async () => {
        await prisma.$disconnect();
    });
