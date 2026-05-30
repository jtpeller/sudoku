/// Extensions on the String class to add a few features.
extension StringExtension on String {
  String capitalize() {
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }

  /// Capitalize each word in the string.
  /// 
  /// Hyphens and underscores are included as word delimiters.
  String title() {
    // Split the string by hyphens, underscores, or spaces.
    List<String> words =
        replaceAll(RegExp(r'[_-]'), ' ') // Replace underscores and hyphens with spaces.
            .split(' ') // Split by spaces
            .map((word) => word.trim()) // Trim whitespace
            .where((word) => word.isNotEmpty) // Skip empty words
            .toList();

    // Capitalize the first letter of each word and join with a space.
    return words
        .map(
          (word) => word.isNotEmpty ? word.capitalize() : '',
        )
        .join(' ');
  }
}
