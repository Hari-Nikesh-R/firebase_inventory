import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_inventory/src/exceptions/inventory_exceptions.dart';
import 'package:firebase_inventory/src/models/inventory_category.dart';
import 'package:firebase_inventory/src/models/inventory_item.dart';
import 'package:logger/logger.dart';

class FirebaseInventoryService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final Logger _logger;

  FirebaseInventoryService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    Logger? logger,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _logger = logger ?? Logger();

  CollectionReference<InventoryItem> get _inventoryCollection =>
      _firestore.collection('inventory').withConverter<InventoryItem>(
            fromFirestore: (snapshot, _) =>
                InventoryItem.fromFirestore(snapshot),
            toFirestore: (item, _) => item.toFirestore(),
          );

  CollectionReference<InventoryCategory> get _categoryCollection =>
      _firestore.collection('categories').withConverter<InventoryCategory>(
            fromFirestore: (snapshot, _) =>
                InventoryCategory.fromFirestore(snapshot.id, snapshot.data()!),
            toFirestore: (category, _) => category.toFirestore(),
          );

  Stream<List<InventoryItem>> watchInventory() {
    return _inventoryCollection
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  Future<void> addItem(InventoryItem item) async {
    try {
      await _inventoryCollection.doc(item.id).set(item);
    } catch (e, stackTrace) {
      _logger.e('Error adding item');
      throw InventoryOperationException('Failed to add item: $e');
    }
  }

  Future<void> updateItem(InventoryItem item) async {
    try {
      await _inventoryCollection.doc(item.id).update(item.toFirestore());
    } catch (e, stackTrace) {
      _logger.e('Error updating item');
      throw InventoryOperationException('Failed to update item: $e');
    }
  }

  Future<void> adjustStock(String itemId, int quantityChange) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final docRef = _inventoryCollection.doc(itemId);
        final doc = await transaction.get(docRef);

        if (!doc.exists) {
          throw InventoryNotFoundException('Item $itemId not found');
        }

        final currentStock = doc.data()!.stock;
        final newStock = currentStock + quantityChange;

        if (newStock < 0) {
          throw InventoryStockException('Insufficient stock');
        }

        transaction.update(docRef, {'stock': newStock});
      });
    } catch (e, stackTrace) {
      _logger.e('Error adjusting stock');
      rethrow;
    }
  }

  Future<List<InventoryCategory>> getCategories() async {
    try {
      final snapshot = await _categoryCollection.get();
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e, stackTrace) {
      _logger.e('Error getting categories', [e, stackTrace]);
      throw InventoryFetchException('Failed to get categories: $e');
    }
  }
}
