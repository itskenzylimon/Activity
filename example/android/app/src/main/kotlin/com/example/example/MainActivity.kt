package com.example.example

import android.os.Bundle
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

import java.io.File
import java.io.FileReader
import java.io.FileWriter
import java.io.OutputStream

class MainActivity : FlutterActivity() {
    private val CHANNEL = "activity_mobile_platform_channel"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
                flutterEngine.dartExecutor.binaryMessenger,
                CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "create" -> {
                    val memoryPath = call.argument<String>("memoryPath") ?: "memory.txt"
                    val value = call.argument<String>("value") ?: ""

                    val memory = Memory(memoryPath)

                    val isCreated = memory.create(value)
                    if(isCreated){
                        result.success(isCreated)
                    }else {
                        // Call the appropriate create function in your MapDataCRUD class passing the key and value
                        // For example: mapDataCRUD.create(key, value)
                        result.error("503","Error initializing memory",null) // You can return a result if necessary
                    }
                }

                "read" -> {
                    val memoryPath = call.argument<String>("memoryPath") ?: "memory.txt"
                    val memory = Memory(memoryPath)
                    val value = memory.read()
                    // Call the appropriate read function in your MapDataCRUD class passing the key
                    // For example: val value = mapDataCRUD.read(key)
                    // Return the value or null through the result object
                    result.success(value)
                }

                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    class Memory(private val filePath: String) {
        private var dataType: String? = null

        init {
            loadDataFromFile()
        }

        private fun loadDataFromFile() {
            Log.i("MainActivity:", "at loadDataFromFile")
            val file = File(filePath)
            Log.i("MainActivity:", "at file")
            if (file.exists()) {
                Log.i("MainActivity:", "at file.exists()")
                FileReader(file).use { reader ->
                    dataType = reader.readText()
                }
            } else {
                Log.i("MainActivity:", "at else")
                try {
                    val file = File(filePath)
                    var out = file.outputStream()
                    out.write("".toString().toByteArray())
                    out.flush()
                    out.close()
                    FileReader(file).use { reader ->
                        dataType = reader.readText()
                    }
                } catch (exx: Exception) {
                    Log.i("MainActivity:", "exception occurred")
                    Log.i("MainActivity:", exx.message.toString())
                    exx.printStackTrace()
                }

            }
        }

        private fun saveDataToFile(): Boolean {
            return try {
                FileWriter(filePath).use { writer ->
                    writer.write(dataType)
                }
                true
            }catch (exception:Exception){
                Log.i("MainActivity:", "exception occurred")
                Log.i("MainActivity:", exception.message.toString())
                false
            }
        }

        fun create(value: String): Boolean {
            val file = File(filePath)
            if(file.exists()){
                Log.e("MainActivity:","at create file exists")
                return true;
            }
            Log.e("MainActivity:","at create")
            var isCreated: Boolean = false;
            try {
                dataType = value
                return   saveDataToFile();
            } catch (ex: Exception) {
                ex.printStackTrace()
                Log.e("MainActivity:","create error =="+ex.message)
            }
            Log.e("MainActivity:","at create END")
            return isCreated;
        }

        fun read(): String? {
            return dataType
        }

    }


}