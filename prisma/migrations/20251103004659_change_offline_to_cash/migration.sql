-- Add 'cash' to PaymentMode enum
ALTER TYPE "PaymentMode" ADD VALUE IF NOT EXISTS 'cash';

-- Note: Enum values must be committed before use, so we'll update records in a separate statement
-- For now, we'll leave existing 'offline' records as is and handle conversion separately

