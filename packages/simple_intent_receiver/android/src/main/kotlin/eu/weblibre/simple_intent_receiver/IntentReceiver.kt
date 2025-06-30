package eu.weblibre.simple_intent_receiver

import io.flutter.plugin.common.BinaryMessenger
import eu.weblibre.simple_intent_receiver.pigeons.IntentEvents
import eu.weblibre.simple_intent_receiver.pigeons.Intent as PigeonIntent

class IntentReceiver(messenger: BinaryMessenger) {
    private val intentEvents: IntentEvents = IntentEvents(messenger)

    fun sendIntent(timestamp: Long, intent: PigeonIntent) {
        intentEvents.onIntentReceived(timestamp, intent) { }
    }
}
