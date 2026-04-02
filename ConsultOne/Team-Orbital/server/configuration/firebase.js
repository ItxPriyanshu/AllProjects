const admin = require('firebase-admin');

try {
  let serviceAccount;

  // Check if we are running in production (Render) and have the JSON stringified in an Environment Variable
  if (process.env.FIREBASE_SERVICE_ACCOUNT) {
    serviceAccount = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT);
  } else {
    // Fallback to local file for development
    serviceAccount = require('../consultone-7e371-firebase-adminsdk-fbsvc-a70f9e2df3.json');
  }

  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
  });
  console.log("Firebase Admin Initialized Successfully");
} catch (error) {
  console.error("Firebase Admin Initialization Error:", error);
}

module.exports = admin;
