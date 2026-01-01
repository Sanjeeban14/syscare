const express = require('express');
const router = express.Router();
const { saveReport } = require('../controllers/reportController');

//POST /api/reports
router.post('/', async (req, res) => {
	try{
		const report = req.body;
		await saveReport(report);
		res.status(201).json({ message: 'Report saved successfully' });
	}
	catch(err) {
		console.error(err);
		res.status(500).json({ error: 'Failed to save report' });
	} 
});

module.exports = router;
