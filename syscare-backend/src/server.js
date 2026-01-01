require('dotenv').config();
const express = require('express');
const cors = require('cors');

const reportsRouter = require('./routes/reports');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json()); 

app.get('/api/health', (req, res) => {
	res.json({ status: 'ok' });
});

app.use('/api/reports', reportsRouter);

app.listen(PORT, () => {
	console.log(`Syscare backend running on port ${PORT}`)
});
