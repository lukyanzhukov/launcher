package com.lukianbat.test.mylauncher

import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.view.View
import android.content.Intent
import android.provider.Settings


class MainActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
    }

    fun onHeartOracleClick(view: View) {
        val launchIntent = packageManager.getLaunchIntentForPackage("com.heartoracle.sport.student")
        startActivity(launchIntent)
    }

    fun onSettingsClick(view: View) {
        val intent = Intent(Settings.ACTION_SETTINGS)
        startActivity(intent)

    }
}
