import * as winston from 'winston';
import * as path from 'path';

const logPath = path.join(__dirname, '../reports/logs/execution.log');

export const logger = winston.createLogger({
    level: 'debug',
    format: winston.format.combine(
        winston.format.timestamp({
            format: 'YYYY-MM-DD HH:mm:ss'
        }),
        winston.format.printf(info => `[${info.timestamp}] [${info.level.toUpperCase()}]: ${info.message}`)
    ),
    transports: [
        new winston.transports.Console({
            format: winston.format.combine(
                winston.format.colorize(),
                winston.format.printf(info => `[${info.timestamp}] [${info.level}]: ${info.message}`)
            )
        }),
        new winston.transports.File({ filename: logPath })
    ]
});
