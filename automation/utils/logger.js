const fs = require('fs');
const path = require('path');

const logFilePath = path.join(__dirname, '../reports/logs/execution.log');

class Logger {
    static init() {
        const dir = path.dirname(logFilePath);
        if (!fs.existsSync(dir)) {
            fs.mkdirSync(dir, { recursive: true });
        }
        // Write standard log header
        if (!fs.existsSync(logFilePath)) {
            fs.writeFileSync(logFilePath, "Timestamp | Module | Action | Result | Duration(ms) | Error Message\n");
        }
    }

    static log(module, action, result, duration, errorMsg = '') {
        this.init();
        const timestamp = new Date().toISOString();
        const cleanError = errorMsg ? errorMsg.replace(/\r?\n|\r/g, " ") : "N/A";
        const logLine = `${timestamp} | ${module} | ${action} | ${result} | ${duration}ms | ${cleanError}\n`;
        
        fs.appendFileSync(logFilePath, logLine);
        console.log(`[${module}] ${action} -> ${result} (${duration}ms) ${errorMsg ? `[Error: ${cleanError}]` : ''}`);
    }
}

module.exports = Logger;
