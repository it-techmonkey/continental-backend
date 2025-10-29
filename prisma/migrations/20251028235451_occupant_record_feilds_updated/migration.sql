/*
  Warnings:

  - The `furnishing` column on the `occupant_records` table would be dropped and recreated. This will lead to data loss if there is data in the column.
  - The `amenities` column on the `occupant_records` table would be dropped and recreated. This will lead to data loss if there is data in the column.
  - The `rent_frequency` column on the `occupant_records` table would be dropped and recreated. This will lead to data loss if there is data in the column.
  - The `handover` column on the `occupant_records` table would be dropped and recreated. This will lead to data loss if there is data in the column.

*/
-- CreateEnum
CREATE TYPE "RentFrequency" AS ENUM ('monthly', 'quarterly', 'yearly');

-- CreateEnum
CREATE TYPE "Furnishing" AS ENUM ('fully_furnished', 'partially_furnished', 'unfurnished', 'kitchen_appliances_only');

-- AlterTable
ALTER TABLE "occupant_records" DROP COLUMN "furnishing",
ADD COLUMN     "furnishing" "Furnishing",
DROP COLUMN "amenities",
ADD COLUMN     "amenities" TEXT[],
DROP COLUMN "rent_frequency",
ADD COLUMN     "rent_frequency" "RentFrequency",
DROP COLUMN "handover",
ADD COLUMN     "handover" TIMESTAMP(3);
