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
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/wallpaper/domain/entities/home_wallpaper.dart';
import 'package:weblibre/features/wallpaper/domain/providers.dart';
import 'package:weblibre/features/wallpaper/domain/services/wallpaper_store.dart';
import 'package:weblibre/features/wallpaper/presentation/widgets/wallpaper_backdrop.dart';
import 'package:weblibre/presentation/hooks/keyed_state.dart';
import 'package:weblibre/presentation/widgets/browser_page.dart';
import 'package:weblibre/utils/ui_helper.dart';

/// Picks a home wallpaper and tunes its treatment.
///
/// Presentational: it reports changes and never persists them, because its two
/// callers persist differently — the settings screen writes each change
/// straight through, while the container editor stages everything until the
/// form is saved.
///
/// The import itself does happen here, and immediately: the picked file is a
/// transient copy the picker will reclaim, so it has to be taken into the
/// profile before the callback can mean anything. A staged edit the user then
/// abandons therefore leaves a file behind, which is what
/// [WallpaperStore.deleteUnreferenced] is for.
class WallpaperEditor extends HookConsumerWidget {
  /// Name of the current wallpaper, or null when there is none.
  final String? fileName;

  /// Treatment to show and edit. For the container editor these are the
  /// inherited values until the user moves a slider.
  final double blur;
  final double dim;

  /// Called with the new wallpaper's name, or null when it is removed.
  final ValueChanged<String?> onFileChanged;

  final ValueChanged<double> onBlurChanged;
  final ValueChanged<double> onDimChanged;

  /// Shown under the preview when there is no wallpaper — the container editor
  /// uses it to say that the profile-wide one applies instead.
  final String emptyDescription;

