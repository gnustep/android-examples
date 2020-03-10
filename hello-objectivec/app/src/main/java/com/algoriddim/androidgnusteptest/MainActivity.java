package com.example.helloobjectivec;

import android.content.Context;
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
		initializeGNUstep(this);

		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_main);

		// Example of a call to a native method
		TextView tv = findViewById(R.id.sample_text);
		tv.setText(stringFromObjectiveC());
	}

	public void onThrowObjCException(View v) {
		throwObjCException();
	}
	public void onThrowObjCXXException(View v) {
		throwObjCXXException();
	}

	/**
	 * A native method that is implemented by the 'native-lib' native library,
	 * which is packaged with this application.
	 */
	public native void initializeGNUstep(Context context);
	public native String stringFromObjectiveC();
	public native void throwObjCException();
	public native void throwObjCXXException();
}
