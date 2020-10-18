package com.asgl.human_resource

import android.app.KeyguardManager
import android.content.Intent
import android.content.pm.PackageManager
import android.hardware.fingerprint.FingerprintManager
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import javax.crypto.Cipher

class MainActivity : FlutterActivity(), MainActionImplement {
    var methodChannel: MethodChannel? = null
    var phoneNumber: String? = null
    var result: MethodChannel.Result? = null


    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        handleSendIntent(intent)
        createNotificationChannel(this)
        initNativeChannel(this, this.flutterEngine)
        requestReadPermission(this)
    }

    //Khi có intent share và app được onResume
    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleSendIntent(intent)
        if (intent.hasExtra("jwt") && intent.hasExtra("password") && intent.hasExtra("userName")) {
            val jwt = intent.getStringExtra("jwt")
            val password = intent.getStringExtra("password")
            val userName = intent.getStringExtra("userName")
            if (jwt != null && jwt != "" && password != null && password != "" && userName != null && userName != "") {
                val mapData = mapOf("jwt" to jwt, "password" to password, "userName" to userName)
                methodChannel?.invokeMethod("com.asgl.human_resource.new_intent_jwt", mapData)
            }
        }
    }


    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == MainActionImplement.READ_EXTERNAL_REQUEST_CODE) {
            if (grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                startListen(this)
            }
        } else if (requestCode == MainActionImplement.CALL_PHONE_REQUEST_CODE) {
            if (grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                createCallPhone(this)
            } else {
                this.result?.success(-1)
            }
        }
    }
}
