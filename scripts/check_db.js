const admin = require('firebase-admin');
const serviceAccount = require('./service-account-key.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function checkDatabase() {
  try {
    console.log('\n🔍 Checking ClayAmour Database...\n');

    // Check products
    const products = await db.collection('products').get();
    console.log(`📦 Products: ${products.size} items`);
    
    if (products.size > 0) {
      const categories = {};
      products.forEach(doc => {
        const cat = doc.data().category;
        categories[cat] = (categories[cat] || 0) + 1;
      });
      Object.entries(categories).forEach(([cat, count]) => {
        console.log(`   - ${cat}: ${count}`);
      });
    }

    // Check users
    const users = await db.collection('users').get();
    console.log(`\n👥 Users: ${users.size}`);
    
    if (users.size > 0) {
      for (const userDoc of users.docs) {
        const cart = await db.collection(`users/${userDoc.id}/cart`).get();
        const favorites = await db.collection(`users/${userDoc.id}/favorites`).get();
        const orders = await db.collection(`users/${userDoc.id}/orders`).get();
        const addresses = await db.collection(`users/${userDoc.id}/addresses`).get();
        
        console.log(`   User: ${userDoc.data().name}`);
        console.log(`      Cart: ${cart.size} | Favorites: ${favorites.size} | Orders: ${orders.size} | Addresses: ${addresses.size}`);
      }
    }

    console.log('\n✅ Database check complete!\n');
    process.exit(0);
  } catch (error) {
    console.error('❌ Error:', error.message);
    process.exit(1);
  }
}

checkDatabase();
