# Exotel Masked Number Integration Guide

## Overview
This guide explains how to integrate Exotel's masked number service to protect privacy during consultations between patients and doctors.

## What is Exotel?
Exotel is a cloud communication platform that provides:
- **Masked Numbers**: Virtual numbers that hide real phone numbers
- **Call Tracking**: Track and record calls for quality assurance
- **API-Based**: Easy integration with web/mobile apps
- **Privacy**: Both parties remain anonymous

## Setup Instructions

### 1. Create Exotel Account
1. Visit [https://exotel.com](https://exotel.com)
2. Sign up for a free account
3. Get your credentials from the dashboard

### 2. Get API Credentials
1. Log in to [Exotel Dashboard](https://exotel.com/dashboard)
2. Navigate to **Settings → API Keys**
3. Copy these credentials:
   - **API Key** (like username)
   - **API Token** (like password)
   - **Account SID** (your account ID)
   - **Virtual Number** (masked number to be dialed)

### 3. Configure Environment Variables
Add the following to your `.env` file in the server directory:

```env
# Exotel Configuration
EXOTEL_API_KEY=your_api_key_here
EXOTEL_API_TOKEN=your_api_token_here
EXOTEL_ACCOUNT_SID=your_account_sid_here
EXOTEL_VIRTUAL_NUMBER=08045889186

# Optional: For call recording and advanced features
EXOTEL_ENABLE_RECORDING=true
EXOTEL_WEBHOOK_URL=https://yourdomain.com/webhook/exotel
```

### 4. Backend Implementation

#### Patient Route
**File:** `server/routes/patient.js`
- Endpoint: `GET /patient/emergency/masked/:consultId`
- Returns: Masked number to call doctor
- Privacy: Patient remains anonymous to doctor

#### Doctor Route
**File:** `server/routes/doctor.js`
- Endpoint: `GET /doctor/emergency/masked/:consultId`
- Returns: Masked number to call patient
- Privacy: Doctor remains anonymous to patient

### 5. Frontend Implementation

#### Flutter Call Dialog
**File:** `frontend/lib/patient/screens/patient_consultation_chat_screen.dart`

The `_showMaskedNumberDialog()` method:
- Displays masked number in a dialog
- Provides "Call Now" button
- Uses Flutter's `url_launcher` to open phone dialer
- Shows privacy notice

```dart
// Call the doctor with masked number
Future<void> _handleCall() async {
    // Fetches masked number from backend
    // Shows dialog with number
    // Opens phone dialer
}
```

## How It Works

### Patient Calls Doctor
```
1. Patient clicks "Call Doctor"
2. App fetches masked number from /patient/emergency/masked/:consultId
3. Exotel API generates temporary masked number
4. Dialog shows masked number
5. Phone dialer opens with pre-filled masked number
6. Patient makes call through Exotel's infrastructure
7. Exotel routes call to actual doctor number
8. Doctor sees: Masked number (not patient's real number)
9. Patient sees: Masked number (not doctor's real number)
```

### Doctor Calls Patient
```
1. Doctor clicks "Call Patient"
2. App fetches masked number from /doctor/emergency/masked/:consultId
3. Exotel API generates temporary masked number
4. Phone dialer opens with masked number
5. Doctor makes call through Exotel's infrastructure
6. Exotel routes call to actual patient number
7. Both remain anonymous
```

## API Reference

### generateMaskedNumber(agentPhone, customerPhone, callerId)
**Parameters:**
- `agentPhone` (string): Doctor's phone number
- `customerPhone` (string): Patient's phone number
- `callerId` (string): Virtual number to display (optional)

**Returns:**
```json
{
  "maskedNumber": "08045889186",
  "sessionId": "unique-session-id",
  "success": true
}
```

### Fallback Mechanism
If Exotel API fails:
- Returns default masked number: `08045889186`
- Call can still be made through fallback system
- Error is logged for debugging

## Environment-Specific Configuration

### Development
```env
EXOTEL_API_KEY=test_key_xxxxx
EXOTEL_API_TOKEN=test_token_xxxxx
EXOTEL_ACCOUNT_SID=test_sid_xxxxx
EXOTEL_VIRTUAL_NUMBER=08045889186
```

### Production
Use real credentials from Exotel dashboard

## Testing

### Test on Android
1. Install the app
2. Create emergency consultation
3. Click "Call Doctor"
4. Verify masked number dialog appears
5. Verify phone dialer opens correctly

### Test on iOS
Same as Android - uses native iOS dialer

### Backend Testing
```bash
# Test masked number endpoint (Patient)
curl -H "Authorization: Bearer TOKEN" \
  http://localhost:5000/patient/emergency/masked/consultation_id

# Test masked number endpoint (Doctor)
curl -H "Authorization: Bearer TOKEN" \
  http://localhost:5000/doctor/emergency/masked/consultation_id
```

## Pricing
- Exotel offers pay-per-call pricing
- Each masked call routed = charges based on your plan
- Free tier available for testing: Limited calls/month
- Check [Exotel Pricing](https://exotel.com/pricing)

## Troubleshooting

### Issue: Masked number not generating
**Solution:**
1. Verify API credentials in `.env` file
2. Check Exotel dashboard for API key status
3. Ensure account has active balance
4. Check console logs for error messages

### Issue: Call not connecting
**Solution:**
1. Verify phone numbers are valid
2. Check if numbers are in supported country
3. Ensure Exotel account is active
4. Verify network connectivity

### Issue: Phone dialer not opening
**Solution:**
1. Check `url_launcher` permissions in Flutter
2. Verify phone number format (with country code)
3. Test with native phone app directly

## Security Best Practices

1. **Never log real phone numbers** - Only log masked numbers
2. **Store API credentials securely** - Use environment variables
3. **Validate phone numbers** - Before sending to Exotel
4. **Use HTTPS** - For all API calls
5. **Implement rate limiting** - To prevent abuse
6. **Monitor call logs** - Track for suspicious activity

## Support

- **Exotel Support**: https://exotel.com/support
- **Documentation**: https://exotel.com/docs
- **API Reference**: https://api-doc.exotel.com

## Future Enhancements

1. **Call Recording**: Store consultation recordings
2. **Call Logs**: Display call history in app
3. **Call Quality**: Monitor call quality metrics
4. **IVR Integration**: Automated call routing
5. **SMS Integration**: Fallback communication
