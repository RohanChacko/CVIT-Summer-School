package com.example.sampleapp;

import android.content.ContentValues;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.os.Environment;
import android.provider.MediaStore;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.view.SurfaceView;
import android.view.Window;
import android.view.WindowManager;
import android.support.v7.app.AppCompatActivity;
import android.widget.Toast;

import org.opencv.android.BaseLoaderCallback;
import org.opencv.android.CameraBridgeViewBase;
import org.opencv.android.CameraBridgeViewBase.CvCameraViewFrame;
import org.opencv.android.CameraBridgeViewBase.CvCameraViewListener2;
import org.opencv.android.LoaderCallbackInterface;
import org.opencv.android.OpenCVLoader;
import org.opencv.core.Core;
import org.opencv.core.CvType;
import org.opencv.core.Mat;
import org.opencv.imgproc.Imgproc;
import org.opencv.imgcodecs.Imgcodecs;

import java.io.File;

// OpenCV Classes

public class CameraActivity extends AppCompatActivity implements CvCameraViewListener2 {

    // Used for logging success or failure messages
    private static final String TAG = "OCV::CameraActivity";

    // Loads camera view of OpenCV for us to use. This lets us see using OpenCV
    private CameraBridgeViewBase mOpenCvCameraView;

    // A key for storing the index of the active camera.
    private static final String STATE_CAMERA_INDEX = "cameraIndex";

    //Index of camera
    private int mCameraIndex;

    //Number of cameras for phone
    private int mNumCameras;

    // Whether an asynchronous menu action is in progress.
    // If so, menu interaction should be disabled.
    private boolean mIsMenuLocked;

    // Whether the next camera frame should be saved as a photo.
    private boolean mIsPhotoPending;

    // These variables are used (at the moment) to fix camera orientation from 270degree to 0degree
    Mat mRgba;
    Mat mRgbaF;
    Mat mRgbaT;

    private Mat mBgr;

