const express = require('express');
const multer = require('multer');
const cors = require('cors');

const app = express();
app.use(express.json());
app.use(cors());

// File Upload Setup
const upload = multer({ dest: 'uploads/' });

// Example storage for reports
const reports = [];

// Submit a report
app.post('/api/reports', upload.array('photos'), (req, res) => {
    const { location, description, contact } = req.body;
    const photos = req.files.map(file => file.path);
    const report = { id: reports.length + 1, location, description, contact, photos };
    reports.push(report);

    // Simulate posting to social platforms
    console.log(`Posted to social platforms: Location: ${location}, Description: ${description}`);
    res.status(201).json({ message: 'Report submitted!', report });
});

// Fetch all reports
app.get('/api/reports', (req, res) => res.json(reports));

// Start server
const PORT = 5000;
app.listen(PORT, () => console.log(`Server running at http://localhost:${PORT}`));
