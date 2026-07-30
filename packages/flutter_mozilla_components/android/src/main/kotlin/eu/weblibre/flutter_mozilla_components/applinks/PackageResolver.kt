/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.applinks

import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.content.pm.ResolveInfo
import mozilla.components.support.base.log.logger.Logger
import mozilla.components.support.ktx.android.content.pm.isPackageInstalled
import mozilla.components.support.utils.BrowsersCache
import mozilla.components.support.utils.ext.packageManagerCompatHelper

/**
 * Seam over [PackageManager] and browser detection so the resolver can be unit-tested
 * (see APP_LINKS_OWN_IMPLEMENTATION_PLAN.md §2.7, Phase 1). Intent construction and
 * sanitisation are still exercised under Robolectric because plain JVM stubs never
 * populate the fields the resolver strips.
 */
interface PackageResolver {
    val selfPackageName: String

    /** May throw [RuntimeException] internally on large result sets; returns empty on failure. */
    fun queryActivities(intent: Intent): List<ResolveInfo>

    /** The default activity for [intent], honouring `MATCH_DEFAULT_ONLY`. */
    fun resolveDefaultActivity(intent: Intent): ResolveInfo?

    fun isPackageInstalled(packageName: String): Boolean

    /** True when [packageName] is an installed browser (excluded for engine-supported schemes). */
    fun isInstalledBrowser(packageName: String): Boolean

    fun applicationLabel(resolveInfo: ResolveInfo): String?
}

class AndroidPackageResolver(private val context: Context) : PackageResolver {
    private val logger = Logger("AppLinkPackageResolver")

    override val selfPackageName: String
        get() = context.packageName

    @Suppress("QueryPermissionsNeeded", "TooGenericExceptionCaught")
    override fun queryActivities(intent: Intent): List<ResolveInfo> {
        return try {
            context.packageManagerCompatHelper.queryIntentActivitiesCompat(
                intent,
                PackageManager.GET_RESOLVED_FILTER,
            )
        } catch (e: RuntimeException) {
            // queryIntentActivities throws on very large result sets — treat as "nothing".
            logger.error("failed to query activities", e)
            emptyList()
        }
    }

    @Suppress("TooGenericExceptionCaught")
    override fun resolveDefaultActivity(intent: Intent): ResolveInfo? {
        return try {
            context.packageManagerCompatHelper.resolveActivityCompat(
                intent,
                PackageManager.MATCH_DEFAULT_ONLY,
            )
        } catch (e: RuntimeException) {
            logger.error("failed to resolve default activity", e)
            null
        }
    }

    override fun isPackageInstalled(packageName: String): Boolean {
        return context.packageManagerCompatHelper.isPackageInstalled(packageName)
    }

    override fun isInstalledBrowser(packageName: String): Boolean {
        return BrowsersCache.all(context).isInstalled(packageName)
    }

    @Suppress("TooGenericExceptionCaught")
    override fun applicationLabel(resolveInfo: ResolveInfo): String? {
        return try {
            val appInfo = resolveInfo.activityInfo?.applicationInfo ?: return null
            context.packageManager.getApplicationLabel(appInfo).toString()
        } catch (e: Exception) {
            logger.error("failed to read application label", e)
            null
        }
    }
}
