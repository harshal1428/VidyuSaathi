const fs = require('fs');
const https = require('https');

const PROJECT_ID = 'civicsense-b653c';

async function main() {
    try {
        console.log("Fetching USERS collection documents...");
        const queryUrl = `/v1/projects/${PROJECT_ID}/databases/(default)/documents/USERS/?pageSize=2000`;
        const firestoreRes = await get('firestore.googleapis.com', queryUrl);
        
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
        
        // Filter for officers (not CITIZEN role)
        const officers = flattenedDocs.filter(d => (d.role || '').toUpperCase() !== 'CITIZEN' && (d.role || '').toUpperCase() !== 'USER');
        console.log(`Identified ${officers.length} officers.`);
        
        if (officers.length === 0) {
            console.error("No officers found. Total documents: " + docs.length);
        }
        
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

function getVal(f) {
    if (!f) return '';
    if (f.stringValue !== undefined) return f.stringValue;
    if (f.integerValue !== undefined) return f.integerValue;
    if (f.booleanValue !== undefined) return f.booleanValue;
    if (f.doubleValue !== undefined) return f.doubleValue;
    if (f.timestampValue !== undefined) return f.timestampValue;
    if (f.nullValue !== undefined) return '';
    if (f.mapValue && f.mapValue.fields) {
        return JSON.stringify(f.mapValue.fields);
    }
    if (f.arrayValue && f.arrayValue.values) {
        return f.arrayValue.values.map(getVal).join(';');
    }
    return '';
}

function get(host, path) {
    return new Promise((resolve, reject) => {
        const options = {
            hostname: host,
            path: path,
            method: 'GET'
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