  const WallpaperEditor({
    super.key,
    required this.fileName,
    required this.blur,
    required this.dim,
    required this.onFileChanged,
    required this.onBlurChanged,
    required this.onDimChanged,
    this.emptyDescription = 'The home page keeps its default backdrop.',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final importing = useState(false);

    // Live slider values, so dragging updates the preview without a write per
    // frame; re-seeded whenever the persisted value changes underneath.
    final blurValue = useKeyedState(blur, [blur]);
    final dimValue = useKeyedState(dim, [dim]);

    final store = ref.watch(wallpaperStoreProvider);
    final fileName = this.fileName;

    Future<void> pick() async {
      final result = await FilePicker.pickFiles(type: FileType.image);
      if (result.isEmpty) return;

      final path = result.first.path;
      if (path == null) {
        if (context.mounted) {
          showErrorMessage(context, 'That file could not be read');
        }
        return;
      }

      importing.value = true;
      try {
        final imported = await store.import(path);

        // [onFileChanged] writes state this widget does not own — the settings
        // screen's provider, or the container form's staged fields — and a
        // large photo takes long enough to decode that the screen can be gone
        // by now. The imported file is then referenced by nothing, which is
        // exactly what the startup sweep collects.
        if (context.mounted) onFileChanged(imported);
      } on WallpaperImportException catch (e) {
        if (context.mounted) showErrorMessage(context, e.message);
      } finally {
        if (context.mounted) importing.value = false;
      }
    }

    final preview = fileName == null
        ? null
        : HomeWallpaper(
            file: store.resolve(fileName),
            blur: blurValue.value,
            dim: dimValue.value,
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Preview(wallpaper: preview, emptyDescription: emptyDescription),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: FilledButton.tonalIcon(
                onPressed: importing.value ? null : pick,
                icon: importing.value
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(MdiIcons.imageOutline),
                label: Text(fileName == null ? 'Choose image' : 'Replace'),
              ),
            ),
            if (fileName != null) ...[
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: importing.value ? null : () => onFileChanged(null),
                icon: const Icon(Icons.delete_outline),
                label: const Text('Remove'),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        // The sliders stay visible without a wallpaper, disabled: they are what
        // explains what a wallpaper here can look like, and hiding them would
        // make the section jump in size on every pick.
        _TreatmentSlider(
          label: 'Blur',
          icon: MdiIcons.blur,
          travel: homeWallpaperBlurToSlider(blurValue.value),
          enabled: fileName != null,
          onChanged: (travel) =>
              blurValue.value = homeWallpaperBlurFromSlider(travel),
          onChangeEnd: (travel) =>
              onBlurChanged(homeWallpaperBlurFromSlider(travel)),
        ),
        _TreatmentSlider(
          label: 'Dim',
          icon: MdiIcons.brightness6,
          travel: dimValue.value / maxHomeWallpaperDim,
          enabled: fileName != null,
          onChanged: (travel) => dimValue.value = travel * maxHomeWallpaperDim,
          onChangeEnd: (travel) => onDimChanged(travel * maxHomeWallpaperDim),
        ),
        Text(
          'Dim blends the image into the app background, so page text stays '
          'readable in both light and dark themes.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

/// A miniature of the home page, at a phone's proportions.
///
/// Portrait, and not by decoration: the wallpaper is drawn with [BoxFit.cover],
/// so a landscape preview crops a completely different part of the picture than
/// the screen it is previewing — the one thing a preview must not get wrong.
///
/// The content over it is a stand-in for the real home surface's chrome, at the
/// same proportions, because what the dim slider is *for* is keeping that
/// chrome readable. An empty preview cannot show that.
class _Preview extends StatelessWidget {
  final HomeWallpaper? wallpaper;
  final String emptyDescription;

  /// Width of the phone mock. The scale everything inside is drawn at follows
  /// from it, so the miniature stays proportional at any size.
  static const _width = 168.0;
  static const _aspectRatio = 9 / 18.0;

  /// Home is laid out for a ~400dp-wide screen; this is how much of that fits
  /// in the mock.
  static const _scale = _width / 400;

  const _Preview({required this.wallpaper, required this.emptyDescription});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: SizedBox(
        width: _width,
        child: AspectRatio(
          aspectRatio: _aspectRatio,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.6),
              ),
            ),
            child: ClipRRect(
              // Inside the border, so the wallpaper does not overdraw it.
              borderRadius: BorderRadius.circular(19),
              child: wallpaper == null
                  ? _Empty(description: emptyDescription)
                  : WallpaperBackdrop(
                      wallpaper: wallpaper,
                      child: const _HomeMock(scale: _scale),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  final String description;

  const _Empty({required this.description});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              MdiIcons.imageOffOutline,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The home surface's fixed chrome — brand mark, search pill, a section of top
/// sites — at [scale].
///
/// [BrandHeader] is the real one the home page draws, scaled down rather than
/// redrawn, so the preview cannot drift away from what it is previewing. The
/// rest is too entangled with live data to reuse and is mocked at the sizes the
/// real widgets use.
class _HomeMock extends StatelessWidget {
  final double scale;

  const _HomeMock({required this.scale});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16 * scale),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 28 * scale),
          Center(
            child: SizedBox.square(
              dimension: 112 * scale,
              child: FittedBox(child: BrandHeader(colorScheme: colorScheme)),
            ),
          ),
          SizedBox(height: 16 * scale),
          // The home search pill: same shape, height and colour as
          // [HomeSearchPill], without its live search entry.
          Container(
            height: 44 * scale,
            padding: EdgeInsets.symmetric(horizontal: 14 * scale),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(22 * scale),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.search,
                  size: 20 * scale,
                  color: colorScheme.onSurfaceVariant,
                ),
                SizedBox(width: 8 * scale),
                Expanded(
                  child: _Bar(
                    height: 6 * scale,
                    widthFactor: 0.62,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20 * scale),
          // A section header, drawn straight on the wallpaper in theme colours
          // — the thing the dim slider has to keep readable.
          Text(
            'Top sites',
            style: theme.textTheme.titleMedium?.copyWith(
              fontSize: (theme.textTheme.titleMedium?.fontSize ?? 16) * scale,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 12 * scale),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (var i = 0; i < 4; i++)
                Column(
                  children: [
                    Container(
                      width: 48 * scale,
                      height: 48 * scale,
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHigh,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(height: 6 * scale),
                    _Bar(
                      height: 5 * scale,
                      width: 34 * scale,
                      color: colorScheme.onSurface,
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// A stand-in for a line of text: the mock is far too small for real glyphs at
/// these sizes to be anything but noise.
class _Bar extends StatelessWidget {
  final double height;
  final double? width;
  final double widthFactor;
  final Color color;

  const _Bar({
    required this.height,
    required this.color,
    this.width,
    this.widthFactor = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: width == null ? widthFactor : null,
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(height),
          ),
        ),
      ),
    );
  }
}

/// One treatment control, in slider travel rather than in the unit it sets.
///
/// Both sliders read as "none to most" and neither unit means anything to the
/// person dragging it — a sigma least of all — so the label is a percentage of
/// the travel and the caller owns the conversion. That is also what lets blur
/// map through a curve without this widget knowing.
class _TreatmentSlider extends StatelessWidget {
  final String label;
  final IconData icon;
  final double travel;
  final bool enabled;
  final ValueChanged<double> onChanged;
  final ValueChanged<double> onChangeEnd;

  const _TreatmentSlider({
    required this.label,
    required this.icon,
    required this.travel,
    required this.enabled,
    required this.onChanged,
    required this.onChangeEnd,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final clamped = travel.clamp(0.0, 1.0);
    final valueLabel = '${(clamped * 100).round()}%';

    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: enabled
              ? theme.colorScheme.onSurfaceVariant
              : theme.disabledColor,
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 40,
          child: Text(label, style: theme.textTheme.bodyMedium),
        ),
        Expanded(
          child: Slider(
            value: clamped,
            divisions: homeWallpaperSliderDivisions,
            label: valueLabel,
            // Only the drag end is reported outward: a write per frame would
            // hit the settings database dozens of times per gesture.
            onChanged: enabled ? onChanged : null,
            onChangeEnd: enabled ? onChangeEnd : null,
          ),
        ),
        SizedBox(
          width: 44,
          child: Text(
            valueLabel,
            textAlign: TextAlign.end,
            style: theme.textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}
