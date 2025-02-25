class InventoryException implements Exception {
  final String message;
  final String code;

  InventoryException(this.message, {this.code = 'UNKNOWN'});

  @override
  String toString() => 'InventoryException: $message (code: $code)';
}

class InventoryOperationException extends InventoryException {
  InventoryOperationException(super.message)
      : super(code: 'OPERATION_FAILED');
}

class InventoryNotFoundException extends InventoryException {
  InventoryNotFoundException(super.message)
      : super(code: 'NOT_FOUND');
}

class InventoryStockException extends InventoryException {
  InventoryStockException(super.message)
      : super(code: 'INSUFFICIENT_STOCK');
}

class InventoryFetchException extends InventoryException {
  InventoryFetchException(super.message)
      : super(code: 'FETCH_FAILED');
}