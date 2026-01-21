# toyyibPay Payment Gateway Setup for ClayAmour

## Why toyyibPay?

✅ **Perfect for Malaysia:**
- 100% Malaysian payment gateway
- Supports FPX (all Malaysian banks)
- Supports e-Wallets (Boost, TNG, GrabPay, ShopeePay)
- Lower fees than international gateways
- Easy setup, no business verification needed for testing
- Supports MYR natively

## Setup Steps

### 1. Create toyyibPay Account
1. Go to https://toyyibpay.com/
2. Click "Sign Up" (or use Dev/Sandbox: https://dev.toyyibpay.com/)
3. Complete registration
4. Verify your email

### 2. Create a Category (Package)
1. Log in to toyyibPay Dashboard
2. Go to **Package Settings** → **Create Package**
3. Fill in:
   - **Package Name:** ClayAmour Store
   - **Package Description:** Clay bouquet orders
   - **Category Status:** Active
4. Save and copy the **Category Code** (e.g., `abc123xyz`)

### 3. Get Secret Key
1. In toyyibPay Dashboard, go to **Settings**
2. Find and copy your **Secret Key**
3. Keep it secure!

### 4. Update the Code
Open `lib/services/toyyibpay_service.dart` and replace:
```dart
static const String _categoryCode = 'YOUR_CATEGORY_CODE';
static const String _secretKey = 'YOUR_SECRET_KEY';
```
With your actual credentials:
```dart
static const String _categoryCode = 'abc123xyz';
static const String _secretKey = 'your-actual-secret-key-here';
```

### 5. Test Payments (Sandbox Mode)
When using **dev.toyyibpay.com** (sandbox):
- All payments are simulated
- Use real bank accounts but money won't be deducted
- Perfect for testing your integration

**Test Flow:**
1. Run your app
2. Add items to cart and checkout
3. Select "toyyibPay" payment method
4. Click "Place Order"
5. Browser will open with toyyibPay payment page
6. Select FPX or e-Wallet
7. Choose any bank (test mode)
8. Complete payment
9. Confirm payment in the app

### 6. Go Live (Production)
When ready for real payments:

1. **Complete KYC Verification:**
   - Submit business documents in dashboard
   - Wait for approval (usually 1-3 days)

2. **Update Code for Production:**
   Open `lib/services/toyyibpay_service.dart` and change:
   ```dart
   // Change from:
   static const String _baseUrl = 'https://dev.toyyibpay.com'; // Sandbox
   
   // To:
   static const String _baseUrl = 'https://toyyibpay.com'; // Production
   ```

3. **Get Production Credentials:**
   - Log in to https://toyyibpay.com (not dev)
   - Create new package/category
   - Get production Secret Key
   - Update code with production credentials

4. **Test with Small Real Transaction**

### 7. Configure Callback URL (Optional but Recommended)
For automatic payment verification:
1. In toyyibPay Dashboard → **Settings** → **Callback URL**
2. Set your callback URL (e.g., `https://yourdomain.com/payment-callback`)
3. toyyibPay will send payment status to this URL

Currently, the app uses a confirmation dialog. For production, consider implementing a proper callback handler.

## Features Available

✅ **FPX Online Banking** (All Malaysian banks)
- Maybank, CIMB, Public Bank, RHB, Hong Leong, etc.
- Instant transfer

✅ **e-Wallets**
- Boost
- Touch 'n Go (TNG)
- GrabPay  
- ShopeePay

✅ **Credit/Debit Cards** (Optional, additional setup)

## Testing the Integration

1. Make sure you're using **dev.toyyibpay.com** in code
2. Run your app: `flutter run`
3. Add items to cart
4. Go to checkout
5. Select "toyyibPay" payment
6. Click "Place Order"
7. Payment page opens in browser
8. Complete payment (no real money charged in sandbox)
9. Return to app and confirm
10. Check order in orders page

## Troubleshooting

**Error: "Failed to create payment"**
- Check if Category Code and Secret Key are correct
- Make sure category is set to "Active" in dashboard
- Verify you're using correct base URL (sandbox vs production)

**Payment page doesn't open**
- Check internet connection
- Ensure `url_launcher` package is installed
- Check if browser is available on device

**Order created but payment pending**
- This is normal - toyyibPay uses callback for confirmation
- In production, implement proper callback handling
- Current version uses manual confirmation dialog

**Cannot find Category Code**
- Log in to toyyibPay dashboard
- Go to Package Settings
- Click on your package
- Category Code is displayed there

## Transaction Fees

**Sandbox/Testing:** FREE  
**Production:**
- FPX: RM 1.00 per transaction
- e-Wallets: 1.5% + RM 0.50
- Credit/Debit Cards: 2.8% + RM 0.50

**Settlement:** T+2 (2 business days)

## Comparison: toyyibPay vs Razorpay vs Stripe

| Feature | toyyibPay | Razorpay | Stripe |
|---------|-----------|----------|--------|
| Malaysian Focus | ✅ Best | ⚠️ Limited | ❌ No |
| FPX Support | ✅ Yes | ⚠️ Via workaround | ❌ No |
| Local e-Wallets | ✅ All major | ⚠️ Some | ❌ No |
| Setup Difficulty | ✅ Easy | ⚠️ Moderate | ❌ Complex |
| Transaction Fees | ✅ RM1-1.5% | ⚠️ 2% | ❌ 2.9% |
| MYR Support | ✅ Native | ✅ Yes | ⚠️ Limited |
| Cloud Functions | ✅ Not needed | ⚠️ Optional | ❌ Required |

## Alternative: Cash on Delivery (COD)

Your app also supports COD which requires no payment gateway:
- Customer pays on delivery
- No setup required
- Good for starting out
- Can be enabled/disabled per order

## Support & Resources

- **toyyibPay Website:** https://toyyibpay.com/
- **Developer Docs:** https://toyyibpay.com/apireference/
- **Support Email:** support@toyyibpay.com
- **WhatsApp:** Available in dashboard

## Security Notes

⚠️ **Never commit your Secret Key to Git:**
```dart
// Bad - Don't do this
static const String _secretKey = 'your-actual-key'; // In public repo

// Good - Use environment variables or secure storage
static const String _secretKey = String.fromEnvironment('TOYYIBPAY_SECRET');
```

For production apps, consider:
1. Store secrets in Firebase Remote Config
2. Use backend server for payment creation
3. Implement webhook callback for automatic verification

## Next Steps

1. ✅ Create toyyibPay account
2. ✅ Get Category Code and Secret Key  
3. ✅ Update code with credentials
4. ✅ Test in sandbox mode
5. ⏳ Complete KYC for production
6. ⏳ Switch to production URL
7. ⏳ Launch!
