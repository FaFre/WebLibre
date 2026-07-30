/*
 * Copyright (c) 2024-2026 Fabian Freund.
 *
 * This file is part of WebLibre
 * (see https://weblibre.eu).
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;
import 'package:weblibre/features/geckoview/features/bookmarks/domain/entities/import_bookmark_node.dart';
import 'package:weblibre/features/geckoview/features/bookmarks/utils/bookmark_importer.dart';

const _containerNormal = 0;
const _containerToolbar = 1;
const _containerMenu = 2;
const _containerUnfiled = 3;
const _containerPlaces = 4;

const _exportIndent = '    ';

/// Parses a Netscape bookmark file into an [ImportBookmarkTree].
///
/// Pure and free of platform channels, so it is safe to run inside an isolate;
/// see `bookmark_import_isolate.dart`.
///
/// When [preserveRootFolders] is set, folders carrying Firefox root markers
/// (`PERSONAL_TOOLBAR_FOLDER`, `BOOKMARKS_MENU`, `UNFILED_BOOKMARKS_FOLDER`,
/// `PLACES_ROOT`) at the top level are routed to the matching Places root
/// instead of being imported as ordinary folders. Everything else lands under
/// [BookmarkRoot.menu].
ImportBookmarkTree parseBookmarkHtml(
  String htmlString, {
  required bool preserveRootFolders,
}) {
  final parser = _BookmarkHtmlParser(preserveRootFolders: preserveRootFolders);
  return parser.parse(htmlString);
}

class BookmarkHTMLUtils {
  final GeckoBookmarksService _service;

  BookmarkHTMLUtils(this._service);

  /// Import bookmarks from HTML string
  Future<int> importFromHTML(String htmlString, {bool replace = false}) {
    final tree = parseBookmarkHtml(htmlString, preserveRootFolders: replace);
    return BookmarkTreeImporter(_service).import(tree, replace: replace);
  }

  /// Export bookmarks to HTML string
  Future<String> exportToHTML({required BookmarkRoot root}) async {
    final tree = await _service.getTree(root.id, recursive: true);
    if (tree == null) {
      throw Exception('Failed to get bookmarks tree');
    }

    final exporter = _BookmarkExporter(tree);
    return exporter.exportToHTML();
  }
}

/// A node collected while parsing.
///
/// Folders stay mutable until their closing tag so children can be appended in
/// place; leaves are immutable as soon as they are complete.
sealed class _ParsedNode {}

final class _ParsedLeaf extends _ParsedNode {
  final ImportBookmarkNode node;

  _ParsedLeaf(this.node);
}

final class _ParsedFolder extends _ParsedNode {
  String title = '';

  /// Set when the folder carried a Firefox root marker, naming the Places root
  /// its children belong to.
  String? rootGuid;
  DateTime? dateAdded;
  DateTime? lastModified;
  final List<_ParsedNode> children = [];
}

/// A bookmark whose `<A>` tag has been opened but whose title text has not been
/// read yet.
class _PendingItem {
  final Uri url;
  final DateTime? dateAdded;
  final DateTime? lastModified;

  _PendingItem({required this.url, this.dateAdded, this.lastModified});
}

/// One level of the document walk: a node and how far through its children the
/// walk has got.
class _WalkFrame {
  final dom.Node node;
  int index = 0;

  _WalkFrame(this.node);
}

class _Frame {
  final _ParsedFolder folder;
  int containerNesting = 0;
  int lastContainerType = _containerNormal;
  String previousText = '';
  bool inDescription = false;
  _PendingItem? pendingItem;
  DateTime? previousDateAdded;
  DateTime? previousLastModifiedDate;

  _Frame(this.folder);
}

class _BookmarkHtmlParser {
  final bool preserveRootFolders;

  final _ParsedFolder _root = _ParsedFolder();
  final List<_Frame> _frames = [];

  int _bookmarkCount = 0;
  int _folderCount = 0;
  int _separatorCount = 0;
  int _skippedUrlCount = 0;

  _BookmarkHtmlParser({required this.preserveRootFolders}) {
    _frames.add(_Frame(_root));
  }

  _Frame get _curFrame => _frames.last;

  ImportBookmarkTree parse(String htmlString) {
    final document = html_parser.parse(htmlString);
    _walkTreeForImport(document.body);

    // Close whatever the document left open so nothing is dropped.
    while (_frames.length > 1) {
      _popFrame();
    }
    _flushPendingItem();

    return _buildTree();
  }

  /// Walks the document depth-first, opening each node on the way down and
  /// closing it on the way back up.
  ///
  /// Keeps its own cursor into every level rather than asking a node for its
  /// next sibling. Locating a sibling means searching the parent's child list,
  /// which is linear, so doing it per step made the walk quadratic in the
  /// number of siblings at a level. A flat bookmark file puts every entry under
  /// a single list, which turned a 25k-bookmark import into hundreds of
  /// millions of comparisons and minutes of parsing.
  void _walkTreeForImport(dom.Node? node) {
    if (node == null) return;

    final stack = <_WalkFrame>[_WalkFrame(node)];
    _enterNode(node);

    while (stack.isNotEmpty) {
      final frame = stack.last;
      final children = frame.node.nodes;

      if (frame.index < children.length) {
        final child = children[frame.index++];
        _enterNode(child);
        stack.add(_WalkFrame(child));
      } else {
        _leaveNode(frame.node);
        stack.removeLast();
      }
    }
  }

  void _enterNode(dom.Node node) {
    if (node.nodeType == dom.Node.ELEMENT_NODE) {
      _openContainer(node as dom.Element);
    } else if (node.nodeType == dom.Node.TEXT_NODE) {
      _appendText(node.text ?? '');
    }
  }

  void _leaveNode(dom.Node node) {
    if (node.nodeType == dom.Node.ELEMENT_NODE) {
      _closeContainer(node as dom.Element);
    }
  }

  void _openContainer(dom.Element element) {
    switch (element.localName) {
      case 'h2':
      case 'h3':
      case 'h4':
      case 'h5':
      case 'h6':
        _handleHeadBegin(element);
      case 'a':
        _handleLinkBegin(element);
      case 'dl':
      case 'ul':
      case 'menu':
        _handleContainerBegin();
      case 'dd':
        _curFrame.inDescription = true;
      case 'hr':
        _handleSeparator();
    }
  }

  void _closeContainer(dom.Element element) {
    final frame = _curFrame;

    if (frame.inDescription) {
      frame.previousText = '';
      frame.inDescription = false;
    }

    switch (element.localName) {
      case 'dl':
      case 'ul':
      case 'menu':
        _handleContainerEnd();
      case 'h2':
      case 'h3':
      case 'h4':
      case 'h5':
      case 'h6':
        _handleHeadEnd();
      case 'a':
        _handleLinkEnd();
    }
  }

  void _appendText(String str) {
    _curFrame.previousText += str;
  }

  void _handleHeadBegin(dom.Element element) {
    // A heading that arrives while the current folder never opened its `<DL>`
    // closes that folder first. Everything below must describe the *new*
    // heading, so the frame is only captured once the stack has settled.
    if (_curFrame.containerNesting == 0 && _frames.length > 1) {
      _popFrame();
    }

    final frame = _curFrame;
    frame.lastContainerType = _containerNormal;

    if (element.attributes.containsKey('personal_toolbar_folder')) {
      if (preserveRootFolders) {
        frame.lastContainerType = _containerToolbar;
      }
    } else if (element.attributes.containsKey('bookmarks_menu')) {
      if (preserveRootFolders) {
        frame.lastContainerType = _containerMenu;
      }
    } else if (element.attributes.containsKey('unfiled_bookmarks_folder')) {
      if (preserveRootFolders) {
        frame.lastContainerType = _containerUnfiled;
      }
    } else if (element.attributes.containsKey('places_root')) {
      if (preserveRootFolders) {
        frame.lastContainerType = _containerPlaces;
      }
    } else {
      final addDate = element.attributes['add_date'];
      if (addDate != null) {
        frame.previousDateAdded = _convertImportedDateToInternalDate(addDate);
      }
      final modDate = element.attributes['last_modified'];
      if (modDate != null) {
        frame.previousLastModifiedDate = _convertImportedDateToInternalDate(
          modDate,
        );
      }
    }
    _curFrame.previousText = '';
  }

  void _handleLinkBegin(dom.Element element) {
    // An unterminated `<A>` must not swallow the one that follows it.
    _flushPendingItem();

    final frame = _curFrame;
    frame.previousText = '';

    // TAGS, SHORTCUTURL, POST_DATA and LAST_CHARSET are read by Firefox but
    // have no representation in Places' bookmark storage, so they are dropped.
    final href = element.attributes['href']?.trim();
    final dateAdded = element.attributes['add_date']?.trim();
    final lastModified = element.attributes['last_modified']?.trim();

    if (href == null || href.isEmpty) {
      _skippedUrlCount++;
      return;
    }

    final Uri url;
    try {
      final uri = Uri.parse(href);
      if (!uri.hasScheme) {
        _skippedUrlCount++;
        return;
      }
      url = uri;
    } catch (e) {
      _skippedUrlCount++;
      return;
    }

    final lastModifiedDate = lastModified != null
        ? _convertImportedDateToInternalDate(lastModified)
        : null;

    frame.pendingItem = _PendingItem(
      url: url,
      // A bookmark that only records a modification time is treated as having
      // been added then, matching Firefox's own importer.
      dateAdded: dateAdded != null
          ? _convertImportedDateToInternalDate(dateAdded)
          : lastModifiedDate,
      lastModified: lastModifiedDate,
    );
  }

  /// Materialises the frame's open bookmark, if any, using [title].
  void _flushPendingItem({String title = ''}) {
    final frame = _curFrame;
    final pending = frame.pendingItem;
    if (pending == null) return;

    frame.pendingItem = null;
    frame.folder.children.add(
      _ParsedLeaf(
        ImportBookmarkItem(
          url: pending.url,
          title: title,
          dateAdded: pending.dateAdded,
          lastModified: pending.lastModified,
        ),
      ),
    );
    _bookmarkCount++;
  }

  /// Completes the innermost folder and hands it to its parent.
  void _popFrame() {
    _flushPendingItem();
    final frame = _frames.removeLast();
    _curFrame.folder.children.add(frame.folder);
  }

  void _handleContainerBegin() {
    _curFrame.containerNesting++;
  }

  void _handleContainerEnd() {
    final frame = _curFrame;
    if (frame.containerNesting > 0) {
      frame.containerNesting--;
    }
    if (_frames.length > 1 && frame.containerNesting == 0) {
      _popFrame();
    }
  }

  void _handleHeadEnd() {
    _newFrame();
  }

  void _handleLinkEnd() {
    final frame = _curFrame;
    _flushPendingItem(title: frame.previousText.trim());
    frame.previousText = '';
  }

  void _handleSeparator() {
    _flushPendingItem();
    _curFrame.folder.children.add(_ParsedLeaf(const ImportBookmarkSeparator()));
    _separatorCount++;
  }

  void _newFrame() {
    _flushPendingItem();

    final frame = _curFrame;
    final containerTitle = frame.previousText;
    frame.previousText = '';

    final folder = _ParsedFolder();

    switch (frame.lastContainerType) {
      case _containerNormal:
        folder.title = containerTitle;
      case _containerPlaces:
        folder.rootGuid = BookmarkRoot.root.id;
      case _containerMenu:
        folder.rootGuid = BookmarkRoot.menu.id;
      case _containerUnfiled:
        folder.rootGuid = BookmarkRoot.unfiled.id;
      case _containerToolbar:
        folder.rootGuid = BookmarkRoot.toolbar.id;
    }

    folder.lastModified = frame.previousLastModifiedDate;
    // As for items, a folder that only records a modification time is treated
    // as having been created then.
    folder.dateAdded = frame.previousDateAdded ?? folder.lastModified;
    frame.previousDateAdded = null;
    frame.previousLastModifiedDate = null;

    _frames.add(_Frame(folder));
  }

  DateTime _convertImportedDateToInternalDate(String seconds) {
    final parsed = int.tryParse(seconds);
    if (parsed != null) {
      return DateTime.fromMillisecondsSinceEpoch(parsed * 1000);
    }
    return DateTime.now();
  }

  /// Groups the parsed top level into per-root sections.
  ///
  /// Only top-level folders carrying a root marker are routed to their own
  /// Places root; a marker deeper in the file describes a folder that Firefox
  /// itself would have nested, so it is imported as an ordinary (untitled)
  /// folder.
  ImportBookmarkTree _buildTree() {
    final menuNodes = <ImportBookmarkNode>[];
    final rootSections = <String, List<ImportBookmarkNode>>{};

    for (final child in _root.children) {
      if (child is _ParsedFolder && child.rootGuid != null) {
        rootSections
            .putIfAbsent(child.rootGuid!, () => <ImportBookmarkNode>[])
            .addAll(child.children.map(_toImmutable));
      } else {
        menuNodes.add(_toImmutable(child));
      }
    }

    final sections = <String, List<ImportBookmarkNode>>{
      if (menuNodes.isNotEmpty) BookmarkRoot.menu.id: menuNodes,
    };
    for (final section in rootSections.entries) {
      sections.update(
        section.key,
        (existing) => existing..addAll(section.value),
        ifAbsent: () => section.value,
      );
    }

    return ImportBookmarkTree(
      sections: sections,
      stats: ImportBookmarkStats(
        bookmarkCount: _bookmarkCount,
        folderCount: _folderCount,
        separatorCount: _separatorCount,
        skippedUrlCount: _skippedUrlCount,
      ),
    );
  }

  ImportBookmarkNode _toImmutable(_ParsedNode node) {
    switch (node) {
      case final _ParsedLeaf leaf:
        return leaf.node;
      case final _ParsedFolder folder:
        _folderCount++;
        return ImportBookmarkFolder(
          title: folder.title,
          children: folder.children.map(_toImmutable).toList(),
          dateAdded: folder.dateAdded,
          lastModified: folder.lastModified,
        );
    }
  }
}

class _BookmarkExporter {
  final BookmarkNode _root;
  final StringBuffer _buffer = StringBuffer();

  _BookmarkExporter(this._root);

  String exportToHTML() {
    _writeHeader();
    _writeContainer(_root);
    return _buffer.toString();
  }

  void _write(String text) {
    _buffer.write(text);
  }

  void _writeLine(String text) {
    _buffer.writeln(text);
  }

  void _writeHeader() {
    _writeLine('<!DOCTYPE NETSCAPE-Bookmark-file-1>');
    _writeLine('<!-- This is an automatically generated file.');
    _writeLine('     It will be read and overwritten.');
    _writeLine('     DO NOT EDIT! -->');
    _writeLine(
      '<META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=UTF-8">',
    );
    _writeLine('<meta http-equiv="Content-Security-Policy"');
    _writeLine(
      '      content="default-src \'self\'; script-src \'none\'; img-src data: *; object-src \'none\'"></meta>',
    );
    _writeLine('<TITLE>Bookmarks</TITLE>');
  }

  void _writeContainer(BookmarkNode item, [String indent = '']) {
    if (item.guid == _root.guid) {
      _writeLine('<H1>${_escapeHtml(item.title ?? 'Bookmarks')}</H1>');
      _writeLine('');
    } else {
      _write('$indent<DT><H3');
      _writeDateAttributes(item);

      if (item.guid == BookmarkRoot.toolbar.id) {
        _write(' PERSONAL_TOOLBAR_FOLDER="true"');
      } else if (item.guid == BookmarkRoot.unfiled.id) {
        _write(' UNFILED_BOOKMARKS_FOLDER="true"');
      }
      _writeLine('>${_escapeHtml(item.title ?? '')}</H3>');
    }

    _writeLine('$indent<DL><p>');
    if (item.children != null) {
      _writeContainerContents(item, indent);
    }
    if (item.guid == _root.guid) {
      _writeLine('$indent</DL>');
    } else {
      _writeLine('$indent</DL><p>');
    }
  }

  void _writeContainerContents(BookmarkNode item, String indent) {
    final localIndent = indent + _exportIndent;

    for (final child in item.children!) {
      if (child.type == BookmarkNodeType.folder) {
        _writeContainer(child, localIndent);
      } else if (child.type == BookmarkNodeType.separator) {
        _writeSeparator(child, localIndent);
      } else {
        _writeItem(child, localIndent);
      }
    }
  }

  void _writeSeparator(BookmarkNode item, String indent) {
    _write('$indent<HR');
    if (item.title != null && item.title!.isNotEmpty) {
      _write(' NAME="${_escapeHtml(item.title!)}"');
    }
    _writeLine('>');
  }

  void _writeItem(BookmarkNode item, String indent) {
    if (item.url == null || item.url!.isEmpty) return;

    try {
      Uri.parse(item.url!);
    } catch (e) {
      return;
    }

    _write('$indent<DT><A HREF="${_escapeUrl(item.url!)}"');
    _writeDateAttributes(item);

    _writeLine('>${_escapeHtml(item.title ?? '')}</A>');
  }

  void _writeDateAttributes(BookmarkNode item) {
    // Convert from microseconds to seconds (UNIX timestamp)
    if (item.dateAdded > 0) {
      _write(' ADD_DATE="${item.dateAdded ~/ 1000000}"');
    }
    if (item.lastModified > 0) {
      _write(' LAST_MODIFIED="${item.lastModified ~/ 1000000}"');
    }
  }

  String _escapeHtml(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#39;');
  }

  String _escapeUrl(String text) {
    return text.replaceAll('"', '%22');
  }
}
