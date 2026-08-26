package dev.abe.skylight;

import android.graphics.Color;
import android.service.dreams.DreamService;
import android.webkit.WebSettings;
import android.webkit.WebView;

public class SkylightDream extends DreamService {

    private WebView webView;

    @Override
    public void onAttachedToWindow() {
        super.onAttachedToWindow();
        setInteractive(false);
        setFullscreen(true);
        setScreenBright(true);

        webView = new WebView(this);
        webView.setBackgroundColor(Color.BLACK);

        WebSettings s = webView.getSettings();
        s.setJavaScriptEnabled(true);
        s.setDomStorageEnabled(true);
        // page ships inside the APK and is loaded from file://android_asset;
        // weather/location fetches need cross-origin from that file origin
        s.setAllowFileAccess(true);
        s.setAllowUniversalAccessFromFileURLs(true);

        webView.loadUrl("file:///android_asset/index.html");
        setContentView(webView);
    }

    @Override
    public void onDetachedFromWindow() {
        super.onDetachedFromWindow();
        if (webView != null) {
            webView.destroy();
            webView = null;
        }
    }
}
