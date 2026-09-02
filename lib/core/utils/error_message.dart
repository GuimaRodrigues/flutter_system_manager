String errorMessage(Object error) {
  final message = error.toString().trim();
  if (message.startsWith('Exception: ')) {
    return message.substring('Exception: '.length);
  }
  return message.isEmpty ? 'An unexpected error occurred.' : message;
}
