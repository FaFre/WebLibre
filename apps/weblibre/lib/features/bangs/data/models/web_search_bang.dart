import 'package:weblibre/features/bangs/data/models/bang_data.dart';
import 'package:weblibre/features/bangs/data/models/bang_group.dart';
import 'package:weblibre/features/bangs/data/models/bang_key.dart';

const webSearchBangKey = BangKey(group: BangGroup.weblibre, trigger: 'wl');

bool isWebSearchBang(BangData? bang) =>
    bang != null && bang.toKey() == webSearchBangKey;
