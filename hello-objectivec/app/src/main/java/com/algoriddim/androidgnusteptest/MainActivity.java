package com.example.helloobjectivec;

import android.content.res.AssetManager;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.view.View;
import android.widget.TextView;

public class MainActivity extends AppCompatActivity {

	// Used to load the 'native-lib' library on application startup.
	static {
		System.loadLibrary("native-lib");
	}

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		initializeGNUstep(getAssets());

		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_main);

		// Example of a call to a native method
		TextView tv = findViewById(R.id.sample_text);
		tv.setText(stringFromObjectiveC());
	}

	public void onThrowObjectiveCException(View v) {
		throwObjectiveCException();
	}

	/**
	 * A native method that is implemented by the 'native-lib' native library,
	 * which is packaged with this application.
	 */
	public native void initializeGNUstep(AssetManager assetManager);
	public native String stringFromJNI();
	public native String stringFromObjectiveC();
	public native void throwObjectiveCException();
}
