/*
 * Copyright (C) 2010 Google Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy of
 * the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 */

/*
 * Copyright (C) 2012, Anthony Prieur & Daniel Oppenheim. All rights reserved.
 *
 * Original from SL4A modified to allow to embed Interpreter and scripts into an APK
 */

package com.android.kolibri27;

import com.android.kolibri27.config.GlobalConstants;
import com.android.kolibri27.support.Utils;
import com.googlecode.android_scripting.FileUtils;

import java.io.File;
import java.io.InputStream;

import android.util.Log;

import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Intent;
import android.content.res.Resources;
import android.os.AsyncTask;
import android.os.Bundle;
import android.os.Environment;
import android.os.Handler;
import android.os.Message;
import android.widget.Button;
import android.widget.Toast;

import android.os.Build;
import android.content.SharedPreferences;
import android.content.SharedPreferences.Editor;
import android.view.View;
import android.graphics.Color;
import android.widget.ProgressBar;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.TextView;

public class ScriptActivity extends Activity {
    ProgressDialog myProgressDialog;

    private SharedPreferences prefs;
    private SharedPreferences.OnSharedPreferenceChangeListener prefs_listener;
    private Editor editor;
    GlobalValues gv;
    private KolibriUtilities mUtilities;
    private ProgressBar spinner;
    private ProgressBar webProgressBar;
    private WebView wv;
    private TextView ServerStatusTextView;
    private String start_command = "start";
    private boolean isServerRunning = false;
    private Button retryButton;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        mUtilities = new KolibriUtilities();
        GlobalValues.initialize(this);
        gv = GlobalValues.getInstance();

        // set the lauching ui
        setContentView(R.layout.activity_launching);

        spinner = (ProgressBar)findViewById(R.id.progressBar);
        webProgressBar = (ProgressBar)findViewById(R.id.webProgressBar);
        ServerStatusTextView = (TextView)findViewById(R.id.ServerStatus);
        retryButton = (Button) findViewById(R.id.buttonStart);
        retryButton.setVisibility(View.INVISIBLE);

        // install needed ?
        boolean installNeeded = isInstallNeeded();

        if (installNeeded) {
            spinner.setVisibility(View.INVISIBLE);
            new InstallAsyncTask().execute();
        } else {
            runScriptService(start_command);
        }

