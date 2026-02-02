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
part of 'routes.dart';

@TypedGoRoute<ProfileListRoute>(
  name: 'ProfileListRoute',
  path: '/profiles',
  routes: [
    TypedGoRoute<EditProfileRoute>(name: 'ProfileEditRoute', path: 'edit'),
    TypedGoRoute<ProfileBackupListRoute>(
      name: 'ProfileBackupListRoute',
      path: 'backup_list',
    ),
    TypedGoRoute<RestoreProfileRoute>(
      name: 'RestoreProfileRoute',
      path: 'restore',
    ),
    TypedGoRoute<BackupProfileRoute>(
      name: 'BackupProfileRoute',
      path: 'backup',
    ),
    TypedGoRoute<CreateProfileRoute>(
      name: 'CreateProfileRoute',
      path: 'create',
    ),
  ],
)
class ProfileListRoute extends GoRouteData with $ProfileListRoute {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const ProfileListScreen();
  }
}

class CreateProfileRoute extends GoRouteData with $CreateProfileRoute {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const ProfileEditScreen(profile: null);
  }
}

class EditProfileRoute extends GoRouteData with $EditProfileRoute {
  final String profile;

  const EditProfileRoute({required this.profile});

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return ProfileEditScreen(
      profile: Profile.fromJson(jsonDecode(profile) as Map<String, dynamic>),
    );
  }
}

class BackupProfileRoute extends GoRouteData with $BackupProfileRoute {
  final String profile;

  const BackupProfileRoute({required this.profile});

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return ProfileBackupScreen(
      profile: Profile.fromJson(jsonDecode(profile) as Map<String, dynamic>),
    );
  }
}

class RestoreProfileRoute extends GoRouteData with $RestoreProfileRoute {
  final String backupFilePath;

  const RestoreProfileRoute({required this.backupFilePath});

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return ProfileRestoreScreen(backupFile: File(backupFilePath));
  }
}

class ProfileBackupListRoute extends GoRouteData with $ProfileBackupListRoute {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const ProfileBackupListScreen();
  }
}
