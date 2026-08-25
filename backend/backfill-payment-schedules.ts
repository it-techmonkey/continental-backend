import { PrismaClient } from '@prisma/client';
import { buildScheduleRows, resolveScheduleConfig } from './src/services/paymentScheduleService';

/**
 * One-off repair for properties that were created while the payment-schedule generator was
 * gated on `payment_frequency` being present. Off-Plan properties (and rentals saved without
 * a rent) ended up with an empty Payment Timeline.
 *
 * Only properties with ZERO payments are touched - a property whose installments were
 * deliberately deleted by an admin must not be resurrected.
 *
 *   npm run db:backfill-schedules -- --dry-run
 *   npm run db:backfill-schedules
 */

const prisma = new PrismaClient();
const dryRun = process.argv.includes('--dry-run');

async function main() {
    console.log(dryRun ? '🔍 Backfilling payment schedules (DRY RUN)...' : '🛠️  Backfilling payment schedules...');

    const records = await prisma.occupantRecord.findMany({
        where: { payments: { none: {} } },
        orderBy: { id: 'asc' },
    });

    if (records.length === 0) {
        console.log('✅ No properties with an empty payment timeline. Nothing to do.');
        return;
    }

    console.log(`Found ${records.length} propert${records.length === 1 ? 'y' : 'ies'} with no payments.\n`);

    let repaired = 0;
    let skipped = 0;

    for (const record of records) {
        const { frequency, count } = resolveScheduleConfig(record);
        const rows = buildScheduleRows({ ...record, payment_frequency: frequency, payment_count: count });

        const label = `#${record.id} ${record.property_name} (${record.property_type})`;

        if (rows.length === 0) {
            console.log(`⏭️  ${label}: resolved count is ${count}, nothing to generate`);
            skipped++;
            continue;
        }

        console.log(`${dryRun ? '📋' : '✅'} ${label}: ${rows.length} × ${frequency} installment(s)`);

        if (!dryRun) {
            await prisma.$transaction(async (tx) => {
                await tx.occupantRecord.update({
                    where: { id: record.id },
                    data: { payment_frequency: frequency, payment_count: count },
                });
                await tx.payments.createMany({ data: rows });
            });
        }

        repaired++;
    }

    console.log(
        `\n${dryRun ? 'Would repair' : 'Repaired'} ${repaired} propert${repaired === 1 ? 'y' : 'ies'}` +
            (skipped > 0 ? `, skipped ${skipped}.` : '.'),
    );
    if (dryRun) console.log('Re-run without --dry-run to apply.');
}

main()
    .catch((error) => {
        console.error('❌ Backfill failed:', error);
        process.exitCode = 1;
    })
    .finally(async () => {
        await prisma.$disconnect();
    });
