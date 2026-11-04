(() => {
    "use strict";

    const endpoint = "http://127.0.0.1:47943/palette";

    // Spotify color name -> 43PR palette key
    const colorMap = {
        "main": "bg",
        "accent": "accent",
        "accent-active": "accent",
        "accent-inactive": "bg_track",
        "banner": "accent",
        "border-active": "border_strong",
        "border-inactive": "border",
        "header": "fg_dim",
        "highlight": "bg_hover",
        "notification": "accent",
        "notification-error": "danger",
        "subtext": "fg_dim",
        "text": "fg",
    };

    let errorReported = false;

    function toRgb(hex) {
        return [
            parseInt(hex.slice(1, 3), 16),
            parseInt(hex.slice(3, 5), 16),
            parseInt(hex.slice(5, 7), 16),
        ].join(", ");
    }

    function applyPalette(palette) {
        const elements = [
            document.documentElement,
            document.body,
        ].filter(Boolean);

        for (const [spotifyKey, paletteKey] of Object.entries(colorMap)) {
            const color = palette[paletteKey];

            if (
                typeof color !== "string" ||
                !/^#[0-9a-fA-F]{6}$/.test(color)
            ) {
                continue;
            }

            for (const element of elements) {
                element.style.setProperty(
                    `--spice-${spotifyKey}`,
                    color
                );

                element.style.setProperty(
                    `--spice-rgb-${spotifyKey}`,
                    toRgb(color)
                );
            }
        }
    }

    async function syncPalette() {
        try {
            const response = await fetch(endpoint, {
                cache: "no-store",
            });

            if (!response.ok) {
                throw new Error(`HTTP ${response.status}`);
            }

            const palette = await response.json();

            applyPalette(palette);
            errorReported = false;

        } catch (error) {
            if (!errorReported) {
                console.warn(
                    "[43PR] Spotify palette sync unavailable:",
                    error
                );

                errorReported = true;
            }
        }
    }

    syncPalette();
    setInterval(syncPalette, 2000);
})();
