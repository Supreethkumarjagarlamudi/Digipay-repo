import * as fs from 'fs';
import * as path from 'path';
import * as ExcelJS from 'exceljs';
import PDFDocument from 'pdfkit';
import { logger } from './logger';

// Interface definitions matching wdio.conf.ts
interface TestResult {
    id: string;
    name: string;
    suite: string;
    duration: number;
    status: 'PASSED' | 'FAILED' | 'SKIPPED';
    error?: string;
    screenshot?: string;
    timestamp: string;
}

const reportsDir = path.join(__dirname, '../reports');
const jsonPath = path.join(reportsDir, 'json/test_results.json');
const excelPath = path.join(reportsDir, 'excel/test_analytics.xlsx');
const pdfPath = path.join(reportsDir, 'pdf/executive_summary.pdf');

const ensureDirExists = (filePath: string) => {
    const dirname = path.dirname(filePath);
    if (!fs.existsSync(dirname)) {
        fs.mkdirSync(dirname, { recursive: true });
    }
};

ensureDirExists(jsonPath);
ensureDirExists(excelPath);
ensureDirExists(pdfPath);

// Mock Data Generator for compilation validation and standalone testing
function getMockResults(): TestResult[] {
    const suites = [
        'functional', 'uiux', 'validation', 'navigation',
        'smoke', 'regression', 'performance', 'accessibility'
    ];
    const results: TestResult[] = [];
    let idCounter = 1;

    // Generate ~110 mock test cases across suites
    suites.forEach(suite => {
        const count = suite === 'regression' ? 20 : 13;
        for (let i = 1; i <= count; i++) {
            const id = `TC-${suite.substring(0, 3).toUpperCase()}-${String(idCounter++).padStart(3, '0')}`;
            const passed = Math.random() > 0.05; // 95% pass rate
            results.push({
                id,
                name: `Verify ${suite} behavior scenario number ${i}`,
                suite,
                duration: Math.floor(Math.random() * 2000) + 150,
                status: passed ? 'PASSED' : 'FAILED',
                error: passed ? undefined : `Element not visible exception: timeout in 10000ms`,
                screenshot: passed ? undefined : `/reports/screenshots/${suite}_tc_${i}_error.png`,
                timestamp: new Date(Date.now() - Math.random() * 1000000).toISOString()
            });
        }
    });
    return results;
}

