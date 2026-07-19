/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/. */

package eu.weblibre.flutter_mozilla_components.push

import eu.weblibre.flutter_mozilla_components.pigeons.PushDistributor
import eu.weblibre.flutter_mozilla_components.pigeons.PushDistributorStatus
import eu.weblibre.flutter_mozilla_components.pigeons.PushStatus

internal fun PushStatusSnapshot.toPigeon() = PushStatus(
    status = status.toPigeon(),
    current = current?.toPigeon(),
    available = available.map { it.toPigeon() },
    lastError = lastError,
)

internal fun DistributorInfo.toPigeon() =
    PushDistributor(packageName = packageName, label = label)

internal fun DistributorStatus.toPigeon() = when (this) {
    DistributorStatus.NONE_AVAILABLE -> PushDistributorStatus.NONE_AVAILABLE
    DistributorStatus.NOT_SELECTED -> PushDistributorStatus.NOT_SELECTED
    DistributorStatus.PENDING -> PushDistributorStatus.PENDING
    DistributorStatus.READY -> PushDistributorStatus.READY
    DistributorStatus.UNAVAILABLE -> PushDistributorStatus.UNAVAILABLE
}
