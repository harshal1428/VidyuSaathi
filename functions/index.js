const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

// Trigger: Ticket Creation
exports.onTicketCreated = functions.firestore
    .document('TICKETS/{ticketId}')
    .onCreate(async (snap, context) => {
        const ticket = snap.data();
        const ticketId = context.params.ticketId;

        // Notification to Citizen
        // Assuming we store FCM tokens in USERS collection
        const citizenDoc = await admin.firestore().collection('USERS').doc(ticket.citizenId).get();
        const citizenToken = citizenDoc.data().fcmToken;

        if (citizenToken) {
            await admin.messaging().send({
                token: citizenToken,
                notification: {
                    title: 'Ticket Created',
                    body: `Your ticket #${ticketId} has been created successfully.`,
                },
            });
        }

        // Notification to Officers (e.g. Broadcast to region or specific role)
        // This logic depends on assignment rules.
    });

// Trigger: Ticket Assignment
exports.onTicketAssigned = functions.firestore
    .document('TICKETS/{ticketId}')
    .onUpdate(async (change, context) => {
        const newData = change.after.data();
        const oldData = change.before.data();

        // Check if assigned officer changed
        if (newData.assignedOfficerId && newData.assignedOfficerId !== oldData.assignedOfficerId) {
            const officerDoc = await admin.firestore().collection('USERS').doc(newData.assignedOfficerId).get();
            const officerToken = officerDoc.data().fcmToken;

            if (officerToken) {
                await admin.messaging().send({
                    token: officerToken,
                    notification: {
                        title: 'New Task Assigned',
                        body: `Ticket #${context.params.ticketId} has been assigned to you.`,
                    },
                });
            }
        }
    });

// Trigger: Status Update
exports.onTicketStatusUpdate = functions.firestore
    .document('TICKETS/{ticketId}')
    .onUpdate(async (change, context) => {
        const newData = change.after.data();
        const oldData = change.before.data();

        if (newData.status !== oldData.status) {
            // Notify Citizen
            const citizenDoc = await admin.firestore().collection('USERS').doc(newData.citizenId).get();
            const citizenToken = citizenDoc.data().fcmToken;

            if (citizenToken) {
                await admin.messaging().send({
                    token: citizenToken,
                    notification: {
                        title: 'Ticket Status Updated',
                        body: `Your ticket #${context.params.ticketId} is now ${newData.status}.`,
                    },
                });
            }
        }
    });