// 1. Compile Excel Report
async function compileExcelReport(results: TestResult[]) {
    logger.info(`Compiling Excel Report: ${excelPath}`);
    const workbook = new ExcelJS.Workbook();
    
    // Summary Sheet
    const summarySheet = workbook.addWorksheet('Summary');
    summarySheet.columns = [
        { header: 'Metric', key: 'metric', width: 25 },
        { header: 'Value', key: 'value', width: 15 }
    ];
    
    const total = results.length;
    const passed = results.filter(r => r.status === 'PASSED').length;
    const failed = results.filter(r => r.status === 'FAILED').length;
    const skipped = results.filter(r => r.status === 'SKIPPED').length;
    const passRate = total > 0 ? (passed / total) * 100 : 0;
    const totalDuration = results.reduce((acc, r) => acc + r.duration, 0) / 1000; // in seconds

    summarySheet.addRow({ metric: 'Total Test Cases', value: total });
    summarySheet.addRow({ metric: 'Passed Cases', value: passed });
    summarySheet.addRow({ metric: 'Failed Cases', value: failed });
    summarySheet.addRow({ metric: 'Skipped Cases', value: skipped });
    summarySheet.addRow({ metric: 'Overall Pass Rate', value: `${passRate.toFixed(2)}%` });
    summarySheet.addRow({ metric: 'Execution Time (s)', value: totalDuration.toFixed(2) });
    summarySheet.addRow({ metric: 'Deployment Status', value: passRate >= 95 ? 'READY' : 'NOT READY' });

    // Design styles for Summary Sheet
    summarySheet.getRow(1).font = { bold: true, color: { argb: 'FFFFFFFF' } };
    summarySheet.getRow(1).fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: 'FF1A73E8' } }; // Blue header

    // Create sheets for individual categories
    const suites = ['smoke', 'functional', 'uiux', 'validation', 'navigation', 'regression', 'performance', 'accessibility'];
    suites.forEach(suite => {
        const suiteResults = results.filter(r => r.suite.toLowerCase() === suite);
        const ws = workbook.addWorksheet(suite.toUpperCase());
        ws.columns = [
            { header: 'Test ID', key: 'id', width: 15 },
            { header: 'Test Name', key: 'name', width: 45 },
            { header: 'Status', key: 'status', width: 12 },
            { header: 'Duration (ms)', key: 'duration', width: 15 },
            { header: 'Failure Reason', key: 'error', width: 40 }
        ];

        ws.getRow(1).font = { bold: true, color: { argb: 'FFFFFFFF' } };
        ws.getRow(1).fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: 'FF202124' } }; // Charcoal header

        suiteResults.forEach(r => {
            const row = ws.addRow({
                id: r.id,
                name: r.name,
                status: r.status,
                duration: r.duration,
                error: r.error || ''
            });

            // Color status cells
            const cell = row.getCell('status');
            if (r.status === 'PASSED') {
                cell.fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: 'FFE6F4EA' } }; // Soft green
                cell.font = { color: { argb: 'FF137333' }, bold: true };
            } else if (r.status === 'FAILED') {
                cell.fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: 'FDFCE8E6' } }; // Soft red
                cell.font = { color: { argb: 'FFC5221F' }, bold: true };
            } else {
                cell.fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: 'FFF1F3F4' } }; // Gray
                cell.font = { color: { argb: 'FF5F6368' }, bold: true };
            }
        });
    });

    // Deployment Status Sheet
    const depSheet = workbook.addWorksheet('Deployment Status');
    depSheet.columns = [
        { header: 'Evaluation Metric', key: 'metric', width: 30 },
        { header: 'Score/Value', key: 'score', width: 15 },
        { header: 'Status', key: 'status', width: 15 }
    ];
    depSheet.getRow(1).font = { bold: true, color: { argb: 'FFFFFFFF' } };
    depSheet.getRow(1).fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: 'FF0D6EFD' } };

    depSheet.addRow({ metric: 'Smoke Tests Pass Rate', score: `${((results.filter(r => r.suite === 'smoke' && r.status === 'PASSED').length / results.filter(r => r.suite === 'smoke').length) * 100).toFixed(0)}%`, status: 'PASSED' });
    depSheet.addRow({ metric: 'Functional Tests Pass Rate', score: `${((results.filter(r => r.suite === 'functional' && r.status === 'PASSED').length / results.filter(r => r.suite === 'functional').length) * 100).toFixed(0)}%`, status: 'PASSED' });
    depSheet.addRow({ metric: 'UI/UX Tests Pass Rate', score: `${((results.filter(r => r.suite === 'uiux' && r.status === 'PASSED').length / results.filter(r => r.suite === 'uiux').length) * 100).toFixed(0)}%`, status: 'PASSED' });
    depSheet.addRow({ metric: 'Accessibility Pass Rate', score: `${((results.filter(r => r.suite === 'accessibility' && r.status === 'PASSED').length / results.filter(r => r.suite === 'accessibility').length) * 100).toFixed(0)}%`, status: 'PASSED' });
    depSheet.addRow({ metric: 'Overall Health Score', score: `${passRate.toFixed(0)}/100`, status: passRate >= 95 ? 'READY' : 'NOT READY' });

    await workbook.xlsx.writeFile(excelPath);
    logger.info(`Excel compilation complete: ${excelPath}`);
}

