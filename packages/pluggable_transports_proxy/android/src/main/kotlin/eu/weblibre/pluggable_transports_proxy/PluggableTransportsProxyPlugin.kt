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
package eu.weblibre.pluggable_transports_proxy

import IPtProxy.Controller
import eu.weblibre.pluggable_transports_proxy.pigeons.IPtProxyController
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodChannel
import java.io.File

/** PluggableTransportsProxyPlugin */
class PluggableTransportsProxyPlugin : FlutterPlugin {
    private lateinit var channel: MethodChannel

    companion object {
        @Volatile
        private var INSTANCE: Controller? = null

        fun getController(ptDirPath: String): Controller {
            return INSTANCE ?: synchronized(this) {
                INSTANCE ?: Controller(ptDirPath, true, false, "INFO", null).also { INSTANCE = it }
            }
        }
    }

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        val ptDir = File(flutterPluginBinding.applicationContext.cacheDir, "pt_state")
        val ptc = getController(ptDir.path)

        IPtProxyController.setUp(flutterPluginBinding.binaryMessenger, ProxyImpl(controller = ptc))
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        // Controller instance remains alive for reuse
    }
}
