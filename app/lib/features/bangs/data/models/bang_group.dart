enum BangGroup {
  general(
    remote:
        'https://raw.githubusercontent.com/FaFre/bangs/main/data/bangs.json',
    bundled: 'assets/bangs/bangs.json',
  ),
  assistant(
    remote:
        'https://raw.githubusercontent.com/FaFre/bangs/main/data/assistant_bangs.json',
    bundled: 'assets/bangs/assistant_bangs.json',
  ),
  kagi(
    remote:
        'https://raw.githubusercontent.com/FaFre/bangs/main/data/kagi_bangs.json',
    bundled: 'assets/bangs/kagi_bangs.json',
  ),
  custom(
    remote:
        'https://raw.githubusercontent.com/FaFre/bangs/refs/heads/custom/data/custom.json',
    bundled: 'assets/bangs/custom.json',
  );

  final String bundled;
  final String remote;

  const BangGroup({required this.bundled, required this.remote});
}