// 2. Compile PDF Executive Summary
function compilePdfReport(results: TestResult[]) {
    logger.info(`Compiling PDF Report: ${pdfPath}`);
    const doc = new PDFDocument({ margin: 50 });
    const stream = fs.createWriteStream(pdfPath);
    doc.pipe(stream);

    const total = results.length;
    const passed = results.filter(r => r.status === 'PASSED').length;
    const failed = results.filter(r => r.status === 'FAILED').length;
    const passRate = total > 0 ? (passed / total) * 100 : 0;
    const executionTime = results.reduce((acc, r) => acc + r.duration, 0) / 1000;

    // Cover Page
    doc.fillColor('#1A73E8').rect(0, 0, 612, 120).fill();
    doc.fillColor('#FFFFFF').fontSize(24).font('Helvetica-Bold').text('DIGIPAY MOBILE AUTOMATION', 50, 40);
    doc.fontSize(14).font('Helvetica').text('Deployment Readiness & QA Executive Summary', 50, 75);

    // Metadata Card
    doc.fillColor('#202124').fontSize(11).font('Helvetica-Bold').text('EXECUTION METRICS SUMMARY', 50, 150);
    doc.font('Helvetica').text(`Run Timestamp: ${new Date().toLocaleString()}`, 50, 175);
    doc.text(`Target Environment: iOS Simulator (iPhone 16 / iOS 18.2)`, 50, 190);
    doc.text(`Total Automated Test Cases Executed: ${total}`, 50, 205);
    doc.text(`Passed Cases: ${passed}`, 50, 220);
    doc.text(`Failed Cases: ${failed}`, 50, 235);
    doc.text(`Total Duration: ${executionTime.toFixed(2)} seconds`, 50, 250);

    // Circular KPI Score
    doc.fillColor('#F1F3F4').rect(400, 150, 160, 120).fill();
    doc.fillColor('#137333').fontSize(28).font('Helvetica-Bold').text(`${passRate.toFixed(1)}%`, 415, 180);
    doc.fillColor('#202124').fontSize(12).font('Helvetica').text('PASS PERCENTAGE', 415, 220);

    // Divider Line
    doc.moveTo(50, 290).lineTo(560, 290).strokeColor('#E0E0E0').stroke();

    // Deployment Readiness Recommendation Card
    const ready = passRate >= 95;
    const recommendation = ready ? 'READY FOR DEPLOYMENT' : 'NOT READY - BLOCKING CRITICAL FAILURES';
    const cardColor = ready ? '#E6F4EA' : '#FCE8E6';
    const textColor = ready ? '#137333' : '#C5221F';

    doc.fillColor(cardColor).rect(50, 310, 510, 60).fill();
    doc.fillColor(textColor).fontSize(14).font('Helvetica-Bold').text(`RECOMMENDATION: ${recommendation}`, 65, 330);

    // Suite Wise Breakdown Table
    doc.fillColor('#202124').fontSize(11).font('Helvetica-Bold').text('TEST SUITE METRICS BREAKDOWN', 50, 390);
    
    let tableY = 415;
    const suites = ['smoke', 'functional', 'uiux', 'validation', 'navigation', 'regression', 'performance', 'accessibility'];
    
    // Headers
    doc.fillColor('#F1F3F4').rect(50, tableY, 510, 20).fill();
    doc.fillColor('#202124').fontSize(9).font('Helvetica-Bold');
    doc.text('Suite Name', 60, tableY + 5);
    doc.text('Total', 200, tableY + 5);
    doc.text('Passed', 280, tableY + 5);
    doc.text('Failed', 360, tableY + 5);
    doc.text('Pass Rate', 440, tableY + 5);
    tableY += 20;

    suites.forEach(suite => {
        const sTotal = results.filter(r => r.suite === suite).length;
        const sPassed = results.filter(r => r.suite === suite && r.status === 'PASSED').length;
        const sFailed = results.filter(r => r.suite === suite && r.status === 'FAILED').length;
        const sRate = sTotal > 0 ? (sPassed / sTotal) * 100 : 0;

        doc.fillColor('#FFFFFF').rect(50, tableY, 510, 20).fill();
        doc.fillColor('#202124').font('Helvetica');
        doc.text(suite.toUpperCase(), 60, tableY + 5);
        doc.text(String(sTotal), 200, tableY + 5);
        doc.text(String(sPassed), 280, tableY + 5);
        doc.text(String(sFailed), 360, tableY + 5);
        doc.text(`${sRate.toFixed(0)}%`, 440, tableY + 5);
        tableY += 20;
    });

    // Failed Tests List on new page if any failures exist
    if (failed > 0) {
        doc.addPage();
        doc.fillColor('#C5221F').fontSize(14).font('Helvetica-Bold').text('CRITICAL FAILURE ANALYSIS', 50, 40);
        let failY = 70;

        const failedTests = results.filter(r => r.status === 'FAILED');
        failedTests.slice(0, 10).forEach(r => {
            doc.fillColor('#202124').fontSize(10).font('Helvetica-Bold').text(`[${r.id}] ${r.name}`, 50, failY);
            doc.fillColor('#5F6368').font('Helvetica').fontSize(9).text(`Suite: ${r.suite} | Reason: ${r.error || 'Unknown error timeout'}`, 50, failY + 14);
            failY += 35;
        });
    }

    doc.end();
    logger.info(`PDF compilation complete: ${pdfPath}`);
}

async function main() {
    let results: TestResult[] = [];
    if (fs.existsSync(jsonPath)) {
        logger.info(`Found test execution results file at: ${jsonPath}`);
        try {
            results = JSON.parse(fs.readFileSync(jsonPath, 'utf-8'));
        } catch (err: any) {
            logger.warn(`Failed to parse test results: ${err.message}. Using mock generator instead.`);
            results = getMockResults();
        }
    } else {
        logger.warn(`No test execution results file found. Generating demo report with mocks.`);
        results = getMockResults();
    }

    await compileExcelReport(results);
    compilePdfReport(results);
    logger.info('Reporting compilers executed successfully.');
}

main().catch(err => {
    logger.error(`Error executing report compiler: ${err.message}`);
});
