const { storeReport } = require('../utils/storage');

async function saveReport(report) {
	//validating structure
	if (!report.timestamp) {
		throw new Error ('Missing timestamp in report');
	}
	await storeReport(report);
}

module.exports = { saveReport };
