class InventoryException implements Exception {
  final String message;
  final String code;

  InventoryException(this.message, {this.code = 'UNKNOWN'});

  @override
  String toString() => 'InventoryException: $message (code: $code)';
}

class InventoryOperationException extends InventoryException {
  InventoryOperationException(String message)
      : super(message, code: 'OPERATION_FAILED');
}

class InventoryNotFoundException extends InventoryException {
  InventoryNotFoundException(String message)
      : super(message, code: 'NOT_FOUND');
}

class InventoryStockException extends InventoryException {
  InventoryStockException(String message)
      : super(message, code: 'INSUFFICIENT_STOCK');
}

class InventoryFetchException extends InventoryException {
  InventoryFetchException(String message)
      : super(message, code: 'FETCH_FAILED');
}