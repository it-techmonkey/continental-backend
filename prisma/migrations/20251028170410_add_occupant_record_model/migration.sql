/*
  Warnings:

  - You are about to drop the column `completionDate` on the `occupant_records` table. All the data in the column will be lost.
  - You are about to drop the column `createdAt` on the `occupant_records` table. All the data in the column will be lost.
  - You are about to drop the column `developerName` on the `occupant_records` table. All the data in the column will be lost.
  - You are about to drop the column `paymentProof` on the `occupant_records` table. All the data in the column will be lost.
  - You are about to drop the column `propertyAgreement` on the `occupant_records` table. All the data in the column will be lost.
  - You are about to drop the column `propertyName` on the `occupant_records` table. All the data in the column will be lost.
  - You are about to drop the column `propertyType` on the `occupant_records` table. All the data in the column will be lost.
  - You are about to drop the column `rentFrequency` on the `occupant_records` table. All the data in the column will be lost.
  - You are about to drop the column `rentalAgreement` on the `occupant_records` table. All the data in the column will be lost.
  - You are about to drop the column `updatedAt` on the `occupant_records` table. All the data in the column will be lost.
  - You are about to drop the column `viewsFromProperty` on the `occupant_records` table. All the data in the column will be lost.
  - The `market` column on the `occupant_records` table would be dropped and recreated. This will lead to data loss if there is data in the column.
  - You are about to alter the column `bathrooms` on the `occupant_records` table. The data in that column could be lost. The data in that column will be cast from `DoublePrecision` to `Integer`.
  - The `handover` column on the `occupant_records` table would be dropped and recreated. This will lead to data loss if there is data in the column.
  - Added the required column `developer_name` to the `occupant_records` table without a default value. This is not possible if the table is not empty.
  - Added the required column `property_name` to the `occupant_records` table without a default value. This is not possible if the table is not empty.
  - Added the required column `updated_at` to the `occupant_records` table without a default value. This is not possible if the table is not empty.

*/
-- CreateEnum
CREATE TYPE "PropertyType" AS ENUM ('Rental', 'OffPlan');

-- CreateEnum
CREATE TYPE "Market" AS ENUM ('Primary', 'Secondary');

-- AlterTable
ALTER TABLE "occupant_records" DROP COLUMN "completionDate",
DROP COLUMN "createdAt",
DROP COLUMN "developerName",
DROP COLUMN "paymentProof",
DROP COLUMN "propertyAgreement",
DROP COLUMN "propertyName",
DROP COLUMN "propertyType",
DROP COLUMN "rentFrequency",
DROP COLUMN "rentalAgreement",
DROP COLUMN "updatedAt",
DROP COLUMN "viewsFromProperty",
ADD COLUMN     "completion_date" TIMESTAMP(3),
ADD COLUMN     "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
ADD COLUMN     "developer_name" TEXT NOT NULL,
ADD COLUMN     "latitude" DOUBLE PRECISION,
ADD COLUMN     "longitude" DOUBLE PRECISION,
ADD COLUMN     "payment_proof" TEXT,
ADD COLUMN     "property_agreement" TEXT,
ADD COLUMN     "property_name" TEXT NOT NULL,
ADD COLUMN     "property_type" "PropertyType" NOT NULL DEFAULT 'Rental',
ADD COLUMN     "property_views" TEXT,
ADD COLUMN     "rent_frequency" TEXT,
ADD COLUMN     "rental_agreement" TEXT,
ADD COLUMN     "updated_at" TIMESTAMP(3) NOT NULL,
DROP COLUMN "market",
ADD COLUMN     "market" "Market",
ALTER COLUMN "bedrooms" DROP NOT NULL,
ALTER COLUMN "bathrooms" DROP NOT NULL,
ALTER COLUMN "bathrooms" SET DATA TYPE INTEGER,
ALTER COLUMN "furnishing" DROP NOT NULL,
ALTER COLUMN "city" DROP NOT NULL,
ALTER COLUMN "location" DROP NOT NULL,
ALTER COLUMN "amenities" DROP NOT NULL,
DROP COLUMN "handover",
ADD COLUMN     "handover" BOOLEAN;
