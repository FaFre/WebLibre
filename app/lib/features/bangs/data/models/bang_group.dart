enum BangGroup {
  general('https://raw.githubusercontent.com/FaFre/bangs/main/data/bangs.json'),
  assistant(
    'https://raw.githubusercontent.com/FaFre/bangs/main/data/assistant_bangs.json',
  ),
  kagi(
    'https://raw.githubusercontent.com/FaFre/bangs/main/data/kagi_bangs.json',
  ),
  custom(
    'https://raw.githubusercontent.com/FaFre/bangs/refs/heads/custom/data/custom.json',
  );

  final String url;

  const BangGroup(this.url);
}
