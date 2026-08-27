package dev.abe.skylight;

import android.content.Context;
import android.graphics.Color;
import android.webkit.WebSettings;
import android.webkit.WebView;

import java.io.InputStream;

final class Pages {

    private Pages() {}

    // "dashboard" mode -> dashboard.html; anything else -> index.html (the sky page)
    static String startPage(Context ctx) {
        try {
            InputStream is = ctx.getAssets().open("config.json");
            byte[] buf = new byte[is.available()];
            int n = is.read(buf);
            is.close();
            org.json.JSONObject cfg = new org.json.JSONObject(new String(buf, 0, n, "UTF-8"));
            if ("dashboard".equals(cfg.optString("mode"))) return "dashboard.html";
        } catch (Exception ignored) {}
        return "index.html";
    }

    static WebView newWebView(Context ctx) {
        WebView webView = new WebView(ctx);
        webView.setBackgroundColor(Color.BLACK);
        WebSettings s = webView.getSettings();
        s.setJavaScriptEnabled(true);
        s.setDomStorageEnabled(true);
        s.setAllowFileAccess(true);
        s.setAllowUniversalAccessFromFileURLs(true);
        webView.loadUrl("file:///android_asset/" + startPage(ctx));
        return webView;
    }
}
