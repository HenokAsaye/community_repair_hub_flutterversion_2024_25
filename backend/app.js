import express from "express";
import cookieParser from "cookie-parser";
import authRoutes from "./routes/authRoutes.js";
import citizenRoutes from "./routes/citizenRoute.js"
import cors from "cors";
import path from 'path';
import { fileURLToPath } from 'url';
import adminRoutes from "./routes/adminRoute.js";
import teamRoutes from "./routes/teamRoutes.js";
import multer from 'multer';
import fs from 'fs';
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const app = express();
app.use(cors({
    origin: '*', 
    methods: ['GET', 'POST', 'PUT', 'DELETE'],
    allowedHeaders: ['Content-Type', 'Authorization']
}));
app.use(express.json({ limit: '50mb' }));
app.use(express.urlencoded({ extended: true, limit: '50mb' }));
app.use(cookieParser());
// Set up static file serving for uploads directory - multiple approaches for robustness
// 1. Serve from the uploads directory directly
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// 2. Serve the entire uploads directory at the root as well (alternative path)
app.use(express.static(path.join(__dirname, 'uploads')));

// 3. Add a dedicated route for serving image files with detailed logging
app.get('/uploads/:filename', (req, res) => {
  const filename = req.params.filename;
  const filePath = path.join(__dirname, 'uploads', filename);
  console.log(`Image request received for: ${filename}`);
  console.log(`Attempting to serve file from: ${filePath}`);
  
  // Check if file exists before sending
  fs.access(filePath, fs.constants.F_OK, (err) => {
    if (err) {
      console.error(`File not found: ${filePath}`);
      return res.status(404).json({ error: 'Image not found', path: filePath });
    }
    
    console.log(`File exists, sending: ${filePath}`);
    res.sendFile(filePath);
  });
});

// 4. Add a test route for image access
app.get('/test-image/:filename', (req, res) => {
  const filename = req.params.filename;
  const filePath = path.join(__dirname, 'uploads', filename);
  console.log(`Testing image access for: ${filename} at ${filePath}`);
  res.sendFile(filePath);
});

// 5. Add a route to debug and list available images
app.get('/list-uploads', (req, res) => {
  const uploadsDir = path.join(__dirname, 'uploads');
  console.log(`Listing files in: ${uploadsDir}`);
  fs.readdir(uploadsDir, (err, files) => {
    if (err) {
      console.error('Error reading uploads directory:', err);
      return res.status(500).json({ error: 'Failed to read uploads directory', details: err.message });
    }
    
    // Create full URLs for each file
    const fileUrls = files.map(file => ({
      filename: file,
      url: `/uploads/${file}`,
      testUrl: `/test-image/${file}`,
      fullPath: path.join(uploadsDir, file)
    }));
    
    res.json({ 
      files: fileUrls, 
      directory: uploadsDir,
      count: files.length
    });
  });
});
app.use('/auth', authRoutes);
app.use("/users", authRoutes);
app.use("/citizens", citizenRoutes);
app.use("/admin", adminRoutes);
app.use("/team", teamRoutes);
app.use((err, req, res, next) => {
    console.error('Global error handler:', {
        message: err.message,
        stack: err.stack,
        name: err.name
    });
    if (err instanceof multer.MulterError) {
        return res.status(400).json({
            success: false,
            message: `Upload error: ${err.message}`
        });
    }
    res.status(500).json({
        success: false,
        message: 'Something went wrong!',
        error: err.message,
        details: process.env.NODE_ENV === 'development' ? err.stack : undefined
    });
});

export default app;