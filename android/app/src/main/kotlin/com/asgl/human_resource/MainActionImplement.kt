package com.asgl.human_resource

import android.Manifest
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Intent
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.media.AudioAttributes
import android.media.RingtoneManager
import android.net.Uri
import android.os.Build
import android.os.Handler
import android.os.Parcelable
import android.provider.MediaStore
import android.util.Log
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.asgl.human_resource.fingerprint.FingerPrintHelper
import com.google.gson.Gson
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.*
import kotlin.collections.ArrayList

interface MainActionImplement {
    companion object {
        const val JWT = "jwt"
        const val PK_NAME = "pkName"
        const val PASSWORD = "password"
        const val USER_NAME = "userName"
        const val NEW_PICK_TURE = "NEW_PICTURE"
        const val METHOD_CHANNEL: String = "com.asgl.human_resource"
        const val READ_EXTERNAL_REQUEST_CODE: Int = 2609
        const val CALL_PHONE_REQUEST_CODE: Int = 1996
        const val KEY_NAME = "com.asgl.s_conect_fingerprint_key"
    }

    /**
     * @param activity
     * @see MainActivity
     * */
    fun createNotificationChannel(activity: MainActivity) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val name = "S-Connect"
            val descriptionText = "S-Connect"
            val importance = NotificationManager.IMPORTANCE_DEFAULT
            val mChannel = NotificationChannel("ASGL ID Channel", name, importance)
            mChannel.description = descriptionText
            val audioAttributes = AudioAttributes.Builder()
                    .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                    .setUsage(AudioAttributes.USAGE_ALARM)
                    .build()
            mChannel.setSound(RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION), audioAttributes)
            mChannel.enableVibration(true)
            mChannel.enableLights(true)
            mChannel.lockscreenVisibility = Notification.VISIBILITY_PUBLIC
            mChannel.vibrationPattern = longArrayOf(0, 250, 250, 250)
            val notificationManager = activity.getSystemService(FlutterActivity.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(mChannel)
        }
    }

    /**
     * Khởi tạo channel platform để giao tiếp với Flutter
     * @param activity
     * @see MainActivity
     * @param flutterEngine
     * @see FlutterEngine
     * */
    fun initNativeChannel(activity: MainActivity, flutterEngine: FlutterEngine?) {
        activity.methodChannel = MethodChannel(flutterEngine?.dartExecutor?.binaryMessenger, METHOD_CHANNEL)
        activity.methodChannel?.setMethodCallHandler { call, result ->
            activity.result = result
            when {
                call.method == "com.asgl.human_resource.checkAppInstalled" -> getPgkNameInstalled(activity, call)
                call.method == "com.asgl.human_resource.openOtherApp" -> openAppWithPkgName(activity, call)
                call.method == "com.asgl.human_resource.createCallPhone" -> checkPermissionCallPhone(activity, call)
                call.method == "com.asgl.human_resource.fingerprints" -> authenticateWithFingerprint(activity, flutterEngine, call)
                call.method == "com.asgl.human_resource.getDataOpenApp" -> getDataOnNewIntent(activity, result)
                else -> result.success(true)
            }
        }
    }

    //Lấy dữ liệu JWT trong Intent nếu có
    private fun getDataOnNewIntent(activity: MainActivity, result: MethodChannel.Result) {
        val intent = activity.intent
        if (intent != null && intent.hasExtra("jwt") && intent.hasExtra("password") && intent.hasExtra("userName")) {
            val jwt = intent.getStringExtra("jwt")
            val password = intent.getStringExtra("password")
            val userName = intent.getStringExtra("userName")
            if (jwt == null || jwt == "" || password == null || password == "" || userName == null || userName == "") {
                result.success("")
            } else result.success(mapOf("jwt" to jwt, "password" to password, "userName" to userName))
        } else {
            result.success("")
        }
    }

    //Xác thực vân tay
    fun authenticateWithFingerprint(activity: MainActivity, flutterEngine: FlutterEngine?, call: MethodCall) {
        val obligatoryCreateKey = call.argument<Boolean>("obligatoryCreateKey") ?: false
        activity.result?.success(true)
        val helper = FingerPrintHelper(activity)
        helper.initFingerPrint(flutterEngine!!, obligatoryCreateKey = obligatoryCreateKey)
    }

    /**
     * Kiểm tra quyền tạo cuộc gọi trước khi thực hiện cuộc gọi
     * @param activity
     * @see MainActivity
     * @param call
     * @see MethodCall
     * */
    fun checkPermissionCallPhone(activity: MainActivity, call: MethodCall) {
        activity.phoneNumber = call.argument<String>("phoneNumber")
        if (ContextCompat.checkSelfPermission(activity.applicationContext, Manifest.permission.CALL_PHONE) != PackageManager.PERMISSION_GRANTED) {
            ActivityCompat.requestPermissions(activity, arrayOf(Manifest.permission.CALL_PHONE), CALL_PHONE_REQUEST_CODE)
            return
        } else {
            createCallPhone(activity)
        }
    }

    /**
     * Yêu cầu quyền đọc bộ nhớ
     * @param activity
     * @see MainActivity
     * */
    fun requestReadPermission(activity: MainActivity) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            if (ContextCompat.checkSelfPermission(activity.applicationContext, Manifest.permission.READ_EXTERNAL_STORAGE) != PackageManager.PERMISSION_GRANTED) {
                ActivityCompat.requestPermissions(activity, arrayOf(Manifest.permission.READ_EXTERNAL_STORAGE), READ_EXTERNAL_REQUEST_CODE)
                return
            } else {
                startListen(activity)
            }
        } else {
            startListen(activity)
        }
    }

    /**
     * Tạo cuộc gọi nếu đã cấp quyền
     * @param activity
     * @see MainActivity
     * */
    fun createCallPhone(activity: MainActivity?) {
        if (activity?.phoneNumber != null && activity.phoneNumber != "") {
            val intent = Intent().apply {
                action = Intent.ACTION_CALL
                flags = Intent.FLAG_ACTIVITY_NEW_TASK
                data = Uri.parse("tel:${activity.phoneNumber}")
            }
            activity.applicationContext.startActivity(intent)
        }
        activity?.result?.success(true)
    }

    /**
     * Mở ứng dung với package name
     * @param activity
     * @see MainActivity
     * @param call
     * @see MethodCall
     * */
    fun openAppWithPkgName(activity: MainActivity?, call: MethodCall) {
        val intentLaunchApp = activity?.packageManager?.getLaunchIntentForPackage(call.argument<String>(PK_NAME)!!)?.apply {
            putExtra(JWT, call.argument<String>(JWT))
            putExtra(PASSWORD, call.argument<String>(PASSWORD))
            putExtra(USER_NAME, call.argument<String>(USER_NAME))
            addFlags(Intent.FLAG_ACTIVITY_CLEAR_TASK)
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }
        activity?.applicationContext?.startActivity(intentLaunchApp)
        activity?.result?.success(true)
    }

    /**
     * Kiểm tra xem package đã được cài đặt hay chưa?
     * @param activity
     * @see MainActivity
     * @param call
     * @see MethodCall
     * */
    fun getPgkNameInstalled(activity: MainActivity, call: MethodCall) {
        val listPackage: List<ApplicationInfo> = activity.packageManager.getInstalledApplications(0)
        var isHasPackageName = false
        listPackage.forEach {
            if (it.packageName == call.argument<String>("pkName")) isHasPackageName = true
        }
        activity.result?.success(isHasPackageName)
    }

    /**
     * Khởi động bộ lắng nghe sự thay đổi event screenshot, take photo
     * @param activity
     * @see MainActivity
     * */
    fun startListen(activity: MainActivity) {
        Handler().postDelayed({
            val imageTableObServer = ImageTableObserver(Handler(), activity)
            activity.contentResolver.registerContentObserver(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, true, imageTableObServer)
            getListImageNew(activity)
        }, 2000)
    }

    /**
     * Lấy ra danh sách ảnh mới nhất trong vòng 5p tính từ thời điểm function được gọi
     * @param activity
     * @see MainActivity
     * */
    private fun getListImageNew(activity: MainActivity) {
        val currentTime = Calendar.getInstance().time
        val timeQuery = currentTime.time - (5 * 60000).toLong()
        val cr = activity.contentResolver
        val cursor = cr.query(MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
                arrayOf(
                        MediaStore.Images.Media.DISPLAY_NAME,
                        MediaStore.Images.Media.DATA,
                        MediaStore.Images.Media._ID,
                        MediaStore.Images.Media.MIME_TYPE,
                        MediaStore.Images.Media.SIZE),
                MediaStore.Images.Media.DATE_TAKEN + ">=?", arrayOf("" + timeQuery), MediaStore.Images.Media.DATE_TAKEN + " DESC")
        val listImageItem: ArrayList<ImageItem> = ArrayList()
        if (cursor != null) {
            cursor.moveToFirst()
            while (!cursor.isAfterLast) {
                val fileName = cursor.getString(cursor.getColumnIndex(MediaStore.Images.Media.DISPLAY_NAME))
                val path = cursor.getString(cursor.getColumnIndex(MediaStore.Images.Media.DATA))
                val id = cursor.getString(cursor.getColumnIndex(MediaStore.Images.Media._ID))
                val mimeType = cursor.getString(cursor.getColumnIndex(MediaStore.Images.Media.MIME_TYPE))
                val size = cursor.getInt(cursor.getColumnIndex(MediaStore.Images.Media.SIZE))
                val imageItem = ImageItem(id, path, fileName, mimeType, size)
                listImageItem.add(imageItem)
                if (listImageItem.size >= 5) {
                    break
                }
                cursor.moveToNext()
            }
        }
        cursor?.close()
        if (listImageItem.size > 0) {
            val gson = Gson()
            val dataSend = gson.toJson(listImageItem)
            activity.methodChannel?.invokeMethod("NEW_ARRAY_IMAGE", dataSend)
        }
    }

    /**
     * Nhận event share image trên Android.
     * @param intent
     * @see Intent
     * */
    fun handleSendIntent(intent: Intent?) {
        when {
            intent?.action == Intent.ACTION_SEND && intent.type?.startsWith("image/") == true -> {
                (intent.getParcelableExtra<Parcelable>(Intent.EXTRA_STREAM) as? Uri)?.let {
                    Log.e("Image uri: ", it.toString())
                }
            }
            intent?.action == Intent.ACTION_SEND_MULTIPLE
                    && intent.type?.startsWith("image/") == true -> {
                intent.getParcelableArrayListExtra<Parcelable>(Intent.EXTRA_STREAM)?.let {
                    it.forEach { uri ->
                        Log.e("Image Uri", uri.toString())
                    }
                }
            }
        }
    }

    /**
     * Gửi ảnh lên Flutter
     * @param activity
     * @see MainActivity
     * @param item is ImageItem
     * @see ImageItem
     * */
    fun sendItem(activity: MainActivity, item: ImageItem) {
        val gson = Gson()
        val dataSend = gson.toJson(item)
        activity.methodChannel?.invokeMethod(NEW_PICK_TURE, dataSend)
    }
}