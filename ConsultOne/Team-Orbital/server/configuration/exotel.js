const axios = require('axios');

// Exotel API Configuration
// Get your credentials from https://exotel.com/dashboard

const EXOTEL_CONFIG = {
    API_KEY: process.env.EXOTEL_API_KEY || 'YOUR_EXOTEL_API_KEY',
    API_TOKEN: process.env.EXOTEL_API_TOKEN || 'YOUR_EXOTEL_API_TOKEN',
    ACCOUNT_SID: process.env.EXOTEL_ACCOUNT_SID || 'YOUR_ACCOUNT_SID',
    BASE_URL: 'https://api.exotel.com/v2',
};

/**
 * Generate a masked number for connecting two parties
 * @param {string} agentPhone - Doctor's phone number (from DB)
 * @param {string} customerPhone - Patient's phone number (from DB)
 * @param {string} callerId - Caller ID / Virtual number to use
 * @returns {Promise<Object>} { maskedNumber, sessionId }
 */
const generateMaskedNumber = async (agentPhone, customerPhone, callerId = null) => {
    try {
        const endpoint = `${EXOTEL_CONFIG.BASE_URL}/accounts/${EXOTEL_CONFIG.ACCOUNT_SID}/virtual_numbers/map`;

        const response = await axios.post(
            endpoint,
            {
                phone_number: agentPhone,
                caller_id: callerId || process.env.EXOTEL_VIRTUAL_NUMBER || '08045889186',
                custom_data: {
                    customer_phone: customerPhone,
                    timestamp: new Date().toISOString(),
                },
            },
            {
                auth: {
                    username: EXOTEL_CONFIG.API_KEY,
                    password: EXOTEL_CONFIG.API_TOKEN,
                },
                headers: {
                    'Content-Type': 'application/json',
                },
            }
        );

        const maskedNumber = response.data?.virtual_number || callerId || '08045889186';
        const sessionId = response.data?.id;

        return {
            maskedNumber,
            sessionId,
            success: true,
        };
    } catch (error) {
        console.error('Exotel Error:', error.response?.data || error.message);
        
        // Fallback to default masked number if Exotel fails
        return {
            maskedNumber: '08045889186',
            sessionId: null,
            success: false,
            error: error.message,
        };
    }
};

/**
 * Get call details from Exotel
 * @param {string} sessionId - Session ID from masked number generation
 * @returns {Promise<Object>} Call details
 */
const getCallDetails = async (sessionId) => {
    try {
        if (!sessionId) return null;

        const endpoint = `${EXOTEL_CONFIG.BASE_URL}/accounts/${EXOTEL_CONFIG.ACCOUNT_SID}/virtual_numbers/${sessionId}`;

        const response = await axios.get(endpoint, {
            auth: {
                username: EXOTEL_CONFIG.API_KEY,
                password: EXOTEL_CONFIG.API_TOKEN,
            },
        });

        return response.data;
    } catch (error) {
        console.error('Exotel Get Call Details Error:', error.message);
        return null;
    }
};

/**
 * Disconnect a masked number session
 * @param {string} sessionId - Session ID to disconnect
 * @returns {Promise<boolean>}
 */
const disconnectMaskedNumber = async (sessionId) => {
    try {
        if (!sessionId) return true;

        const endpoint = `${EXOTEL_CONFIG.BASE_URL}/accounts/${EXOTEL_CONFIG.ACCOUNT_SID}/virtual_numbers/${sessionId}`;

        await axios.delete(endpoint, {
            auth: {
                username: EXOTEL_CONFIG.API_KEY,
                password: EXOTEL_CONFIG.API_TOKEN,
            },
        });

        return true;
    } catch (error) {
        console.error('Exotel Disconnect Error:', error.message);
        return false;
    }
};

module.exports = {
    generateMaskedNumber,
    getCallDetails,
    disconnectMaskedNumber,
    EXOTEL_CONFIG,
};
