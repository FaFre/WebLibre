// Autogenerated from Pigeon (v25.5.0), do not edit directly.
// See also: https://pub.dev/packages/pigeon
@file:Suppress("UNCHECKED_CAST", "ArrayInDataClass")

package eu.weblibre.simple_intent_receiver.pigeons

import android.util.Log
import io.flutter.plugin.common.BasicMessageChannel
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MessageCodec
import io.flutter.plugin.common.StandardMethodCodec
import io.flutter.plugin.common.StandardMessageCodec
import java.io.ByteArrayOutputStream
import java.nio.ByteBuffer
private object IntentPigeonUtils {

  fun createConnectionError(channelName: String): FlutterError {
    return FlutterError("channel-error",  "Unable to establish connection on channel: '$channelName'.", "")  }
  fun deepEquals(a: Any?, b: Any?): Boolean {
    if (a is ByteArray && b is ByteArray) {
        return a.contentEquals(b)
    }
    if (a is IntArray && b is IntArray) {
        return a.contentEquals(b)
    }
    if (a is LongArray && b is LongArray) {
        return a.contentEquals(b)
    }
    if (a is DoubleArray && b is DoubleArray) {
        return a.contentEquals(b)
    }
    if (a is Array<*> && b is Array<*>) {
      return a.size == b.size &&
          a.indices.all{ deepEquals(a[it], b[it]) }
    }
    if (a is List<*> && b is List<*>) {
      return a.size == b.size &&
          a.indices.all{ deepEquals(a[it], b[it]) }
    }
    if (a is Map<*, *> && b is Map<*, *>) {
      return a.size == b.size && a.all {
          (b as Map<Any?, Any?>).containsKey(it.key) &&
          deepEquals(it.value, b[it.key])
      }
    }
    return a == b
  }
      
}

/**
 * Error class for passing custom error details to Flutter via a thrown PlatformException.
 * @property code The error code.
 * @property message The error message.
 * @property details The error details. Must be a datatype supported by the api codec.
 */
class FlutterError (
  val code: String,
  override val message: String? = null,
  val details: Any? = null
) : Throwable()

/** Generated class from Pigeon that represents data sent in messages. */
data class Intent (
  val fromPackageName: String? = null,
  val action: String? = null,
  val data: String? = null,
  val categories: List<String>,
  val extra: Map<String, Any?>
)
 {
  companion object {
    fun fromList(pigeonVar_list: List<Any?>): Intent {
      val fromPackageName = pigeonVar_list[0] as String?
      val action = pigeonVar_list[1] as String?
      val data = pigeonVar_list[2] as String?
      val categories = pigeonVar_list[3] as List<String>
      val extra = pigeonVar_list[4] as Map<String, Any?>
      return Intent(fromPackageName, action, data, categories, extra)
    }
  }
  fun toList(): List<Any?> {
    return listOf(
      fromPackageName,
      action,
      data,
      categories,
      extra,
    )
  }
  override fun equals(other: Any?): Boolean {
    if (other !is Intent) {
      return false
    }
    if (this === other) {
      return true
    }
    return IntentPigeonUtils.deepEquals(toList(), other.toList())  }

  override fun hashCode(): Int = toList().hashCode()
}
private open class IntentPigeonCodec : StandardMessageCodec() {
  override fun readValueOfType(type: Byte, buffer: ByteBuffer): Any? {
    return when (type) {
      129.toByte() -> {
        return (readValue(buffer) as? List<Any?>)?.let {
          Intent.fromList(it)
        }
      }
      else -> super.readValueOfType(type, buffer)
    }
  }
  override fun writeValue(stream: ByteArrayOutputStream, value: Any?)   {
    when (value) {
      is Intent -> {
        stream.write(129)
        writeValue(stream, value.toList())
      }
      else -> super.writeValue(stream, value)
    }
  }
}

/** Generated class from Pigeon that represents Flutter messages that can be called from Kotlin. */
class IntentEvents(private val binaryMessenger: BinaryMessenger, private val messageChannelSuffix: String = "") {
  companion object {
    /** The codec used by IntentEvents. */
    val codec: MessageCodec<Any?> by lazy {
      IntentPigeonCodec()
    }
  }
  fun onIntentReceived(timestampArg: Long, intentArg: Intent, callback: (Result<Unit>) -> Unit)
{
    val separatedMessageChannelSuffix = if (messageChannelSuffix.isNotEmpty()) ".$messageChannelSuffix" else ""
    val channelName = "dev.flutter.pigeon.simple_intent_receiver.IntentEvents.onIntentReceived$separatedMessageChannelSuffix"
    val channel = BasicMessageChannel<Any?>(binaryMessenger, channelName, codec)
    channel.send(listOf(timestampArg, intentArg)) {
      if (it is List<*>) {
        if (it.size > 1) {
          callback(Result.failure(FlutterError(it[0] as String, it[1] as String, it[2] as String?)))
        } else {
          callback(Result.success(Unit))
        }
      } else {
        callback(Result.failure(IntentPigeonUtils.createConnectionError(channelName)))
      } 
    }
  }
}
