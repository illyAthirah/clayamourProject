const admin = require('firebase-admin');
const serviceAccount = require('./service-account-key.json');

// Initialize Firebase Admin
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

// Products data - Flowers, Characters, and Add-Ons
const products = [
  // Flower Bouquets (8 items)
  { name: "Rose Bouquet", category: "Flowers", price: 150, description: "Beautiful handcrafted clay rose bouquet", featured: true, stock: 10 },
  { name: "Sunflower Bouquet", category: "Flowers", price: 120, description: "Bright and cheerful clay sunflower arrangement", featured: true, stock: 8 },
  { name: "Tulip Bouquet", category: "Flowers", price: 140, description: "Elegant clay tulip bouquet", featured: false, stock: 12 },
  { name: "Mixed Flower Bouquet", category: "Flowers", price: 180, description: "Colorful mixed clay flower arrangement", featured: true, stock: 15 },
  { name: "Lily Bouquet", category: "Flowers", price: 160, description: "Graceful clay lily bouquet", featured: false, stock: 10 },
  { name: "Daisy Bouquet", category: "Flowers", price: 130, description: "Fresh and vibrant clay daisy bouquet", featured: true, stock: 9 },
  { name: "Orchid Bouquet", category: "Flowers", price: 170, description: "Exotic clay orchid arrangement", featured: false, stock: 7 },
  { name: "Peony Bouquet", category: "Flowers", price: 155, description: "Romantic clay peony bouquet", featured: true, stock: 11 },

  // Character Bouquets (8 items)
  { name: "Stitch Bouquet", category: "Characters", price: 200, description: "Adorable Stitch character clay bouquet", featured: true, stock: 5 },
  { name: "Hello Kitty Bouquet", category: "Characters", price: 190, description: "Cute Hello Kitty clay bouquet", featured: true, stock: 6 },
  { name: "Minion Bouquet", category: "Characters", price: 195, description: "Fun Minion character clay bouquet", featured: false, stock: 8 },
  { name: "Pokemon Bouquet", category: "Characters", price: 210, description: "Cute Pokemon character clay bouquet", featured: true, stock: 4 },
  { name: "Mickey Mouse Bouquet", category: "Characters", price: 205, description: "Classic Mickey Mouse clay bouquet", featured: true, stock: 6 },
  { name: "Winnie the Pooh Bouquet", category: "Characters", price: 185, description: "Adorable Winnie the Pooh clay bouquet", featured: false, stock: 7 },
  { name: "Snoopy Bouquet", category: "Characters", price: 195, description: "Lovable Snoopy character clay bouquet", featured: true, stock: 5 },
  { name: "Doraemon Bouquet", category: "Characters", price: 200, description: "Cute Doraemon character clay bouquet", featured: false, stock: 6 },

  // Add-Ons (6 items)
  { name: "Greeting Card", category: "Add-Ons", price: 15, description: "Personalized greeting card for your bouquet", featured: false, stock: 50 },
  { name: "Gift Box", category: "Add-Ons", price: 25, description: "Premium gift box packaging", featured: false, stock: 30 },
  { name: "Ribbon Decoration", category: "Add-Ons", price: 10, description: "Beautiful ribbon decoration", featured: false, stock: 40 },
  { name: "LED Lights", category: "Add-Ons", price: 35, description: "Decorative LED lights", featured: false, stock: 20 },
  { name: "Personalized Tag", category: "Add-Ons", price: 12, description: "Custom name tag for your bouquet", featured: false, stock: 45 },
  { name: "Gift Bag", category: "Add-Ons", price: 20, description: "Elegant gift bag packaging", featured: false, stock: 35 },

  // Single (3 items)
  { name: "Rose", category: "Custom", price: 2, description: "Single rose", featured: false, stock: 50 },
  { name: "Orchid", category: "Custom", price: 2, description: "Single orchid", featured: false, stock: 30 },
  { name: "Lily", category: "Custom", price: 2, description: "Single lily", featured: false, stock: 40 }
];

// Main seeding function
async function seedDatabase() {
  try {
    console.log('\n🚀 Starting ClayAmour Database Setup...\n');

    // Check if products already exist
    const existingProducts = await db.collection('products').limit(1).get();
    
    if (!existingProducts.empty) {
      console.log('⚠️  Products collection already exists!');
      const choice = process.argv[2];
      
      if (choice === '--force' || choice === '-f') {
        console.log('🔄 Force flag detected. Clearing existing products...');
        const snapshot = await db.collection('products').get();
        const batch = db.batch();
        snapshot.docs.forEach(doc => batch.delete(doc.ref));
        await batch.commit();
        console.log('✅ Cleared existing products\n');
      } else {
        console.log('ℹ️  Use --force or -f to overwrite existing data');
        console.log('📊 Current products count:', (await db.collection('products').get()).size);
        process.exit(0);
      }
    }

    // Seed products
    console.log('📦 Adding products...');
    const batch = db.batch();
    const productsRef = db.collection('products');
    
    products.forEach((product) => {
      const docRef = productsRef.doc();
      batch.set(docRef, {
        ...product,
        createdAt: admin.firestore.FieldValue.serverTimestamp()
      });
    });
    
    await batch.commit();
    console.log(`✅ Added ${products.length} products`);

    // Summary
    const categoryCounts = products.reduce((acc, p) => {
      acc[p.category] = (acc[p.category] || 0) + 1;
      return acc;
    }, {});

    console.log('\n📊 Database Summary:');
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log(`Total Products: ${products.length}`);
    Object.entries(categoryCounts).forEach(([cat, count]) => {
      console.log(`  ${cat}: ${count} items`);
    });
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    
    console.log('\n✅ Database setup complete!');
    console.log('🔗 View at: https://console.firebase.google.com/project/clayamour04/firestore');
    console.log('\n💡 Next steps:');
    console.log('   1. Run: flutter run');
    console.log('   2. Sign up in the app');
    console.log('   3. Start shopping!\n');
    
    process.exit(0);
  } catch (error) {
    console.error('\n❌ Error setting up database:', error.message);
    process.exit(1);
  }
}

seedDatabase();
