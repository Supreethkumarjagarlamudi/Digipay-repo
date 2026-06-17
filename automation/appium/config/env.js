const dotenv = require('dotenv');
dotenv.config();

const environment = process.env.NODE_ENV || 'development';

const configs = {
    development: {
        baseUrl: 'http://localhost:8000',
        timeout: 5000,
        mockPayments: true
    },
    staging: {
        baseUrl: 'https://staging.digipay.in',
        timeout: 10000,
        mockPayments: false
    },
    production: {
        baseUrl: 'https://web-production-86613.up.railway.app',
        timeout: 15000,
        mockPayments: false
    }
};

module.exports = {
    env: environment,
    config: configs[environment]
};
