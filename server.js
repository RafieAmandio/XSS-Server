const express = require('express');
const fs = require('fs').promises;
const path = require('path');
const cors = require('cors');
const app = express();
const port = 3000;

app.use(cors({
    origin: '*', // Allow all origins
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'], // Allow all methods
    allowedHeaders: ['Content-Type', 'Authorization'] // Allow these headers
}));

// Ensure public directory exists
const publicDir = path.join(__dirname, 'public');
const dataFile = path.join(publicDir, 'data.json');

// Create directory and initial data file if they don't exist
async function initializeStorage() {
    try {
        await fs.mkdir(publicDir, { recursive: true });
        try {
            await fs.access(dataFile);
        } catch {
            await fs.writeFile(dataFile, JSON.stringify([], null, 2));
        }
    } catch (error) {
        console.error('Error initializing storage:', error);
    }
}

// Initialize storage on startup
initializeStorage();

// Serve static files from public directory
app.use('/public', express.static('public'));

// GET route to receive data
app.get('/api', async (req, res) => {
    const receivedData = req.query.data;

    if (!receivedData) {
        return res.status(400).json({
            error: 'Data parameter is required'
        });
    }

    try {
        // Read existing data
        const existingData = JSON.parse(await fs.readFile(dataFile, 'utf8'));

        // Add new data entry
        const newEntry = {
            data: receivedData,
            timestamp: new Date().toISOString()
        };
        existingData.push(newEntry);

        // Save updated data
        await fs.writeFile(dataFile, JSON.stringify(existingData, null, 2));

        res.json(newEntry);
    } catch (error) {
        res.status(500).json({ error: 'Error processing data' });
    }
});

// GET route to retrieve all stored data
app.get('/data', async (req, res) => {
    try {
        const data = await fs.readFile(dataFile, 'utf8');
        res.json(JSON.parse(data));
    } catch (error) {
        res.status(500).json({ error: 'Error retrieving data' });
    }
});

app.listen(port, () => {
    console.log(`Server running on http://localhost:${port}`);
});
