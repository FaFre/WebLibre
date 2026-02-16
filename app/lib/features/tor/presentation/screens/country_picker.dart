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
import 'package:country_codes/country_codes.dart';
import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';

/// Sentinel value returned when the user selects "Automatic" (no country).
/// Distinguished from `null` which means the user navigated back without
/// making a selection.
const automaticCountry = '';

class CountryPickerScreen extends HookWidget {
  const CountryPickerScreen({
    required this.title,
    this.selectedCountryCode,
  });

  final String title;
  final String? selectedCountryCode;

  @override
  Widget build(BuildContext context) {
    final searchController = useTextEditingController();
    final searchQuery = useState('');

    final countries = useMemoized(() {
      return CountryCodes.countryCodes().map((country) {
        final label =
            country.localizedName ??
            country.name ??
            country.alpha2Code ??
            country.countryCode ??
            'Unnamed Country';
        return (alpha2Code: country.alpha2Code, label: label);
      }).toList()
        ..sort((a, b) => a.label.compareTo(b.label));
    });

    final filteredCountries = useMemoized(
      () {
        if (searchQuery.value.isEmpty) return countries;
        final query = searchQuery.value.toLowerCase();
        return countries
            .where((c) => c.label.toLowerCase().contains(query))
            .toList();
      },
      [searchQuery.value, countries],
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search countries...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchQuery.value.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          searchController.clear();
                          searchQuery.value = '';
                        },
                      )
                    : null,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (value) => searchQuery.value = value,
            ),
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: filteredCountries.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            final isSelected = selectedCountryCode == null;
            return ListTile(
              leading: const SizedBox(
                width: 32,
                height: 24,
                child: Center(child: Icon(Icons.public)),
              ),
              title: const Text('Automatic'),
              trailing: isSelected ? const Icon(Icons.check) : null,
              onTap: () => context.pop(automaticCountry),
            );
          }

          final country = filteredCountries[index - 1];
          final isSelected = country.alpha2Code == selectedCountryCode;

          return ListTile(
            leading: country.alpha2Code != null
                ? CountryFlag.fromCountryCode(
                    country.alpha2Code!,
                    theme: const EmojiTheme(size: 28),
                  )
                : const SizedBox(width: 32),
            title: Text(country.label),
            trailing: isSelected ? const Icon(Icons.check) : null,
            onTap: () => context.pop(country.alpha2Code),
          );
        },
      ),
    );
  }
}
