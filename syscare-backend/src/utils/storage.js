const fs = require('fs');
const path = require('path');

const DATA_DIR = process.env.DATA_DIR || path.join(__dirname, '../../data');

console.log("Resolved DATA_DIR:", DATA_DIR);

if (!fs.existsSync(DATA_DIR)) {
	fs.mkdirSync(DATA_DIR, { recursive: true });
}

async function storeReport(report) {
	const timestamp = new Date(report.timestamp).toISOString().replace(/[:.]/g, '-');
	const filename = `report-${timestamp}.json`;
	const filepath = path.join(DATA_DIR, filename);
	return fs.promises.writeFile(filepath, JSON.stringify(report, null, 2));
}

module.exports = { storeReport };
