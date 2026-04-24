# Changelog

All notable changes to **Disco Lights** will be documented here.

---

## [1.0.1] – 2026-04-24

### Added
- App icon: disco ball with colourful mirrored tiles, sparkles, and a dark background

---

## [1.0.0] – 2026-04-24

### Added
- Initial release — iOS SwiftUI app
- **Ordered mode**: colors cycle in sequence at a chosen BPM (30–300)
- **Random / Chaos mode**: colors flash randomly at a chosen BPM
- **Beat Reactive mode**: microphone detects ambient sound and flashes on the beat
- Five colour palettes: Disco, Neon, Fire, Ocean, Custom
- Custom palette editor: add, reorder, and delete colours with SwiftUI ColorPicker
- Beat sensitivity slider for fine-tuning mic reactivity
- Fullscreen disco mode: max brightness, screen always on, all UI chrome hidden
- Brightness saved on entry and restored on all exit paths
- Double-tap or stop button to exit disco mode
- Mic permission flow with Settings deep-link if access is denied
- Flashing light / epilepsy safety warning shown once before first use
- `xcodegen` `project.yml` for easy Xcode project regeneration
