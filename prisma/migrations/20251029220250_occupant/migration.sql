/*
  Warnings:

  - You are about to drop the column `payment_proof` on the `occupant_records` table. All the data in the column will be lost.
  - You are about to drop the column `property_agreement` on the `occupant_records` table. All the data in the column will be lost.
  - You are about to drop the column `rent_frequency` on the `occupant_records` table. All the data in the column will be lost.
  - Added the required column `name` to the `occupant_records` table without a default value. This is not possible if the table is not empty.
  - Added the required column `phone` to the `occupant_records` table without a default value. This is not possible if the table is not empty.

*/
-- CreateEnum
CREATE TYPE "PaymentStatus" AS ENUM ('due', 'paid', 'overdue');

-- CreateEnum
CREATE TYPE "PaymentMode" AS ENUM ('online', 'offline');

-- AlterTable
ALTER TABLE "occupant_records" DROP COLUMN "payment_proof",
DROP COLUMN "property_agreement",
DROP COLUMN "rent_frequency",
ADD COLUMN     "email" TEXT,
ADD COLUMN     "emi" INTEGER,
ADD COLUMN     "image_url" TEXT,
ADD COLUMN     "name" TEXT NOT NULL,
ADD COLUMN     "offplan_agreement" TEXT,
ADD COLUMN     "payment_count" INTEGER DEFAULT 1,
ADD COLUMN     "payment_frequency" "RentFrequency",
ADD COLUMN     "phone" TEXT NOT NULL,
ADD COLUMN     "price" INTEGER;

-- CreateTable
CREATE TABLE "payments" (
    "id" SERIAL NOT NULL,
    "emi" INTEGER,
    "rent" INTEGER,
    "status" "PaymentStatus" NOT NULL DEFAULT 'due',
    "payment_date" TIMESTAMP(3),
    "payment_proof" TEXT,
    "mode_of_payment" "PaymentMode" NOT NULL DEFAULT 'online',
    "occupantRecordId" INTEGER,

    CONSTRAINT "payments_pkey" PRIMARY KEY ("id")
);

-- AddForeignKey
ALTER TABLE "payments" ADD CONSTRAINT "payments_occupantRecordId_fkey" FOREIGN KEY ("occupantRecordId") REFERENCES "occupant_records"("id") ON DELETE SET NULL ON UPDATE CASCADE;
