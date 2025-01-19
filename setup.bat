@echo off
echo Setting up Node.js API project...

echo Creating project directories...
mkdir public

echo Creating server.js...
(
echo const express = require^('express'^);
echo const fs = require^('fs'^).promises;
echo const path = require^('path'^);
echo const app = express^(^);
echo const port = 3000;
echo.
echo // Ensure public directory exists
echo const publicDir = path.join^(__dirname, 'public'^);
echo const dataFile = path.join^(publicDir, 'data.json'^);
echo.
echo // Create directory and initial data file if they don't exist
echo async function initializeStorage^(^) {
echo     try {
echo         await fs.mkdir^(publicDir, { recursive: true }^);
echo         try {
echo             await fs.access^(dataFile^);
echo         } catch {
echo             await fs.writeFile^(dataFile, JSON.stringify^([], null, 2^)^);
echo         }
echo     } catch ^(error^) {
echo         console.error^('Error initializing storage:', error^);
echo     }
echo }
echo.
echo // Initialize storage on startup
echo initializeStorage^(^);
echo.
echo // Serve static files from public directory
echo app.use^('/public', express.static^('public'^)^);
echo.
echo // GET route to receive data
echo app.get^('/api', async ^(req, res^) ^=^> {
echo     const receivedData = req.query.data;
echo     
echo     if ^(!receivedData^) {
echo         return res.status^(400^).json^({
echo             error: 'Data parameter is required'
echo         }^);
echo     }
echo.
echo     try {
echo         // Read existing data
echo         const existingData = JSON.parse^(await fs.readFile^(dataFile, 'utf8'^)^);
echo         
echo         // Add new data entry
echo         const newEntry = {
echo             data: receivedData,
echo             timestamp: new Date^(^).toISOString^(^)
echo         };
echo         existingData.push^(newEntry^);
echo.
echo         // Save updated data
echo         await fs.writeFile^(dataFile, JSON.stringify^(existingData, null, 2^)^);
echo.
echo         res.json^(newEntry^);
echo     } catch ^(error^) {
echo         res.status^(500^).json^({ error: 'Error processing data' }^);
echo     }
echo }^);
echo.
echo // GET route to retrieve all stored data
echo app.get^('/data', async ^(req, res^) ^=^> {
echo     try {
echo         const data = await fs.readFile^(dataFile, 'utf8'^);
echo         res.json^(JSON.parse^(data^)^);
echo     } catch ^(error^) {
echo         res.status^(500^).json^({ error: 'Error retrieving data' }^);
echo     }
echo }^);
echo.
echo app.listen^(port, ^(^) ^=^> {
echo     console.log^(`Server running on http://localhost:${port}`^);
echo }^);
) > server.js

echo Creating Dockerfile...
(
echo FROM node:18-alpine
echo.
echo WORKDIR /usr/src/app
echo.
echo COPY package*.json ./
echo.
echo RUN npm install
echo.
echo COPY . .
echo.
echo # Create public directory
echo RUN mkdir -p public
echo.
echo EXPOSE 3000
echo.
echo CMD [ "node", "server.js" ]
) > Dockerfile

echo Creating .dockerignore...
(
echo node_modules
echo npm-debug.log
echo public/data.json
) > .dockerignore

echo Initializing npm project...
call npm init -y

echo Installing dependencies...
call npm install express

echo Building Docker image...
docker build -t node-api-storage .

echo Setup complete!
echo.
echo To start the application, run:
echo docker run -p 3000:3000 -v %cd%/public:/usr/src/app/public node-api-storage
echo.
echo Available endpoints:
echo - POST data: http://localhost:3000/api?data=yourdata
echo - GET all data: http://localhost:3000/data
echo - Access stored file: http://localhost:3000/public/data.json
pause