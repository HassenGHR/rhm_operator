// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../models/user.dart' as app_user;

// class FirebaseService {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   // Initialize Firebase
//   static Future<void> init() async {
//     await Firebase.initializeApp();
//   }

//   // Authentication methods
//   Future<app_user.User?> signInWithEmailAndPassword(
//       String email, String password) async {
//     try {
//       final UserCredential userCredential =
//           await _auth.signInWithEmailAndPassword(
//         email: email,
//         password: password,
//       );

//       if (userCredential.user != null) {
//         return _userFromFirebase(userCredential.user!);
//       }
//       return null;
//     } catch (e) {
//       print('Sign in error: $e');
//       rethrow;
//     }
//   }

//   Future<app_user.User?> createUserWithEmailAndPassword(
//       String email, String password) async {
//     try {
//       final UserCredential userCredential =
//           await _auth.createUserWithEmailAndPassword(
//         email: email,
//         password: password,
//       );

//       if (userCredential.user != null) {
//         // Create user document in Firestore
//         await _createUserDocument(userCredential.user!);
//         return _userFromFirebase(userCredential.user!);
//       }
//       return null;
//     } catch (e) {
//       print('Create user error: $e');
//       rethrow;
//     }
//   }

//   Future<void> signOut() async {
//     await _auth.signOut();
//   }

//   Future<void> resetPassword(String email) async {
//     await _auth.sendPasswordResetEmail(email: email);
//   }

//   app_user.User? get currentUser {
//     final User? firebaseUser = _auth.currentUser;
//     return firebaseUser != null ? _userFromFirebase(firebaseUser) : null;
//   }

//   Stream<app_user.User?> get authStateChanges {
//     return _auth.authStateChanges().map((User? user) {
//       return user != null ? _userFromFirebase(user) : null;
//     });
//   }

//   // Helper method to convert Firebase User to app User
//   app_user.User _userFromFirebase(User firebaseUser) {
//     return app_user.User(
//       id: firebaseUser.uid,
//       email: firebaseUser.email ?? '',
//       displayName: firebaseUser.displayName ?? '',
//     );
//   }

//   // Create user document in Firestore
//   Future<void> _createUserDocument(User user) async {
//     await _firestore.collection('users').doc(user.uid).set({
//       'email': user.email,
//       'name': user.displayName ?? '',
//       'createdAt': FieldValue.serverTimestamp(),
//     });
//   }

//   // Data synchronization methods
//   Future<void> syncUserData(String userId, Map<String, dynamic> data) async {
//     try {
//       await _firestore
//           .collection('users')
//           .doc(userId)
//           .collection('data')
//           .doc('latest')
//           .set({
//         'lastSyncTimestamp': data['lastSyncTimestamp'],
//         'parameters': data['parameters'] ?? [],
//         'readings': data['readings'] ?? [],
//       });
//     } catch (e) {
//       print('Sync error: $e');
//       rethrow;
//     }
//   }

//   Future<Map<String, dynamic>?> fetchUserData(String userId) async {
//     try {
//       final docSnapshot = await _firestore
//           .collection('users')
//           .doc(userId)
//           .collection('data')
//           .doc('latest')
//           .get();

//       if (docSnapshot.exists) {
//         return docSnapshot.data();
//       }
//       return null;
//     } catch (e) {
//       print('Fetch data error: $e');
//       rethrow;
//     }
//   }

//   // User profile methods
//   Future<void> updateUserProfile(String userId, String name) async {
//     try {
//       await _firestore.collection('users').doc(userId).update({
//         'name': name,
//       });

//       // Update display name in Firebase Auth
//       await _auth.currentUser?.updateDisplayName(name);
//     } catch (e) {
//       print('Update profile error: $e');
//       rethrow;
//     }
//   }
// }
