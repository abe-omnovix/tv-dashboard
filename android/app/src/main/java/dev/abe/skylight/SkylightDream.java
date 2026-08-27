package dev.abe.skylight;

import android.service.dreams.DreamService;
import android.webkit.WebView;

public class SkylightDream extends DreamService {

    private WebView webView;

    @Override
    public void onAttachedToWindow() {
        super.onAttachedToWindow();
        setInteractive(false);
        setFullscreen(true);
        setScreenBright(true);
        webView = Pages.newWebView(this);
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
