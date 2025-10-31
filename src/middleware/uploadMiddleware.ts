import multer from 'multer';
import { Request } from 'express';

// Configure multer to store files in memory as buffers
const storage = multer.memoryStorage();

// File filter to accept only images and PDFs
const fileFilter = (req: Request, file: Express.Multer.File, cb: multer.FileFilterCallback) => {
    // Check file type
    if (
        file.mimetype.startsWith('image/') ||
        file.mimetype === 'application/pdf'
    ) {
        cb(null, true);
    } else {
        cb(new Error('Invalid file type. Only images and PDFs are allowed.'));
    }
};

// Configure multer
const upload = multer({
    storage: storage,
    fileFilter: fileFilter,
    limits: {
        fileSize: 20 * 1024 * 1024, // 20MB max file size
    },
});

export default upload;

