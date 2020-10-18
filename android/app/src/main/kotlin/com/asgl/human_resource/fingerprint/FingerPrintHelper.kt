package com.asgl.human_resource.fingerprint

import android.app.KeyguardManager
import android.content.Context
import android.hardware.fingerprint.FingerprintManager
import android.os.Build
import android.os.CancellationSignal
import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyPermanentlyInvalidatedException
import android.security.keystore.KeyProperties.*
import android.util.Log
import android.widget.Toast
import com.asgl.human_resource.MainActionImplement
import com.asgl.human_resource.MainActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.security.KeyStore
import javax.crypto.Cipher
import javax.crypto.KeyGenerator
import javax.crypto.SecretKey


class FingerPrintHelper(private val activity: MainActivity) : FingerprintManager.AuthenticationCallback() {
    private var cancellationSignal: CancellationSignal? = null
    private var cryptoObject: FingerprintManager.CryptoObject? = null
    private var keyStore: KeyStore? = null
    private var keyGenerator: KeyGenerator? = null
    private var cipher: Cipher? = null
    private var fingerprintManager: FingerprintManager? = null
    private var keyguardManager: KeyguardManager? = null
    private var methodChannel: MethodChannel? = null

    companion object {
        const val AUTH_RESULT = "com.asgl.human_resource.auth_result"
        const val METHOD_CHANNEL = "com.asgl.human_resource.fingerprint_channel"
    }

    fun initFingerPrint(flutterEngine: FlutterEngine, obligatoryCreateKey: Boolean) {
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, METHOD_CHANNEL)
        methodChannel?.setMethodCallHandler { call, result ->
            when {
                call.method == "com.asgl.human_resource.cancel_authenticate" -> {
                    result.success(true)
                    if (cancellationSignal != null && !cancellationSignal!!.isCanceled) {
                        cancellationSignal?.cancel()
                    }
                }
                else -> result.success(true)
            }
        }
        keyguardManager = activity.getSystemService(Context.KEYGUARD_SERVICE) as KeyguardManager
        fingerprintManager = activity.getSystemService(Context.FINGERPRINT_SERVICE) as FingerprintManager
        if (!keyguardManager!!.isKeyguardSecure) {
            methodChannel?.invokeMethod(AUTH_RESULT, -1)//Chưa cài đặt khóa màn hình
            return
        }
        if (!fingerprintManager!!.isHardwareDetected || !fingerprintManager!!.hasEnrolledFingerprints()) {
            methodChannel?.invokeMethod(AUTH_RESULT, -2)//Chưa đăng ký một vân tay cho ứng dụng
            return
        }

        val isGenSuccess = genKey(obligatoryCreateKey)
        if (isGenSuccess && cipherInit()) {
            cryptoObject = FingerprintManager.CryptoObject(cipher!!)
            authenticate(fingerprintManager!!, cryptoObject!!)
        }
    }

    //Khởi tạo key cho authenticate
    //Nếu obligatoryCreateKey = true -> bắt buộc khởi tạo key
    //Ngược lại thì sẽ kiểm tra key trước khi khởi tạo
    private fun genKey(obligatoryCreateKey: Boolean): Boolean {
        try {
            keyStore = KeyStore.getInstance("AndroidKeyStore")
            keyStore?.load(null)
            keyGenerator = KeyGenerator.getInstance(
                    KEY_ALGORITHM_AES,
                    "AndroidKeyStore")
            val keyProperties = PURPOSE_ENCRYPT or PURPOSE_DECRYPT
            if (obligatoryCreateKey) {
                val builder = KeyGenParameterSpec.Builder(MainActionImplement.KEY_NAME, keyProperties)
                        .setBlockModes(BLOCK_MODE_CBC)
                        .setUserAuthenticationRequired(true)
                        .setEncryptionPaddings(ENCRYPTION_PADDING_PKCS7)
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                    builder.setInvalidatedByBiometricEnrollment(true)
                }
                keyGenerator?.run {
                    init(builder.build())
                    generateKey()
                }
            } else {
                if (!keyStore!!.containsAlias(MainActionImplement.KEY_NAME)) {
                    val builder = KeyGenParameterSpec.Builder(MainActionImplement.KEY_NAME, keyProperties)
                            .setBlockModes(BLOCK_MODE_CBC)
                            .setUserAuthenticationRequired(true)
                            .setEncryptionPaddings(ENCRYPTION_PADDING_PKCS7)
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                        builder.setInvalidatedByBiometricEnrollment(true)
                    }
                    keyGenerator?.run {
                        init(builder.build())
                        generateKey()
                    }
                }
            }
            return true
        } catch (ex: Exception) {
            methodChannel?.invokeMethod(AUTH_RESULT, -3)//Lỗ
            Log.e("TAG", ex.toString())// i tạo key
            return false
        }
    }

    private fun cipherInit(): Boolean {
        return try {
//            keyStore?.load(null)
            val cipherString = "$KEY_ALGORITHM_AES/$BLOCK_MODE_CBC/$ENCRYPTION_PADDING_PKCS7"

            cipher = Cipher.getInstance(
                    cipherString)
            val key: SecretKey = keyStore!!.getKey(MainActionImplement.KEY_NAME, null) as SecretKey
            cipher!!.init(Cipher.ENCRYPT_MODE, key)
            true
        } catch (ex: KeyPermanentlyInvalidatedException) {
            methodChannel?.invokeMethod(AUTH_RESULT, -4)//Người dùng cập nhật vân tay
            return false
        } catch (ex: Exception) {
            Log.e("cipher", ex.toString())// i tạo key
            methodChannel?.invokeMethod(AUTH_RESULT, -3)//Lỗi tạo key
            false
        }

    }

    private fun authenticate(manager: FingerprintManager,
                             cryptoObject: FingerprintManager.CryptoObject) {

        cancellationSignal = CancellationSignal()
        manager.authenticate(cryptoObject, cancellationSignal, 0, this, null)
    }

    override fun onAuthenticationError(errMsgId: Int,
                                       errString: CharSequence) {
        if(errMsgId == 7){
            methodChannel?.invokeMethod(AUTH_RESULT, 2)//Xác thực thất bại quá nhiều lần
        }else{
            methodChannel?.invokeMethod(AUTH_RESULT, 3)//thao tác dùng vân tay bị hủy
        }

    }

    override fun onAuthenticationHelp(helpMsgId: Int,
                                      helpString: CharSequence) {
        Toast.makeText(activity.applicationContext,
                "Authentication help\n$helpString",
                Toast.LENGTH_LONG).show()
    }

    override fun onAuthenticationFailed() {
        methodChannel?.invokeMethod(AUTH_RESULT, 0)//Authenticate thất bại
    }

    override fun onAuthenticationSucceeded(
            result: FingerprintManager.AuthenticationResult) {
        methodChannel?.invokeMethod(AUTH_RESULT, 1)//Authenticate thành công
    }
}