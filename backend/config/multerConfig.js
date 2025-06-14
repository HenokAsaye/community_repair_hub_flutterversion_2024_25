import multer from 'multer';
import path from 'path';
import { fileURLToPath } from 'url';
import { dirname } from 'path';
import fs from 'fs';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

// Ensure uploads directory exists
const uploadsDir = path.join(__dirname, '../uploads');
if (!fs.existsSync(uploadsDir)) {
    fs.mkdirSync(uploadsDir, { recursive: true });
}

// Configure storage
const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        cb(null, uploadsDir);
    },
    filename: (req, file, cb) => {
        // Create a unique filename with original extension
        const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
        const ext = path.extname(file.originalname);
        cb(null, uniqueSuffix + ext);
    }
});

// File filter function
const fileFilter = (req, file, cb) => {
    // Define allowed file extensions
    const allowedExtensions = ['.jpeg', '.jpg', '.png', '.gif'];
    // Define allowed MIME types
    const allowedMimeTypes = ['image/jpeg', 'image/png', 'image/gif'];

    // Check file extension
    const extname = path.extname(file.originalname).toLowerCase();
    const isExtensionAllowed = allowedExtensions.includes(extname);

    // Check MIME type
    const isMimeTypeAllowed = allowedMimeTypes.includes(file.mimetype);

    if (isMimeTypeAllowed && isExtensionAllowed) {
        cb(null, true); // Accept the file
    } else {
        let errorMessage = 'File type not allowed.';
        if (!isMimeTypeAllowed) {
            errorMessage += ` Mimetype ${file.mimetype} is not accepted. Expected one of: ${allowedMimeTypes.join(', ')}.`;
        }
        if (!isExtensionAllowed) {
            errorMessage += ` Extension ${extname} is not accepted. Expected one of: ${allowedExtensions.join(', ')}.`;
        }
        // Log the details on the server for easier debugging
        console.warn(`File rejected: originalname='${file.originalname}', mimetype='${file.mimetype}', ext='${extname}'. Reason: ${errorMessage}`);
        cb(new Error(errorMessage), false); // Reject the file
    }
};

// Error handling middleware
const handleMulterError = (err, req, res, next) => {
    if (err instanceof multer.MulterError) {
        if (err.code === 'LIMIT_FILE_SIZE') {
            return res.status(400).json({
                error: 'File too large. Maximum size is 10MB.'
            });
        }
        return res.status(400).json({
            error: `Upload error: ${err.message}`
        });
    } else if (err) {
        return res.status(400).json({
            error: err.message
        });
    }
    next();
};

// Configure multer
const upload = multer({
    storage: storage,
    fileFilter: fileFilter,
    limits: {
        fileSize: 10 * 1024 * 1024, // 10MB limit
        files: 1 // Only allow 1 file per request
    }
});

// Export both the upload middleware and error handler
export { upload, handleMulterError };