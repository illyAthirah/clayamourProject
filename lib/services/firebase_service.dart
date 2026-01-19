import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseService {
  static FirebaseAuth get auth => FirebaseAuth.instance;
  static FirebaseFirestore get db => FirebaseFirestore.instance;

  static Stream<User?> authStateChanges() => auth.authStateChanges();

  static User? get currentUser => auth.currentUser;
  static String? get uid => auth.currentUser?.uid;

  static DocumentReference<Map<String, dynamic>> userDoc(String uid) {
    return db.collection('users').doc(uid);
  }

  static CollectionReference<Map<String, dynamic>> products() {
    return db.collection('products');
  }

  static CollectionReference<Map<String, dynamic>> userSubcollection(
    String uid,
    String name,
  ) {
    return userDoc(uid).collection(name);
  }

  static Future<void> ensureUserDoc({
    required String uid,
    required String email,
    required String name,
  }) async {
    final ref = userDoc(uid);
    final snap = await ref.get();
    if (!snap.exists) {
      await ref.set({
        'name': name,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  static Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await credential.user?.updateDisplayName(name);
    await ensureUserDoc(
      uid: credential.user!.uid,
      email: email,
      name: name,
    );
  }

  static Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await auth.signInWithEmailAndPassword(email: email, password: password);
  }

  static Future<void> signOut() async {
    await auth.signOut();
  }

  static Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // If user cancels the sign-in
      if (googleUser == null) {
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final userCredential = await auth.signInWithCredential(credential);

      // Ensure user document exists
      if (userCredential.user != null) {
        await ensureUserDoc(
          uid: userCredential.user!.uid,
          email: userCredential.user!.email ?? '',
          name: userCredential.user!.displayName ?? 'User',
        );
      }

      return userCredential;
    } catch (e) {
      rethrow;
    }
  }
}
