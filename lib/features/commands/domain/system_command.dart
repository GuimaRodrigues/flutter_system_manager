import 'dart:collection';

class SystemCommand {
  SystemCommand({
    required this.id,
    required this.title,
    required this.description,
    required this.executable,
    required List<String> arguments,
  }) : arguments = UnmodifiableListView(arguments);

  final String id;
  final String title;
  final String description;
  final String executable;
  final List<String> arguments;
}
