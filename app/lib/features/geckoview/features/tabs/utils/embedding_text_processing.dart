/// Removes trailing domain-related text such as '... - Mail' or '... | News'
/// If there's not enough information remaining after, we keep the text as is
/// [text] tab title with potential domain information
/// Returns the processed string
String preprocessText(String text) {
  // Matches 'xyz - Domain' or 'xyz | Domain'
  // with a space before and after delimiter
  // or if there are multiple delimiters next to each other
  final delimiters = RegExp(r'(?<=\s)[|–-]+(?=\s)');
  final splitText = text.split(delimiters);

  // ensure there's enough info without the last element
  final hasEnoughInfo =
      splitText.isNotEmpty &&
      splitText.sublist(0, splitText.length - 1).join(' ').length > 5;

  // domain related texts are usually shorter, this takes care of the most common cases
  final isPotentialDomainInfo =
      splitText.length > 1 && splitText.last.length < 20;

  // If both conditions are met, remove the last chunk, filter out empty strings,
  // join on space, trim, and lowercase
  if (hasEnoughInfo && isPotentialDomainInfo) {
    return splitText
        .sublist(0, splitText.length - 1) // everything except the last element
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty) // remove empty strings
        .join(' ') // join with spaces
        .trim(); // remove leading/trailing spaces
  }

  // Otherwise, just return the text
  return text;
}
