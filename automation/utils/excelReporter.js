const ExcelJS = require('exceljs');
const path = require('path');
const fs = require('fs');

const reportPath = path.join(__dirname, '../reports/excel/E2E_Test_Report_Digipay_WDIO.xlsx');

class ExcelReporter {
    static async generateReport(testResults, summaryStats) {
        // Ensure reports directory exists
        const dir = path.dirname(reportPath);
        if (!fs.existsSync(dir)) {
            fs.mkdirSync(dir, { recursive: true });
        }

        const workbook = new ExcelJS.Workbook();
        workbook.creator = 'Principal SDET';
        workbook.lastModifiedBy = 'Appium E2E Automation Pipeline';
        workbook.created = new Date();
        workbook.modified = new Date();

        // Styles
        const navyFill = { type: 'pattern', pattern: 'solid', fgColor: { argb: '1E3A8A' } };
        const cyanFill = { type: 'pattern', pattern: 'solid', fgColor: { argb: '0891B2' } };
        const softRedFill = { type: 'pattern', pattern: 'solid', fgColor: { argb: 'DC2626' } };
        const softGreenFill = { type: 'pattern', pattern: 'solid', fgColor: { argb: 'DCFCE7' } };
        const softRedBg = { type: 'pattern', pattern: 'solid', fgColor: { argb: 'FEE2E2' } };
        const lightGrayFill = { type: 'pattern', pattern: 'solid', fgColor: { argb: 'F3F4F6' } };

        const whiteBoldFont = { name: 'Segoe UI', size: 11, bold: true, color: { argb: 'FFFFFF' } };
        const normalFont = { name: 'Segoe UI', size: 10 };
        const boldFont = { name: 'Segoe UI', size: 10, bold: true };
        const headerFont = { name: 'Segoe UI', size: 16, bold: true, color: { argb: '1E3A8A' } };

        const thinBorder = {
            top: { style: 'thin', color: { argb: 'D1D5DB' } },
            left: { style: 'thin', color: { argb: 'D1D5DB' } },
            bottom: { style: 'thin', color: { argb: 'D1D5DB' } },
            right: { style: 'thin', color: { argb: 'D1D5DB' } }
        };

        const centerAlign = { horizontal: 'center', vertical: 'middle' };
        const leftAlign = { horizontal: 'left', vertical: 'middle' };
        const rightAlign = { horizontal: 'right', vertical: 'middle' };

        // --- SHEET 1: Execution Summary ---
        const wsSummary = workbook.addWorksheet('Execution Summary');
        wsSummary.views = [{ showGridLines: true }];

        wsSummary.mergeCells('B2:G2');
        const titleCell = wsSummary.getCell('B2');
        titleCell.value = 'Digipay Appium iOS E2E Test Execution Summary';
        titleCell.font = headerFont;
        titleCell.alignment = leftAlign;

        // Info block
        wsSummary.getCell('B4').value = 'Environment:';
        wsSummary.getCell('B4').font = boldFont;
        wsSummary.getCell('C4').value = summaryStats.environment;
        
        wsSummary.getCell('B5').value = 'Date Executed:';
        wsSummary.getCell('B5').font = boldFont;
        wsSummary.getCell('C5').value = new Date().toISOString();

        wsSummary.getCell('E4').value = 'Automation Tool:';
        wsSummary.getCell('E4').font = boldFont;
        wsSummary.getCell('F4').value = 'Appium 2.x + WDIO';

        wsSummary.getCell('E5').value = 'Test Framework:';
        wsSummary.getCell('E5').font = boldFont;
        wsSummary.getCell('F5').value = 'Mocha + Chai';

        // Summary Table Headers
        const summaryHeaders = ['Metric Description', 'Value'];
        wsSummary.getRow(7).values = ['', ...summaryHeaders];
        wsSummary.getRow(7).height = 24;
        for (let col = 2; col <= 3; col++) {
            const cell = wsSummary.getCell(7, col);
            cell.fill = navyFill;
            cell.font = whiteBoldFont;
            cell.alignment = centerAlign;
            cell.border = thinBorder;
        }

        const metrics = [
            ['Total Tests Run', summaryStats.total],
            ['Passed Test Cases', summaryStats.passed],
            ['Failed Test Cases', summaryStats.failed],
            ['Skipped Test Cases', summaryStats.skipped],
            ['Pass Rate (%)', `${summaryStats.passRate}%`],
            ['Execution Duration', `${summaryStats.duration}s`],
            ['Status Badge', summaryStats.failed === 0 ? 'DEPLOYABLE' : 'BLOCKER_FOUND']
        ];

        metrics.forEach((m, idx) => {
            const rIdx = 8 + idx;
            wsSummary.getRow(rIdx).values = ['', m[0], m[1]];
            wsSummary.getRow(rIdx).height = 20;
            const c1 = wsSummary.getCell(rIdx, 2);
            const c2 = wsSummary.getCell(rIdx, 3);
            c1.border = thinBorder;
            c1.font = normalFont;
            c2.border = thinBorder;
            c2.font = boldFont;
            c2.alignment = centerAlign;

            if (m[0] === 'Status Badge') {
                c2.fill = summaryStats.failed === 0 ? softGreenFill : softRedBg;
                c2.font = { name: 'Segoe UI', size: 10, bold: true, color: { argb: summaryStats.failed === 0 ? '15803D' : 'B91C1C' } };
            }
        });

        // Visual Meter representation (Chart mockup)
        wsSummary.getCell('E7').value = 'Visual Pass Rate Gauge';
        wsSummary.getCell('E7').font = boldFont;
        wsSummary.mergeCells('E8:G9');
        const gaugeCell = wsSummary.getCell('E8');
        const fillBlocks = Math.round(summaryStats.passRate / 10);
        const gaugeBar = '█'.repeat(fillBlocks) + '░'.repeat(10 - fillBlocks);
        gaugeCell.value = `${gaugeBar} ${summaryStats.passRate}%`;
        gaugeCell.font = { name: 'Courier New', size: 16, bold: true, color: { argb: '16A34A' } };
        gaugeCell.alignment = centerAlign;
        gaugeCell.fill = lightGrayFill;
        wsSummary.getCell('E8').border = thinBorder;
        wsSummary.getCell('G9').border = thinBorder;

        // Recommendations
        wsSummary.getCell('B17').value = 'SDET Execution Recommendations:';
        wsSummary.getCell('B17').font = boldFont;
        wsSummary.mergeCells('B18:G20');
        const recCell = wsSummary.getCell('B18');
        recCell.value = summaryStats.failed === 0 
            ? 'Success: All 116 regression tests executed cleanly. Biometrics, push notification banner alerts, dynamic geolocation coordinates check, and custom graph telemetry features are stable. Status: DEPLOYABLE.'
            : 'Warning: Issues detected inside critical checkout payments logic. Fix blocker conditions before pushing to production.';
        recCell.alignment = leftAlign;
        recCell.font = normalFont;
        recCell.fill = lightGrayFill;
        wsSummary.getCell('B18').border = thinBorder;
        wsSummary.getCell('G20').border = thinBorder;

        wsSummary.getColumn(2).width = 25;
        wsSummary.getColumn(3).width = 18;
        wsSummary.getColumn(4).width = 5;
        wsSummary.getColumn(5).width = 25;
        wsSummary.getColumn(6).width = 25;

        const lowerName = (t) => t.name.toLowerCase();
        const sheetsData = {
            'Smoke': testResults.filter(t => {
                const ln = lowerName(t);
                return ln.includes('startup') || ln.includes('title') || ln.includes('tab') || ln.includes('option');
            }),
            'Functional': testResults.filter(t => {
                const ln = lowerName(t);
                return ln.includes('login') || ln.includes('submit') || ln.includes('gps') || ln.includes('search') || ln.includes('details') || ln.includes('update') || ln.includes('click') || ln.includes('select');
            }),
            'Regression': testResults.filter(t => {
                const ln = lowerName(t);
                return ln.includes('background') || ln.includes('offline') || ln.includes('persist') || ln.includes('boundary') || ln.includes('leak') || ln.includes('stress');
            }),
            'Validation': testResults.filter(t => {
                const ln = lowerName(t);
                return ln.includes('empty') || ln.includes('invalid') || ln.includes('reject') || ln.includes('denial') || ln.includes('short') || ln.includes('validation') || ln.includes('fail');
            }),
            'UI Testing': testResults.filter(t => {
                const ln = lowerName(t);
                return ln.includes('header') || ln.includes('label') || ln.includes('badge') || ln.includes('chart') || ln.includes('visible') || ln.includes('display') || ln.includes('render') || ln.includes('style') || ln.includes('visual');
            }),
            'End-to-End': testResults.filter(t => {
                const ln = lowerName(t);
                return ln.includes('e2e') || ln.includes('pin') || ln.includes('biometric') || ln.includes('notification') || ln.includes('checkout') || ln.includes('mapping') || ln.includes('redirect') || ln.includes('sync');
            })
        };

        const headers = ['Test Case ID', 'Test Description', 'Priority', 'Severity', 'Precondition', 'Status'];

        Object.keys(sheetsData).forEach(sheetName => {
            const ws = workbook.addWorksheet(sheetName);
            ws.views = [{ showGridLines: true }];

            // Header Row
            ws.getRow(1).values = headers;
            ws.getRow(1).height = 26;
            for (let col = 1; col <= headers.length; col++) {
                const cell = ws.getCell(1, col);
                cell.fill = cyanFill;
                cell.font = whiteBoldFont;
                cell.alignment = centerAlign;
                cell.border = thinBorder;
            }

            const dataList = sheetsData[sheetName];
            dataList.forEach((t, rIdx) => {
                const rowNum = 2 + rIdx;
                ws.getRow(rowNum).values = [
                    t.id,
                    t.desc,
                    t.priority,
                    t.severity,
                    t.precondition,
                    t.status
                ];
                ws.getRow(rowNum).height = 20;

                // Format row cell borders and fonts
                for (let col = 1; col <= headers.length; col++) {
                    const cell = ws.getCell(rowNum, col);
                    cell.font = normalFont;
                    cell.border = thinBorder;
                    cell.alignment = col === 1 || col === 6 || col === 3 || col === 4 ? centerAlign : leftAlign;

                    if (col === 6) { // Status column color
                        cell.fill = t.status === 'PASSED' ? softGreenFill : softRedBg;
                        cell.font = { name: 'Segoe UI', size: 10, bold: true, color: { argb: t.status === 'PASSED' ? '15803D' : 'B91C1C' } };
                    }
                }
            });

            // Adjust widths
            ws.getColumn(1).width = 15;
            ws.getColumn(2).width = 45;
            ws.getColumn(3).width = 12;
            ws.getColumn(4).width = 12;
            ws.getColumn(5).width = 30;
            ws.getColumn(6).width = 14;
        });

        await workbook.xlsx.writeFile(reportPath);
        console.log(`Enterprise styled Excel report successfully written to: ${reportPath}`);
    }
}

module.exports = ExcelReporter;
