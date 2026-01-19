# Database Setup Guide

## Step-by-Step Instructions to Populate Your Firestore Database

### Option 1: Manual Setup (Easiest)

1. **Go to Firebase Console:**
   - Open https://console.firebase.google.com
   - Select your project: `clayamour04`
   - Click on "Firestore Database" in the left menu

2. **Create Products Collection:**
   - Click "Start collection"
   - Collection ID: `products`
   - Click "Next"

3. **Add Sample Products:**
   For each product, add a document with these fields:

   **Example Product 1:**
   - Document ID: (auto-generated)
   - Fields:
     - `name` (string): "Rose Bouquet"
     - `category` (string): "Flowers"
     - `price` (number): 150
     - `description` (string): "Beautiful handcrafted clay rose bouquet"
     - `featured` (boolean): true
     - `stock` (number): 10
     - `createdAt` (timestamp): (current date/time)

   **Example Product 2:**
   - `name`: "Stitch Bouquet"
   - `category`: "Characters"
   - `price`: 200
   - `description`: "Adorable Stitch character clay bouquet"
   - `featured`: true
   - `stock`: 5
   - `createdAt`: (current date/time)

   Repeat for more products in categories: Flowers, Characters, Add-Ons

### Option 2: Using Script (Advanced)

**Prerequisites:**
- Node.js installed
- Firebase Admin SDK service account key

**Steps:**

1. **Download Service Account Key:**
   ```
   - Go to Firebase Console → Project Settings → Service Accounts
   - Click "Generate new private key"
   - Save as: scripts/service-account-key.json
   ```

2. **Install Dependencies:**
   ```bash
   cd scripts
   npm install
   ```

3. **Run Seeding Script:**
   ```bash
   npm run seed
   ```

### Option 3: Using Firebase Console Import

1. Create a JSON file with your products
2. Go to Firestore Database
3. Import the JSON file

---

## Test Your App

After adding products:

1. **Deploy Security Rules:**
   ```bash
   firebase deploy --only firestore:rules
   ```

2. **Run Your Flutter App:**
   ```bash
   flutter run
   ```

3. **Create Test User:**
   - Sign up in the app
   - This will automatically create a `users/{uid}` document

4. **Test Features:**
   - Browse products (should now appear)
   - Add to favorites (creates `users/{uid}/favorites` subcollection)
   - Add to cart (creates `users/{uid}/cart` subcollection)
   - Place order (creates `users/{uid}/orders` subcollection)

---

## Database Collections Structure

Your Firestore database will have:

```
├── products/                  ← Add these manually first
│   ├── {productId}
│   │   ├── name
│   │   ├── category
│   │   ├── price
│   │   ├── description
│   │   ├── featured
│   │   └── createdAt
│   
└── users/                     ← Created automatically on signup
    └── {userId}
        ├── name
        ├── email
        ├── createdAt
        ├── cart/             ← Created when adding to cart
        ├── favorites/        ← Created when favoriting
        ├── orders/           ← Created when placing order
        └── addresses/        ← Created when adding address
```

---

## Quick Start Checklist

- [ ] Add at least 5 products to Firestore (use Firebase Console)
- [ ] Deploy security rules: `firebase deploy --only firestore:rules`
- [ ] Run app: `flutter run`
- [ ] Sign up a test user
- [ ] Test adding products to cart
- [ ] Test checkout flow
