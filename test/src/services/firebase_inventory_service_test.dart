// // test/src/services/firebase_inventory_service_test.dart
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_inventory/firebase_inventory.dart';
// import 'package:firebase_inventory/src/exceptions/inventory_exceptions.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:mockito/annotations.dart';
// import 'package:mockito/mockito.dart';
//
//
// @GenerateMocks([
//   FirebaseFirestore,
//   FirebaseAuth,
//   DocumentReference,
//   CollectionReference,
//   Transaction,
//   DocumentSnapshot,
//   QuerySnapshot,
//   QueryDocumentSnapshot,
// ])
// void main() {
//   late MockFirebaseFirestore mockFirestore;
//   late MockFirebaseAuth mockAuth;
//   late FirebaseInventoryService service;
//   late MockCollectionReference<InventoryItem> mockInventoryCollection;
//   late MockCollectionReference<InventoryCategory> mockCategoryCollection;
//
//   var testItem = InventoryItem(
//     id: 'item1',
//     name: 'Test Item',
//     description: 'Test Description',
//     price: 9.99,
//     stock: 10,
//     categoryId: 'cat1',
//     createdAt: DateTime(2023, 1, 1),
//   );
//
//   setUp(() {
//     mockFirestore = MockFirebaseFirestore();
//     mockAuth = MockFirebaseAuth();
//     mockInventoryCollection = MockCollectionReference<InventoryItem>();
//     mockCategoryCollection = MockCollectionReference<InventoryCategory>();
//
//     when(mockFirestore.collection('inventory')).thenReturn(mockInventoryCollection);
//     when(mockFirestore.collection('categories')).thenReturn(mockCategoryCollection);
//
//     service = FirebaseInventoryService(
//       firestore: mockFirestore,
//       auth: mockAuth,
//       logger: Logger(printer: PrettyPrinter(printTime: false)),
//     );
//   });
//
//   group('addItem', () {
//     test('should add item to Firestore', () async {
//       final mockDocRef = MockDocumentReference<InventoryItem>();
//       when(mockInventoryCollection.doc(testItem.id)).thenReturn(mockDocRef);
//       when(mockDocRef.set(testItem)).thenAnswer((_) => Future.value());
//
//       await service.addItem(testItem);
//
//       verify(mockInventoryCollection.doc(testItem.id)).called(1);
//       verify(mockDocRef.set(testItem)).called(1);
//     });
//
//     test('should throw InventoryOperationException on error', () async {
//       final mockDocRef = MockDocumentReference<InventoryItem>();
//       when(mockInventoryCollection.doc(testItem.id)).thenReturn(mockDocRef);
//       when(mockDocRef.set(testItem)).thenThrow(FirebaseException(plugin: 'firestore'));
//
//       expect(() => service.addItem(testItem), throwsA(isA<InventoryOperationException>()));
//     });
//   });
//
//   group('adjustStock', () {
//     test('should increase stock successfully', () async {
//       final mockTransaction = MockTransaction();
//       final mockDocRef = MockDocumentReference<InventoryItem>();
//       final mockDocSnapshot = MockDocumentSnapshot<InventoryItem>();
//
//       when(mockInventoryCollection.doc(testItem.id)).thenReturn(mockDocRef);
//       when(mockDocSnapshot.exists).thenReturn(true);
//       when(mockDocSnapshot.data()).thenReturn(testItem);
//       when(mockTransaction.get(mockDocRef)).thenAnswer((_) async => mockDocSnapshot);
//
//       await service.adjustStock(testItem.id, 5);
//
//       verify(mockTransaction.update(mockDocRef, {'stock': 15})).called(1);
//     });
//
//     test('should throw InventoryNotFoundException when item not found', () async {
//       final mockTransaction = MockTransaction();
//       final mockDocRef = MockDocumentReference<InventoryItem>();
//       final mockDocSnapshot = MockDocumentSnapshot<InventoryItem>();
//
//       when(mockInventoryCollection.doc(testItem.id)).thenReturn(mockDocRef);
//       when(mockDocSnapshot.exists).thenReturn(false);
//       when(mockTransaction.get(mockDocRef)).thenAnswer((_) async => mockDocSnapshot);
//
//       expect(
//             () => service.adjustStock(testItem.id, 5),
//         throwsA(isA<InventoryNotFoundException>()),
//       );
//     });
//
//     test('should throw InventoryStockException on negative stock', () async {
//       final mockTransaction = MockTransaction();
//       final mockDocRef = MockDocumentReference<InventoryItem>();
//       final mockDocSnapshot = MockDocumentSnapshot<InventoryItem>();
//
//       when(mockInventoryCollection.doc(testItem.id)).thenReturn(mockDocRef);
//       when(mockDocSnapshot.exists).thenReturn(true);
//       when(mockDocSnapshot.data()).thenReturn(testItem.copyWith(stock: 3));
//       when(mockTransaction.get(mockDocRef)).thenAnswer((_) async => mockDocSnapshot);
//
//       expect(
//             () => service.adjustStock(testItem.id, -5),
//         throwsA(isA<InventoryStockException>()),
//       );
//     });
//   });
//
//   group('getCategories', () {
//     test('should return list of categories', () async {
//       final mockQuerySnapshot = MockQuerySnapshot<InventoryCategory>();
//       final mockDocSnapshot = MockQueryDocumentSnapshot<InventoryCategory>();
//       const category = InventoryCategory(id: 'cat1', name: 'Electronics');
//
//       when(mockCategoryCollection.get()).thenAnswer((_) async => mockQuerySnapshot);
//       when(mockQuerySnapshot.docs).thenReturn([mockDocSnapshot]);
//       when(mockDocSnapshot.data()).thenReturn(category);
//
//       final result = await service.getCategories();
//
//       expect(result, [category]);
//       verify(mockCategoryCollection.get()).called(1);
//     });
//
//     test('should throw InventoryFetchException on error', () async {
//       when(mockCategoryCollection.get()).thenThrow(FirebaseException(plugin: 'firestore'));
//
//       expect(() => service.getCategories(), throwsA(isA<InventoryFetchException>()));
//     });
//   });
//
//   group('watchInventory', () {
//     test('should emit list of items on changes', () async {
//       final mockQuerySnapshot = MockQuerySnapshot<InventoryItem>();
//       final mockDocSnapshot = MockQueryDocumentSnapshot<InventoryItem>();
//
//       when(mockInventoryCollection.snapshots()).thenAnswer((_) => Stream.value(mockQuerySnapshot));
//       when(mockQuerySnapshot.docs).thenReturn([mockDocSnapshot]);
//       when(mockDocSnapshot.data()).thenReturn(testItem);
//
//       expectLater(
//         service.watchInventory(),
//         emitsInOrder([
//           [testItem],
//         ]),
//       );
//     });
//   });
// }