/*
 * Copyright (c) 2024-2025 Fabian Freund.
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
import 'package:weblibre/core/logger.dart';

const _containerNormal = 0;
const _containerToolbar = 1;
const _containerMenu = 2;
const _containerUnfiled = 3;
const _containerPlaces = 4;

const _exportIndent = '    ';

class _Frame {
  final Map<String, dynamic> folder;
  int containerNesting = 0;
  int lastContainerType = _containerNormal;
  String previousText = '';
  bool inDescription = false;
  String? previousLink;
  Map<String, dynamic>? previousItem;
  DateTime? previousDateAdded;
  DateTime? previousLastModifiedDate;

  _Frame(this.folder);
}

class BookmarkHTMLUtils {
  final GeckoBookmarksService _service;

  BookmarkHTMLUtils(this._service);

  /// Import bookmarks from HTML string
  Future<int> importFromHTML(String htmlString, {bool replace = false}) async {
    final importer = _BookmarkImporter(_service, replace);
    return await importer.importFromHTML(htmlString);
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

class _BookmarkImporter {
  final GeckoBookmarksService _service;
  final bool _isImportDefaults;
  final Map<String, dynamic> _bookmarkTree;
  final List<_Frame> _frames = [];

  _BookmarkImporter(this._service, this._isImportDefaults)
    : _bookmarkTree = {
        'type': BookmarkNodeType.folder.index,
        'guid': BookmarkRoot.menu.id,
        'children': <Map<String, dynamic>>[],
      } {
    _frames.add(_Frame(_bookmarkTree));
  }

  _Frame get _curFrame => _frames.last;

  Future<int> importFromHTML(String htmlString) async {
    final document = html_parser.parse(htmlString);
    _walkTreeForImport(document.body);
    return await _importBookmarks();
  }

  dom.Node? _nextSibling(dom.Node node) {
    final parent = node.parent;
    if (parent == null) return null;

    final siblings = parent.nodes;
    final index = siblings.indexOf(node);

    if (index != -1 && index + 1 < siblings.length) {
      return siblings[index + 1];
    }

    return null;
  }

  void _walkTreeForImport(dom.Node? node) {
    if (node == null) return;

    dom.Node? current = node;
    dom.Node? next;

    for (;;) {
      if (current?.nodeType == dom.Node.ELEMENT_NODE) {
        _openContainer(current! as dom.Element);
      } else if (current?.nodeType == dom.Node.TEXT_NODE) {
        _appendText(current!.text ?? '');
      }

      if ((next = current?.firstChild) != null) {
        current = next;
        continue;
      }

      for (;;) {
        if (current?.nodeType == dom.Node.ELEMENT_NODE) {
          _closeContainer(current! as dom.Element);
        }
        if (current == node) return;
        if ((next = _nextSibling(current!)) != null) {
          current = next;
          break;
        }
        current = current.parentNode;
      }
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
    final frame = _curFrame;

    frame.previousLink = null;
    frame.lastContainerType = _containerNormal;

    if (frame.containerNesting == 0 && _frames.length > 1) {
      _frames.removeLast();
    }

    if (element.attributes.containsKey('personal_toolbar_folder')) {
      if (_isImportDefaults) {
        frame.lastContainerType = _containerToolbar;
      }
    } else if (element.attributes.containsKey('bookmarks_menu')) {
      if (_isImportDefaults) {
        frame.lastContainerType = _containerMenu;
      }
    } else if (element.attributes.containsKey('unfiled_bookmarks_folder')) {
      if (_isImportDefaults) {
        frame.lastContainerType = _containerUnfiled;
      }
    } else if (element.attributes.containsKey('places_root')) {
      if (_isImportDefaults) {
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
    final frame = _curFrame;

    frame.previousItem = null;
    frame.previousText = '';

    final href = element.attributes['href']?.trim();
    final dateAdded = element.attributes['add_date']?.trim();
    final lastModified = element.attributes['last_modified']?.trim();
    final tags = element.attributes['tags']?.trim();
    final keyword = element.attributes['shortcuturl']?.trim();
    final postData = element.attributes['post_data']?.trim();
    final lastCharset = element.attributes['last_charset']?.trim();

    if (href == null || href.isEmpty) {
      frame.previousLink = null;
      return;
    }

    try {
      final uri = Uri.parse(href);
      if (!uri.hasScheme) {
        frame.previousLink = null;
        return;
      }
      frame.previousLink = uri.toString();
    } catch (e) {
      frame.previousLink = null;
      return;
    }

    final bookmark = <String, dynamic>{'url': frame.previousLink};

    if (dateAdded != null) {
      bookmark['dateAdded'] = _convertImportedDateToInternalDate(
        dateAdded,
      ).millisecondsSinceEpoch;
    }
    if (lastModified != null) {
      bookmark['lastModified'] = _convertImportedDateToInternalDate(
        lastModified,
      ).millisecondsSinceEpoch;
    }
    if (dateAdded == null && lastModified != null) {
      bookmark['dateAdded'] = bookmark['lastModified'];
    }

    if (tags != null && tags.isNotEmpty) {
      bookmark['tags'] = tags;
    }
    if (keyword != null && keyword.isNotEmpty) {
      bookmark['keyword'] = keyword;
    }
    if (postData != null && postData.isNotEmpty) {
      bookmark['postData'] = postData;
    }
    if (lastCharset != null && lastCharset.isNotEmpty) {
      bookmark['charset'] = lastCharset;
    }

    (frame.folder['children'] as List).add(bookmark);
    frame.previousItem = bookmark;
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
      _frames.removeLast();
    }
  }

  void _handleHeadEnd() {
    _newFrame();
  }

  void _handleLinkEnd() {
    final frame = _curFrame;
    frame.previousText = frame.previousText.trim();

    if (frame.previousItem != null) {
      frame.previousItem!['title'] = frame.previousText;
    }

    frame.previousText = '';
  }

  void _handleSeparator() {
    final frame = _curFrame;
    final separator = <String, dynamic>{
      'type': BookmarkNodeType.separator.index,
    };
    (frame.folder['children'] as List).add(separator);
    frame.previousItem = separator;
  }

  void _newFrame() {
    final frame = _curFrame;
    final containerTitle = frame.previousText;
    frame.previousText = '';
    final containerType = frame.lastContainerType;

    final folder = <String, dynamic>{
      'children': <Map<String, dynamic>>[],
      'type': BookmarkNodeType.folder.index,
    };

    switch (containerType) {
      case _containerNormal:
        folder['title'] = containerTitle;
      case _containerPlaces:
        folder['guid'] = BookmarkRoot.root.id;
      case _containerMenu:
        folder['guid'] = BookmarkRoot.menu.id;
      case _containerUnfiled:
        folder['guid'] = BookmarkRoot.unfiled.id;
      case _containerToolbar:
        folder['guid'] = BookmarkRoot.toolbar.id;
    }

    (frame.folder['children'] as List).add(folder);

    if (frame.previousDateAdded != null) {
      folder['dateAdded'] = frame.previousDateAdded!.millisecondsSinceEpoch;
      frame.previousDateAdded = null;
    }
    if (frame.previousLastModifiedDate != null) {
      folder['lastModified'] =
          frame.previousLastModifiedDate!.millisecondsSinceEpoch;
      frame.previousLastModifiedDate = null;
    }
    if (!folder.containsKey('dateAdded') &&
        folder.containsKey('lastModified')) {
      folder['dateAdded'] = folder['lastModified'];
    }

    frame.previousItem = folder;
    _frames.add(_Frame(folder));
  }

  DateTime _convertImportedDateToInternalDate(String seconds) {
    try {
      final parsed = int.tryParse(seconds);
      if (parsed != null) {
        return DateTime.fromMillisecondsSinceEpoch(parsed * 1000);
      }
    } catch (e) {
      // Fall through
    }
    return DateTime.now();
  }

  List<Map<String, dynamic>> _getBookmarkTrees() {
    if (!_isImportDefaults) {
      return [_bookmarkTree];
    }

    final bookmarkTrees = <Map<String, dynamic>>[_bookmarkTree];
    final children = _bookmarkTree['children'] as List<Map<String, dynamic>>;

    _bookmarkTree['children'] = children.where((child) {
      final guid = child['guid'] as String?;
      if (guid != null && bookmarkRootIds.contains(guid)) {
        bookmarkTrees.add(child);
        return false;
      }
      return true;
    }).toList();

    return bookmarkTrees;
  }

  Future<int> _importBookmarks() async {
    if (_isImportDefaults) {
      // Delete bookmarks from each root folder (except root itself to avoid errors)
      for (final root in BookmarkRoot.values) {
        if (root != BookmarkRoot.root) {
          await _service.eraseEverything(root);
        }
      }
    }

    final bookmarkTrees = _getBookmarkTrees();
    int bookmarkCount = 0;

    for (final tree in bookmarkTrees) {
      final children = tree['children'] as List?;
      if (children == null || children.isEmpty) continue;

      bookmarkCount += await _insertTree(tree);
    }

    return bookmarkCount;
  }

  Future<int> _insertTree(Map<String, dynamic> node) async {
    int count = 0;
    final children = node['children'] as List?;

    if (children == null || children.isEmpty) return 0;

    final parentGuid = node['guid'] as String;

    for (int i = 0; i < children.length; i++) {
      final child = children[i] as Map<String, dynamic>;
      final type = child['type'] as int? ?? BookmarkNodeType.item.index;

      if (type == BookmarkNodeType.item.index) {
        final url = child['url'] as String?;
        final title = child['title'] as String? ?? '';

        if (url != null && url.isNotEmpty) {
          try {
            final uri = Uri.parse(url);
            if (uri.hasScheme) {
              await _service.addItem(parentGuid, uri, title, i);
              count++;
            }
          } catch (e) {
            logger.e('Failed to import bookmark "$title": $e');
          }
        }
      } else if (type == BookmarkNodeType.folder.index) {
        final title = child['title'] as String? ?? '';
        try {
          final newGuid = await _service.addFolder(parentGuid, title, i);
          child['guid'] = newGuid;
          count += await _insertTree(child);
        } catch (e) {
          logger.e('Failed to import folder "$title": $e');
        }
      }
    }

    return count;
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
