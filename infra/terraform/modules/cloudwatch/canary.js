const synthetics = require('Synthetics');
const log = require('SyntheticsLogger');

const apiCanaryBlueprint = async function () {
    const page = synthetics.getPage();
    
    const apiEndpoint = process.env.API_ENDPOINT || 'https://api.example.com/health';
    
    const headers = {
        'User-Agent': synthetics.getCanaryUserAgentString(),
        'Content-Type': 'application/json'
    };
    
    const requestOptions = {
        url: apiEndpoint,
        method: 'GET',
        headers: headers,
        timeout: 10000
    };
    
    log.info(`Making request to ${apiEndpoint}`);
    
    try {
        const response = await synthetics.executeHttpStep(
            'Health Check',
            requestOptions,
            (res) => {
                return new Promise((resolve, reject) => {
                    if (res.statusCode !== 200) {
                        reject(`Health check failed with status code: ${res.statusCode}`);
                    } else {
                        resolve();
                    }
                });
            }
        );
        
        log.info('Health check passed');
    } catch (error) {
        throw new Error(`Health check failed: ${error.message}`);
    }
};

exports.handler = async () => {
    return await synthetics.executeBlueprint(apiCanaryBlueprint);
};