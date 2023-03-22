import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.os.Environment

class MainActivity: FlutterActivity() {

    private val CHANNEL = "com.flutter.activity/android"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
                call, result ->
            if (call.method == "getAndroidStoragePath") {
                val path = Environment.getExternalStorageDirectory().toString()
                result.success(path)
            } else {
                result.notImplemented()
            }
        }
    }

}
