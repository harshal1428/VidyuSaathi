const fs = require('fs');
const path = require('path');
const https = require('https');
const os = require('os');
const { execSync } = require('child_process');

const PROJECT_ID = 'civicsense-b653c';

async function main() {
    try {
        console.log("Starting User Data Export (REST API via Owner Auth)...");
        
        // 1. Find Refresh Token from firebase-tools.json
        const configPath = path.join(os.homedir(), '.config', 'configstore', 'firebase-tools.json');
        if (!fs.existsSync(configPath)) {
            console.error("Firebase config not found at: " + configPath);
            return;
        }
        
        const config = JSON.parse(fs.readFileSync(configPath, 'utf8'));
        
        // The structure of firebase-tools.json can vary, but generally it's config.tokens.refresh_token
        let refreshToken = '';
        if (config.tokens && config.tokens.refresh_token) {
            refreshToken = config.tokens.refresh_token;
        } else if (config.user && config.tokens && config.tokens[config.user]) {
             refreshToken = config.tokens[config.user].refresh_token;
        } else {
             // Brute force search for token-like string
             const content = fs.readFileSync(configPath, 'utf8');
             const match = content.match(/1\/\/[-_a-zA-Z0-9]+/);
             if (match) refreshToken = match[0];
        }
        
        if (!refreshToken) {
            console.error("Could not find refresh token in firebase-tools.json. Please run 'firebase login' first.");
            return;
        }
        
        // 2. Exchange Refresh Token for Access Token
        console.log("Exchanging refresh token for access token...");
        const tokenRes = await post('oauth2.googleapis.com', '/token', {
            grant_type: 'refresh_token',
            client_id: '563584335869-fgrhgmd47bqkij5i8b5pr03ho849e6.apps.googleusercontent.com', 
            refresh_token: refreshToken
        });
        
        const accessToken = tokenRes.access_token;
        if (!accessToken) {
             console.error("Token exchange failed: " + JSON.stringify(tokenRes));
             return;
        }
        
        // 3. Fetch USERS collection from Firestore
        console.log("Fetching USERS collection documents...");
        const queryUrl = `/v1/projects/${PROJECT_ID}/databases/(default)/documents/USERS/?pageSize=2000`;
        const firestoreRes = await get('firestore.googleapis.com', queryUrl, accessToken);
        
        if (!firestoreRes.documents || firestoreRes.documents.length === 0) {
            console.error("No users found in collection (or error fetching).");
            console.log(JSON.stringify(firestoreRes, null, 2));
            return;
        }
        
        const docs = firestoreRes.documents;
        console.log(`Retrieved ${docs.length} user documents.`);
        
        // 4. Flatten Firestore documents and convert to CSV
        const headers = [
            'userId', 'name', 'email', 'phone', 'role', 'designation', 
            'divisionId', 'circleId', 'regionId', 'officeId', 'level', 
            'employeeId', 'password', 'departmentId', 'isActive', 'createdAt'
        ];
        
        const csvRows = [headers.join(',')];
        
const flattenedDocs = docs.map(doc => {
    const data = {};
    const fields = doc.fields || {};
    for (const key in fields) {
        data[key] = getVal(fields[key]);
    }
    // Add ID if not in fields
    if (!data.userId) data.userId = doc.name.split('/').pop();
    return data;
});

function getVal(f) {
    if (!f) return '';
    if (f.stringValue !== undefined) return f.stringValue;
    if (f.integerValue !== undefined) return f.integerValue;
    if (f.booleanValue !== undefined) return f.booleanValue;
    if (f.doubleValue !== undefined) return f.doubleValue;
    if (f.timestampValue !== undefined) return f.timestampValue;
    if (f.nullValue !== undefined) return '';
    if (f.mapValue && f.mapValue.fields) {
        // Return JSON string for nested maps
        return JSON.stringify(f.mapValue.fields);
    }
    if (f.arrayValue && f.arrayValue.values) {
        return f.arrayValue.values.map(getVal).join(';');
    }
    return '';
}
        
        // Filter for officers (not CITIZEN role)
        const officers = flattenedDocs.filter(d => (d.role || '').toUpperCase() !== 'CITIZEN' && (d.role || '').toUpperCase() !== 'USER');
        console.log(`Identified ${officers.length} officers.`);
        
        for (const user of officers) {
            const row = headers.map(header => {
                let val = user[header] || '';
                // Quote if necessary
                let strVal = val.toString().replace(/"/g, '""');
                if (strVal.includes(',') || strVal.includes('\n')) {
                    strVal = `"${strVal}"`;
                }
                return strVal;
            }).join(',');
            csvRows.push(row);
        }
        
        const csvContent = csvRows.join('\n');
        fs.writeFileSync('officers_data.csv', csvContent);
        console.log("Successfully saved officers_data.csv in current directory.");
        
    } catch (err) {
        console.error("Fatal Error Exporting Data: ", err);
    }
}

// REST Client Helper Methods
function post(host, path, data) {
    return new Promise((resolve, reject) => {
        const payload = Object.keys(data).map(k => `${encodeURIComponent(k)}=${encodeURIComponent(data[k])}`).join('&');
        const options = {
            hostname: host,
            path: path,
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
                'Content-Length': payload.length
            }
        };
        const req = https.request(options, res => {
            let body = '';
            res.on('data', d => body += d);
            res.on('end', () => resolve(JSON.parse(body)));
        });
        req.on('error', reject);
        req.write(payload);
        req.end();
    });
}

function get(host, path, token) {
    return new Promise((resolve, reject) => {
        const options = {
            hostname: host,
            path: path,
            method: 'GET',
            headers: {
                'Authorization': `Bearer ${token}`
            }
        };
        const req = https.request(options, res => {
            let body = '';
            res.on('data', d => body += d);
            res.on('end', () => resolve(JSON.parse(body)));
        });
        req.on('error', reject);
        req.end();
    });
}

main();
