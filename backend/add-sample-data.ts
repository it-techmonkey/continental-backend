import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
    console.log('🌱 Adding more sample data...');

    try {
        // Add more Rental properties
        console.log('🏠 Adding more Rental properties...');
        await prisma.occupantRecord.create({
            data: {
                name: 'Meera Patel',
                phone: '+971508888888',
                email: 'meera.patel@email.com',
                property_name: 'Dubai Marina Tower - 15B',
                developer_name: 'DMCC',
                image_url: 'https://images.unsplash.com/photo-1512917774080-9991f1c4c750',
                bedrooms: 1,
                bathrooms: 1,
                furnishing: 'fully_furnished',
                price: 120000,
                city: 'Dubai',
                location: 'Dubai Marina, Sheikh Zayed Road',
                latitude: 25.0772,
                longitude: 55.1394,
                property_views: 'Marina View',
                amenities: ['Swimming Pool', 'Gym', 'Parking', 'Balcony'],
                property_type: 'Rental',
                market: 'Primary',
                rent: 4500,
                payment_frequency: 'monthly',
                rental_agreement: '6-month lease',
                payment_count: 6,
                payments: {
                    create: [
                        {
                            rent: 4500,
                            status: 'paid',
                            payment_date: new Date('2024-03-01'),
                            payment_proof: 'receipt_mar_2024.pdf',
                            mode_of_payment: 'online',
                        },
                        {
                            rent: 4500,
                            status: 'paid',
                            payment_date: new Date('2024-04-01'),
                            payment_proof: 'receipt_apr_2024.pdf',
                            mode_of_payment: 'online',
                        },
                        {
                            rent: 4500,
                            status: 'due',
                            payment_date: new Date('2024-05-01'),
                            payment_proof: null,
                            mode_of_payment: 'online',
                        },
                    ],
                },
            },
        });

        await prisma.occupantRecord.create({
            data: {
                name: 'Rajesh Kumar',
                phone: '+971509999999',
                email: 'rajesh.kumar@email.com',
                property_name: 'Downtown Dubai Loft',
                developer_name: 'Emaar Properties',
                image_url: 'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c',
                bedrooms: 2,
                bathrooms: 2,
                furnishing: 'unfurnished',
                price: 200000,
                city: 'Dubai',
                location: 'Downtown Dubai, Burj Khalifa Area',
                latitude: 25.1972,
                longitude: 55.2794,
                property_views: 'Burj Khalifa View',
                amenities: ['Swimming Pool', 'Gym', 'Parking', 'Concierge'],
                property_type: 'Rental',
                market: 'Primary',
                rent: 12000,
                payment_frequency: 'monthly',
                rental_agreement: '12-month lease',
                payment_count: 12,
                payments: {
                    create: [
                        {
                            rent: 12000,
                            status: 'paid',
                            payment_date: new Date('2024-01-15'),
                            payment_proof: 'receipt_jan_2024.pdf',
                            mode_of_payment: 'online',
                        },
                        {
                            rent: 12000,
                            status: 'paid',
                            payment_date: new Date('2024-02-15'),
                            payment_proof: 'receipt_feb_2024.pdf',
                            mode_of_payment: 'online',
                        },
                        {
                            rent: 12000,
                            status: 'overdue',
                            payment_date: new Date('2024-03-15'),
                            payment_proof: null,
                            mode_of_payment: 'online',
                        },
                        {
                            rent: 12000,
                            status: 'due',
                            payment_date: new Date('2024-04-15'),
                            payment_proof: null,
                            mode_of_payment: 'online',
                        },
                    ],
                },
            },
        });

        // Add more Off-Plan properties
        console.log('🏗️ Adding more Off-Plan properties...');
        await prisma.occupantRecord.create({
            data: {
                name: 'Lina Al-Mansoori',
                phone: '+9715011111999',
                email: 'lina.mansoori@email.com',
                property_name: 'Emaar Beachfront - Residence 1204',
                developer_name: 'Emaar Properties',
                image_url: 'https://images.unsplash.com/photo-1600566753086-00f18fb6b3ea',
                bedrooms: 3,
                bathrooms: 3,
                furnishing: null,
                price: 4200000,
                city: 'Dubai',
                location: 'Dubai Marina, Emaar Beachfront',
                latitude: 25.0768,
                longitude: 55.1365,
                property_views: 'Sea View',
                amenities: ['Beach Access', 'Swimming Pool', 'Gym', 'Parking', 'Water Sports'],
                property_type: 'OffPlan',
                market: 'Primary',
                handover: new Date('2026-03-15'),
                completion_date: new Date('2026-02-01'),
                emi: 35000,
                offplan_agreement: '80-20 payment plan',
                payment_count: 36,
                payments: {
                    create: [
                        {
                            emi: 35000,
                            status: 'paid',
                            payment_date: new Date('2024-02-01'),
                            payment_proof: 'emi_feb_2024.pdf',
                            mode_of_payment: 'online',
                        },
                        {
                            emi: 35000,
                            status: 'paid',
                            payment_date: new Date('2024-03-01'),
                            payment_proof: 'emi_mar_2024.pdf',
                            mode_of_payment: 'online',
                        },
                        {
                            emi: 35000,
                            status: 'paid',
                            payment_date: new Date('2024-04-01'),
                            payment_proof: 'emi_apr_2024.pdf',
                            mode_of_payment: 'online',
                        },
                        {
                            emi: 35000,
                            status: 'paid',
                            payment_date: new Date('2024-05-01'),
                            payment_proof: 'emi_may_2024.pdf',
                            mode_of_payment: 'online',
                        },
                        {
                            emi: 35000,
                            status: 'paid',
                            payment_date: new Date('2024-06-01'),
                            payment_proof: 'emi_jun_2024.pdf',
                            mode_of_payment: 'online',
                        },
                        {
                            emi: 35000,
                            status: 'due',
                            payment_date: new Date('2024-07-01'),
                            payment_proof: null,
                            mode_of_payment: 'online',
                        },
                        {
                            emi: 35000,
                            status: 'due',
                            payment_date: new Date('2024-08-01'),
                            payment_proof: null,
                            mode_of_payment: 'online',
                        },
                    ],
                },
            },
        });

        await prisma.occupantRecord.create({
            data: {
                name: 'Fadi Bassam',
                phone: '+9715022222999',
                email: 'fadi.bassam@email.com',
                property_name: 'Dubai Hills Park View Villa',
                developer_name: 'Emaar Properties',
                image_url: 'https://images.unsplash.com/photo-1600585154340-be6161a56a0c',
                bedrooms: 4,
                bathrooms: 4,
                furnishing: null,
                price: 6500000,
                city: 'Dubai',
                location: 'Dubai Hills Estate',
                latitude: 25.0997,
                longitude: 55.2785,
                property_views: 'Park View, Golf Course',
                amenities: ['Golf Course', 'Swimming Pool', 'Gym', 'Parking', 'Community Center'],
                property_type: 'OffPlan',
                market: 'Primary',
                handover: new Date('2025-11-30'),
                completion_date: new Date('2025-10-15'),
                emi: 65000,
                offplan_agreement: 'Construction linked payments',
                payment_count: 24,
                payments: {
                    create: [
                        {
                            emi: 65000,
                            status: 'paid',
                            payment_date: new Date('2023-12-01'),
                            payment_proof: 'emi_dec_2023.pdf',
                            mode_of_payment: 'offline',
                        },
                        {
                            emi: 65000,
                            status: 'paid',
                            payment_date: new Date('2024-01-01'),
                            payment_proof: 'emi_jan_2024.pdf',
                            mode_of_payment: 'online',
                        },
                        {
                            emi: 65000,
                            status: 'paid',
                            payment_date: new Date('2024-02-01'),
                            payment_proof: 'emi_feb_2024.pdf',
                            mode_of_payment: 'online',
                        },
                        {
                            emi: 65000,
                            status: 'paid',
                            payment_date: new Date('2024-03-01'),
                            payment_proof: 'emi_mar_2024.pdf',
                            mode_of_payment: 'online',
                        },
                        {
                            emi: 65000,
                            status: 'paid',
                            payment_date: new Date('2024-04-01'),
                            payment_proof: 'emi_apr_2024.pdf',
                            mode_of_payment: 'online',
                        },
                        {
                            emi: 65000,
                            status: 'paid',
                            payment_date: new Date('2024-05-01'),
                            payment_proof: 'emi_may_2024.pdf',
                            mode_of_payment: 'online',
                        },
                        {
                            emi: 65000,
                            status: 'paid',
                            payment_date: new Date('2024-06-01'),
                            payment_proof: 'emi_jun_2024.pdf',
                            mode_of_payment: 'online',
                        },
                        {
                            emi: 65000,
                            status: 'overdue',
                            payment_date: new Date('2024-07-01'),
                            payment_proof: null,
                            mode_of_payment: 'online',
                        },
                        {
                            emi: 65000,
                            status: 'due',
                            payment_date: new Date('2024-08-01'),
                            payment_proof: null,
                            mode_of_payment: 'online',
                        },
                    ],
                },
            },
        });

        console.log('✅ Sample data added successfully!');
        console.log('\n📊 New Data Added:');
        console.log('   - 2 more Rental properties');
        console.log('   - 2 more Off-Plan properties');
        console.log('\n🎉 Database now has more realistic data for testing!');
    } catch (error) {
        console.error('❌ Error adding sample data:', error);
    }
}

main()
    .catch((e) => {
        console.error('❌ Error:', e);
        process.exit(1);
    })
    .finally(async () => {
        await prisma.$disconnect();
    });

