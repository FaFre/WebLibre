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
// Supabase project configuration for the WebLibre native app.
//
// All three values are overridable at build time via `--dart-define` so
// developer / staging / production builds can point at distinct Supabase
// projects without code changes. The defaults match the current dev
// project; the anon key is safe to ship in client binaries by design
// (it's a public JWT bound only to anon Postgres RLS).
abstract final class SupabaseConfig {
  static const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://erddtdugipagetkjojjr.supabase.co',
  );

  static const supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVyZGR0ZHVnaXBhZ2V0a2pvampyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODEzOTMxMzEsImV4cCI6MjA5Njk2OTEzMX0.GGrXn_rbd5TPPYRyPd_GvkZuuCRObIOhz4M87kuIsL0',
  );

  static const accountWebUrl = String.fromEnvironment(
    'ACCOUNT_BACKEND_ORIGIN',
    defaultValue: 'https://account.weblibre.eu',
  );
}
