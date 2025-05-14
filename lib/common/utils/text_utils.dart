String toSentenceCase(String input) {
  if (input.isEmpty) return input;
  
  // Convert entire string to lowercase first
  String lowercased = input.toLowerCase();
  
  // Split into words
  List<String> words = lowercased.split(' ');
  
  // Capitalize first letter of each word
  for (int i = 0; i < words.length; i++) {
    if (words[i].isNotEmpty) {
      words[i] = words[i][0].toUpperCase() + words[i].substring(1);
    }
  }
  
  // Join words back together
  return words.join(' ');
}