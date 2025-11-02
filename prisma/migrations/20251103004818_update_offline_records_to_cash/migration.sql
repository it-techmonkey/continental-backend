-- Update all existing records with 'offline' to 'cash'
-- This runs after the enum value has been committed
UPDATE "payments" SET "mode_of_payment" = 'cash' WHERE "mode_of_payment" = 'offline';

