String formatBytes(int bytes) {
  const gibibyte = 1024 * 1024 * 1024;
  const mebibyte = 1024 * 1024;
  if (bytes >= gibibyte) {
    return '${(bytes / gibibyte).toStringAsFixed(1)} GB';
  }
  return '${(bytes / mebibyte).toStringAsFixed(0)} MB';
}
