# Skylight

An ambient TV dashboard / screensaver. A single self-contained HTML page:
the background is a live sky that tracks real sunrise/sunset at your
location, stars come out at night, faint clouds drift when it's actually
cloudy, and the weather is written as an almanac sentence under a big
serif clock.

**Live URL:** point any browser (or a TV "URL screensaver" app) at the
GitHub Pages URL for this repo.

## Data sources

- Weather + sunrise/sunset: [Open-Meteo](https://open-meteo.com/) (free, no API key)
- Location: auto-detected from IP via ipapi.co (fallback: geojs.io)

## Configuration

Edit the `CONFIG` object at the top of the `<script>` in `index.html`:

```js
var CONFIG = {
  latitude: null,        // set both to pin a location instead of IP detection
  longitude: null,
  locationName: null,    // display name override, e.g. "Denver"
  units: "fahrenheit",   // or "celsius"
  hour12: true,
  weatherRefreshMinutes: 15
};
```

## Notes

- Written for TV browsers: conservative JS (no optional chaining), CSS
  custom properties, no build step.
- Anti burn-in: the content block drifts a few pixels every 90 seconds.
- Last-known weather is cached in localStorage so a reboot shows data
  instantly.
