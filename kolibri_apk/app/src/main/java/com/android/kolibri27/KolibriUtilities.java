package com.android.kolibri27;

import android.content.Context;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import java.io.IOException;
import java.net.HttpURLConnection;
import java.net.URL;

public class KolibriUtilities {

	public String exitCodeTranslate(int server_status) {
		switch (server_status) {
			case -7:
				return "Please wait, server is starting up";
			case 0:
				return "Server is running";
			case 1:
				return "Server is stopped (1)";
			case 4:
				return "Server is starting up (4)";
			case 5:
				return "Not responding (5)";
			case 6:
				return "Failed to start (6)";
			case 7:
				return "Unclean shutdown (7)";
			case 8:
				return "Unknown KA Lite running on port (8)";
			case 9:
				return "KA Lite server configuration error (9)";
			case 99:
				return "Could not read PID file (99)";
			case 100:
				return "Invalid PID file (100)";
			case 101:
				return "Could not determine status (101)";
		}
		return "unknown python exit code";
	}

	private boolean isNetworkAvailable(Context context) {
		ConnectivityManager connectivityManager
				= (ConnectivityManager) context.getSystemService(Context.CONNECTIVITY_SERVICE);
		NetworkInfo activeNetworkInfo = connectivityManager.getActiveNetworkInfo();
		return activeNetworkInfo != null && activeNetworkInfo.isConnected();
	}

	public boolean hasInternetAccess(Context context) {
		if (isNetworkAvailable(context)) {
			try {
				HttpURLConnection urlc = (HttpURLConnection)
						(new URL("https://learningequality.org/give/")
								.openConnection());
				urlc.setRequestMethod("HEAD");
				urlc.setRequestProperty("Accept-Encoding", "");
				urlc.setRequestProperty("User-Agent", "Android");
				urlc.setRequestProperty("Connection", "close");
				// Waiting time
				urlc.setConnectTimeout(15000);
				urlc.connect();
				return (urlc.getResponseCode() == 200);
			} catch (IOException e) {
				e.printStackTrace();
			}
		}
		return false;
	}
}
