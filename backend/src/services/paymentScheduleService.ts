import { Prisma, PropertyType, RentFrequency } from '@prisma/client';

/**
 * Shared payment-schedule (a.k.a. "payment timeline") maths.
 *
 * Used by occupant record create, occupant record update (reconciliation) and the
 * one-off backfill script, so the three paths can never drift apart.
 */

export const DEFAULT_FREQUENCY: RentFrequency = 'monthly';
export const DEFAULT_PAYMENT_COUNT = 12;

/** How many months apart two consecutive installments are. */
export function intervalMonthsFor(frequency: RentFrequency | null | undefined): number {
    switch (frequency ?? DEFAULT_FREQUENCY) {
        case 'quarterly':
            return 3;
        case 'yearly':
            return 12;
        case 'monthly':
        default:
            return 1;
    }
}

export interface ScheduleConfigInput {
    property_type?: PropertyType | null;
    payment_frequency?: RentFrequency | null;
    payment_count?: number | null;
    completion_date?: Date | null;
    handover?: Date | null;
}

export interface ScheduleConfig {
    frequency: RentFrequency;
    count: number;
}

/**
 * Work out the schedule config for a property.
 *
 * The frequency always resolves to a concrete value - it is deliberately NOT gated on an
 * amount being present. The Off-Plan form never sends a frequency (or an emi), and gating
 * on that is what left every new Off-Plan property with an empty timeline.
 */
export function resolveScheduleConfig(data: ScheduleConfigInput): ScheduleConfig {
    const frequency = data.payment_frequency ?? DEFAULT_FREQUENCY;

    // An explicit count is always honoured, including 0 - that is how a vacant property is
    // marked (see the vacant_properties tally in getDashboardStats).
    const requested = data.payment_count;
    if (requested != null && Number.isFinite(requested) && requested >= 0) {
        return { frequency, count: Math.floor(requested) };
    }

    // Off-Plan: derive the count from how far out completion/handover is.
    const isOffPlan = (data.property_type ?? 'Rental') === 'OffPlan';
    const target = data.completion_date ?? data.handover ?? null;
    if (isOffPlan && target && !Number.isNaN(new Date(target).getTime())) {
        const now = new Date();
        const completion = new Date(target);
        const months =
            (completion.getFullYear() - now.getFullYear()) * 12 +
            (completion.getMonth() - now.getMonth());
        const interval = intervalMonthsFor(frequency);
        return { frequency, count: Math.max(1, Math.ceil((months > 0 ? months : 1) / interval)) };
    }

    return { frequency, count: DEFAULT_PAYMENT_COUNT };
}

/**
 * The due date of installment `index` (0-based), counted from `baseDate`.
 *
 * Clamps to the last day of the month so that e.g. Jan 31 + 1 month lands on Feb 28/29
 * rather than rolling over into March.
 */
export function dueDateForIndex(
    baseDate: Date,
    index: number,
    frequency: RentFrequency | null | undefined,
): Date {
    const base = new Date(baseDate);
    const monthsToAdd = index * intervalMonthsFor(frequency);

    // Resolve the target year/month arithmetically. Doing this with setMonth() instead lets
    // the date overflow first (Jan 31 -> "Feb 31" -> Mar 3), and by then the month you would
    // clamp against is already the wrong one.
    const monthOffset = base.getMonth() + monthsToAdd;
    const year = base.getFullYear() + Math.floor(monthOffset / 12);
    const month = ((monthOffset % 12) + 12) % 12;

    const lastDayOfTargetMonth = new Date(year, month + 1, 0).getDate();
    const day = Math.min(base.getDate(), lastDayOfTargetMonth);

    const dueDate = new Date(base);
    // Set all three together so there is no intermediate overflow.
    dueDate.setFullYear(year, month, day);

    return dueDate;
}

export interface ScheduleSourceRecord {
    id: number;
    property_type: PropertyType;
    payment_frequency: RentFrequency | null;
    payment_count: number | null;
    rent: number | null;
    created_at: Date;
}

/**
 * `Payments.rent` is an Int column while `OccupantRecord.rent` is a Float, so a fractional
 * rent has to be rounded before it can be written.
 */
export function rentAmountFor(record: Pick<ScheduleSourceRecord, 'rent'>): number | null {
    return record.rent != null && record.rent > 0 ? Math.round(record.rent) : null;
}

/**
 * Build the installment rows for a property.
 *
 * - Off-Plan rows are blank placeholders (no emi, no date). The admin fills each one in
 *   later from the Edit Payment screen.
 * - Rental rows carry the due date and the rent amount when one is known; a rental saved
 *   without a rent still gets its dated rows so the timeline exists.
 *
 * `fromIndex` lets callers append only the missing tail of a schedule (used when a
 * property's payment_count is increased) while keeping dates aligned with existing rows.
 */
export function buildScheduleRows(
    record: ScheduleSourceRecord,
    options: { fromIndex?: number; toCount?: number } = {},
): Prisma.PaymentsCreateManyInput[] {
    const fromIndex = options.fromIndex ?? 0;
    const count = options.toCount ?? record.payment_count ?? 0;

    if (count <= 0 || fromIndex >= count) return [];

    const isOffPlan = record.property_type === 'OffPlan';
    const baseDate = record.created_at ?? new Date();
    const rent = rentAmountFor(record);

    const rows: Prisma.PaymentsCreateManyInput[] = [];
    for (let i = fromIndex; i < count; i++) {
        if (isOffPlan) {
            // Blank placeholder: amount and date are supplied by the admin later.
            rows.push({
                status: 'due',
                payment_date: null,
                occupantRecordId: record.id,
            });
        } else {
            rows.push({
                rent,
                status: 'due',
                payment_date: dueDateForIndex(baseDate, i, record.payment_frequency),
                occupantRecordId: record.id,
            });
        }
    }

    return rows;
}