        wv = (WebView)findViewById(R.id.webview);
        if(GlobalConstants.IS_REMOTE_DEBUGGING){
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
                WebView.setWebContentsDebuggingEnabled(true);
            }
        }
        wv.setVisibility(View.INVISIBLE);
        WebSettings webSettings = wv.getSettings();
        webSettings.setJavaScriptEnabled(true);
        wv.setLayerType(View.LAYER_TYPE_HARDWARE, null);
        wv.setWebViewClient(new WebViewClient(){
            public void onPageFinished(WebView view, String url){
                super.onPageFinished(view, url);
                webProgressBar.setVisibility(View.INVISIBLE);
                if(url.equals("http://0.0.0.0:8080/")){
                    view.setVisibility(View.VISIBLE);
                    view.clearHistory();
                }
            }

            public void onProgressChanged(WebView view, int progress) {
                webProgressBar.setProgress(progress);
                if(progress > 99){
                    webProgressBar.setProgress(0);
                }
            }
        });

        prefs = getSharedPreferences("MyPrefs", MODE_MULTI_PROCESS);
        editor = prefs.edit();
        //clean kolibri_command from before, we are not using SharedPreferences in conventional way.
        editor.clear();
        editor.commit();

        prefs_listener = new SharedPreferences.OnSharedPreferenceChangeListener() {
            public void onSharedPreferenceChanged(SharedPreferences prefs, String key) {
                if(prefs.getBoolean("from_process", false)){
                    editor.putBoolean("from_process", false);
                    int server_status = prefs.getInt("python_exit_code", -7);
                    String kolibri_command = prefs.getString("kolibri_command", "no command yet");

                    if (server_status == 0) {  // 0 means the server is running
                        isServerRunning = true;
                        openWebViewIfAllConditionsMeet();
                    }else{
                        spinner.setVisibility(View.INVISIBLE);
                        ServerStatusTextView.setText(mUtilities.exitCodeTranslate(server_status));
                        ServerStatusTextView.setTextColor(Color.parseColor("#FF9966"));
                        retryButton.setVisibility(View.VISIBLE);
                    }
                }
            }
        };
        prefs.registerOnSharedPreferenceChangeListener(prefs_listener);
    }

    private void openWebViewIfAllConditionsMeet(){
        if(isServerRunning){
            wv.loadUrl("http://0.0.0.0:8080/", null);
            prefs.unregisterOnSharedPreferenceChangeListener(prefs_listener);
        }
    }

    public void restartServer(View view) {
        retryButton.setVisibility(View.INVISIBLE);
        spinner.setVisibility(View.VISIBLE);
        ServerStatusTextView.setText("Retry to start Kolibri ... ");
        runScriptService("start");
    }

    private void sendmsg(String key, String value) {
        Message message = installerHandler.obtainMessage();
        Bundle bundle = new Bundle();
        bundle.putString(key, value);
        message.setData(bundle);
        installerHandler.sendMessage(message);
    }

    final Handler installerHandler = new Handler() {
        @Override
        public void handleMessage(Message message) {
            Bundle bundle = message.getData();

            if (bundle.containsKey("showProgressDialog")) {
                myProgressDialog = ProgressDialog.show(ScriptActivity.this, "Installing", "Loading", true);
            } else if (bundle.containsKey("setMessageProgressDialog")) {
                if (myProgressDialog.isShowing()) {
                    myProgressDialog.setMessage(bundle.getString("setMessageProgressDialog"));
                }
            } else if (bundle.containsKey("dismissProgressDialog")) {
                if (myProgressDialog.isShowing()) {
                    myProgressDialog.dismiss();
                }
            } else if (bundle.containsKey("installSucceed")) {
                Toast toast = Toast.makeText(getApplicationContext(), "Install Succeed", Toast.LENGTH_LONG);
                toast.show();
            } else if (bundle.containsKey("installFailed")) {
                Toast toast = Toast.makeText(getApplicationContext(), "Install Failed. Please check logs.", Toast.LENGTH_LONG);
                toast.show();
            }
        }
    };

    public class InstallAsyncTask extends AsyncTask<Void, Integer, Boolean> {
        @Override
        protected void onPreExecute() {
        }

        @Override
        protected Boolean doInBackground(Void... params) {
            Log.i(GlobalConstants.LOG_TAG, "Installing...");

            // show progress dialog
            sendmsg("showProgressDialog", "");

            sendmsg("setMessageProgressDialog", "Please wait...");
            createOurExternalStorageRootDir();

            // Copy all resources
            copyResourcesToLocal();

            // TODO
            return true;
        }

        @Override
        protected void onProgressUpdate(Integer... values) {
        }

        @Override
        protected void onPostExecute(Boolean installStatus) {
            sendmsg("dismissProgressDialog", "");

            if (installStatus) {
                sendmsg("installSucceed", "");
            } else {
                sendmsg("installFailed", "");
            }

            spinner.setVisibility(View.VISIBLE);
            runScriptService(start_command);
        }

    }

    private void runScriptService(String kolibri_command) {
        if (GlobalConstants.IS_FOREGROUND_SERVICE) {
            startService(new Intent(this, ScriptService.class));
        } else {
            startService(new Intent(this, BackgroundScriptService.class).putExtra("kolibri_command", kolibri_command));
        }
    }

    private void createOurExternalStorageRootDir() {
        Utils.createDirectoryOnExternalStorage(this.getPackageName());
    }

    // quick and dirty: only test a file
    private boolean isInstallNeeded() {
        File testedFile = new File(this.getFilesDir().getAbsolutePath() + "/" + GlobalConstants.PYTHON_MAIN_SCRIPT_NAME);
        if (!testedFile.exists()) {
            return true;
        }
        return false;
    }


    private void copyResourcesToLocal() {
        String name, sFileName;
        InputStream content;

        R.raw a = new R.raw();
        java.lang.reflect.Field[] t = R.raw.class.getFields();
        Resources resources = getResources();

        boolean succeed = true;

        for (int i = 0; i < t.length; i++) {
            if (t[i].getType().getName().equals("int")) {
                try {
                    name = resources.getText(t[i].getInt(a)).toString();
                    sFileName = name.substring(name.lastIndexOf('/') + 1, name.length());
                    content = getResources().openRawResource(t[i].getInt(a));
                    content.reset();

                    // python project
                    if (sFileName.endsWith(GlobalConstants.PYTHON_MAIN_SCRIPT_NAME)) {
                        succeed &= Utils.moveFile(content, this.getFilesDir().getAbsolutePath() + "/" + GlobalConstants.PYTHON_MAIN_SCRIPT_NAME, true);
                    }
                    // python -> /data/data/com.android.kolibri27/files/python
                    else if (sFileName.endsWith(GlobalConstants.PYTHON_ZIP_NAME)) {
                        succeed &= Utils.unzip(content, this.getFilesDir().getAbsolutePath() + "/", true);
                        FileUtils.chmod(new File(this.getFilesDir().getAbsolutePath() + "/python/bin/python"), 0755);
                    }
                    // python extras -> /sdcard/com.android.kolibri27/extras/python
                    else if (sFileName.endsWith(GlobalConstants.PYTHON_EXTRAS_ZIP_NAME)) {
                        Utils.createDirectoryOnExternalStorage(this.getPackageName() + "/" + "extras");
                        Utils.createDirectoryOnExternalStorage(this.getPackageName() + "/" + "extras" + "/" + "tmp");
                        succeed &= Utils.unzip(content, Environment.getExternalStorageDirectory().getAbsolutePath() + "/" + this.getPackageName() + "/extras/", true);
                    }

                } catch (Exception e) {
                    Log.e(GlobalConstants.LOG_TAG, "Failed to copyResourcesToLocal", e);
                    succeed = false;
                }
            }
        } // end for all files in res/raw

    }

    @Override
    protected void onStart() {
        super.onStart();

        String s = "System infos:";
        s += " OS Version: " + System.getProperty("os.version") + "(" + android.os.Build.VERSION.INCREMENTAL + ")";
        s += " | OS API Level: " + android.os.Build.VERSION.SDK;
        s += " | Device: " + android.os.Build.DEVICE;
        s += " | Model (and Product): " + android.os.Build.MODEL + " (" + android.os.Build.PRODUCT + ")";

        Log.i(GlobalConstants.LOG_TAG, s);
    }

}
