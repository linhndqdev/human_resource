package com.asgl.human_resource;

import android.database.ContentObserver;
import android.database.Cursor;
import android.net.Uri;
import android.os.Handler;
import android.provider.MediaStore;
import android.util.Log;

public class ImageTableObserver extends ContentObserver {
    /**
     * Main application
     */
    private MainActivity application;

    /**
     * Constructor
     *
     * @param handler Handler for this class
     */
    public ImageTableObserver(Handler handler, MainActivity activity) {
        super(handler);

        this.application = activity;
    }

    /**
     * This function is fired when a change occurs on the image table
     *
     * @param selfChange
     */
    @Override
    public void onChange(boolean selfChange) {

    }

    @Override
    public void onChange(boolean selfChange, Uri uri) {
        if (uri.toString().matches(MediaStore.Images.Media.EXTERNAL_CONTENT_URI.toString() + "/[0-9]+")) {
            Cursor cursor = null;
            try {
                cursor = application.getContentResolver().query(uri, new String[]{
                        MediaStore.Images.Media.DISPLAY_NAME,
                        MediaStore.Images.Media.DATA,
                        MediaStore.Images.Media._ID,
                        MediaStore.Images.Media.MIME_TYPE,
                        MediaStore.Images.Media.SIZE,
                }, null, null, null);
                if (cursor != null && cursor.moveToFirst()) {
                    final String fileName = cursor.getString(cursor.getColumnIndex(MediaStore.Images.Media.DISPLAY_NAME));
                    final String path = cursor.getString(cursor.getColumnIndex(MediaStore.Images.Media.DATA));
                    final String id = cursor.getString(cursor.getColumnIndex(MediaStore.Images.Media._ID));
                    final String mimeType = cursor.getString(cursor.getColumnIndex(MediaStore.Images.Media.MIME_TYPE));
                    final int size = cursor.getInt(cursor.getColumnIndex(MediaStore.Images.Media.SIZE));
                    Log.e("screen shot added ", fileName + " " + path + " " + id + " " + mimeType);
                    ImageItem imageItem = new ImageItem(id, path, fileName, mimeType, size);
                    application.sendItem(application, imageItem);
                }
            } catch (Exception exx) {
                Log.e("Error", exx.getMessage());
            } finally {
                if (cursor != null) {
                    cursor.close();
                }
            }
        }
        super.onChange(selfChange, uri);
    }
}