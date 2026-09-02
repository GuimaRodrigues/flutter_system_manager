import 'dart:async';
import 'dart:io';

abstract interface class NativeProcessRunner {
  Future<ProcessResult> run(
    String executable,
    List<String> arguments, {
    required Duration timeout,
  });
}

class IoNativeProcessRunner implements NativeProcessRunner {
  const IoNativeProcessRunner();

  @override
  Future<ProcessResult> run(
    String executable,
    List<String> arguments, {
    required Duration timeout,
  }) {
    return Process.run(
      executable,
      arguments,
      runInShell: false,
    ).timeout(timeout);
  }
}
