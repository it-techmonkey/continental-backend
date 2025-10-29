-- CreateTable
CREATE TABLE "occupant_records" (
    "id" SERIAL NOT NULL,
    "propertyName" TEXT NOT NULL,
    "developerName" TEXT NOT NULL,
    "propertyType" TEXT NOT NULL,
    "market" TEXT NOT NULL,
    "bedrooms" INTEGER NOT NULL,
    "bathrooms" DOUBLE PRECISION NOT NULL,
    "furnishing" TEXT NOT NULL,
    "city" TEXT NOT NULL,
    "location" TEXT NOT NULL,
    "viewsFromProperty" TEXT NOT NULL,
    "amenities" TEXT NOT NULL,
    "handover" TEXT,
    "rent" DOUBLE PRECISION,
    "rentFrequency" TEXT,
    "rentalAgreement" BOOLEAN,
    "propertyAgreement" BOOLEAN,
    "paymentProof" BOOLEAN,
    "completionDate" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "occupant_records_pkey" PRIMARY KEY ("id")
);