    private BaseLoaderCallback mLoaderCallback = new BaseLoaderCallback(this) {
        @Override
        public void onManagerConnected(int status) {
            switch (status) {
                case LoaderCallbackInterface.SUCCESS:
                {
                    Log.i(TAG, "OpenCV loaded successfully");
                    mOpenCvCameraView.enableView();
                    mBgr = new Mat();
                } break;
                default:
                {
                    super.onManagerConnected(status);
                } break;
            }
        }
    };


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        Log.i(TAG, "called onCreate");
        super.onCreate(savedInstanceState);
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);

        if (savedInstanceState != null) {
            mCameraIndex = savedInstanceState.getInt(
                    STATE_CAMERA_INDEX, 0);
        } else {
            mCameraIndex = 0;
        }

        setContentView(R.layout.activity_camera);

        mOpenCvCameraView = (CameraBridgeViewBase) findViewById(R.id.show_camera_activity_java_surface_view);

        mOpenCvCameraView.setVisibility(SurfaceView.VISIBLE);

        mOpenCvCameraView.setCvCameraViewListener(this);
    }

    public void onSaveInstanceState(Bundle savedInstanceState) {
        // Save the current camera index.
        savedInstanceState.putInt(STATE_CAMERA_INDEX, mCameraIndex);
        super.onSaveInstanceState(savedInstanceState);
    }

    @Override
    public void onPause()
    {
        super.onPause();
        if (mOpenCvCameraView != null)
            mOpenCvCameraView.disableView();
    }

    @Override
    public void onResume()
    {
        super.onResume();
        if (!OpenCVLoader.initDebug()) {
            Log.d(TAG, "Internal OpenCV library not found. Using OpenCV Manager for initialization");
            OpenCVLoader.initAsync(OpenCVLoader.OPENCV_VERSION_3_0_0, this, mLoaderCallback);
        } else {
            Log.d(TAG, "OpenCV library found inside package. Using it!");
            mLoaderCallback.onManagerConnected(LoaderCallbackInterface.SUCCESS);
            mIsMenuLocked = false;
        }
    }

    public void onDestroy() {
        super.onDestroy();
        if (mOpenCvCameraView != null)
            mOpenCvCameraView.disableView();
    }

    @Override
    public boolean onCreateOptionsMenu(final Menu menu) {
        getMenuInflater().inflate(R.menu.menu_camera, menu);
        mNumCameras = 1;

        //TODO : Fix mNumCameras = Camera.getNumberOfCameras().
        // Need to use new Camera2 API to get value

        if (mNumCameras < 2) {
            // Remove the option to switch cameras, since there is
            // only 1.
            menu.removeItem(R.id.menu_next_camera);
        }
        return true;
    }
    @Override
    public boolean onOptionsItemSelected(final MenuItem item) {
        if (mIsMenuLocked) {
            return true;
        }
        switch (item.getItemId()) {
            case R.id.menu_next_camera:
                mIsMenuLocked = true;
                // With another camera index, recreate the activity.
                mCameraIndex++;
                if (mCameraIndex == mNumCameras) {
                    mCameraIndex = 0;
                }
                recreate();
                return true;
            case R.id.menu_take_photo:
                mIsMenuLocked = true;

                // Next frame, take the photo.
                mIsPhotoPending = true;
                return true;
            default:
                return super.onOptionsItemSelected(item);
        }
    }


    public void onCameraViewStarted(int width, int height) {

        mRgba = new Mat(height, width, CvType.CV_8UC4);
        mRgbaF = new Mat(height, width, CvType.CV_8UC4);
        mRgbaT = new Mat(width, width, CvType.CV_8UC4);
    }

    public void onCameraViewStopped() {
        mRgba.release();
    }

    public Mat onCameraFrame(CvCameraViewFrame inputFrame) {


        mRgba = inputFrame.rgba();

        if (mIsPhotoPending) {
            mIsPhotoPending = false;
            takePhoto(mRgba);
        }

        // Rotate mRgba 90 degrees
        Core.transpose(mRgba, mRgbaT);
        Imgproc.resize(mRgbaT, mRgbaF, mRgbaF.size(), 0,0, 0);
        Core.flip(mRgbaF, mRgba, 1 );

        return mRgba;
    }

    private void takePhoto(final Mat rgba) {

        // Determine the path and metadata for the photo.
        final long currentTimeMillis = System.currentTimeMillis();
        final String appName = getString(R.string.app_name);
        final String galleryPath = Environment.getExternalStoragePublicDirectory(
                        Environment.DIRECTORY_PICTURES).toString();
        final String albumPath = galleryPath + File.separator + "OpenCV";
        final String photoPath = albumPath + File.separator + currentTimeMillis + LabActivity.PHOTO_FILE_EXTENSION;
        final ContentValues values = new ContentValues();

        values.put(MediaStore.MediaColumns.DATA, photoPath);
        values.put(MediaStore.Images.Media.MIME_TYPE, LabActivity.PHOTO_MIME_TYPE);
        values.put(MediaStore.Images.Media.TITLE, appName);
        values.put(MediaStore.Images.Media.DESCRIPTION, appName);
        values.put(MediaStore.Images.Media.DATE_TAKEN, currentTimeMillis);

        // Ensure that the album directory exists.
        File album = new File(albumPath);
        if (!album.isDirectory() && !album.mkdirs()) {
            Log.e(TAG, "Failed to create album directory at " + album);
            Log.e(TAG, Environment.DIRECTORY_PICTURES);
            Log.e(TAG, Boolean.toString(album.exists()));
            onTakePhotoFailed();
            return;
        }

        // Try to create the photo.
        Imgproc.cvtColor(mRgba, mBgr, Imgproc.COLOR_RGBA2BGR, 3);

        if (!Imgcodecs.imwrite(photoPath, mBgr)) {
            Log.e(TAG, "Failed to save photo to " + photoPath);
            onTakePhotoFailed();
        }
        else {
            Log.d(TAG, "Photo saved successfully to " + photoPath);
        }

        // Try to insert the photo into the MediaStore.
        Uri uri;

        try {
            uri = getContentResolver().insert(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, values);
        }
        catch (final Exception e) {
            Log.e(TAG, "Failed to insert photo into MediaStore");
            e.printStackTrace();
            // Since the insertion failed, delete the photo.
            File photo = new File(photoPath);
            if (!photo.delete()) {
                Log.e(TAG, "Failed to delete non-inserted photo");
            }

            onTakePhotoFailed();
            return;
        }

        // Open the photo in LabActivity.
        final Intent intent = new Intent(this, LabActivity.class);
        intent.putExtra(LabActivity.EXTRA_PHOTO_URI, uri);
        intent.putExtra(LabActivity.EXTRA_PHOTO_DATA_PATH,
                photoPath);
        startActivity(intent);
    }

    private void onTakePhotoFailed() {
        mIsMenuLocked = false;
        // Show an error message.
        final String errorMessage = getString(R.string.photo_error_message);
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                Toast.makeText(CameraActivity.this, errorMessage, Toast.LENGTH_SHORT).show();
            }
        });
    }
}

