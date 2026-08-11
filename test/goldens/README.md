# Golden test images

This folder is empty on purpose — golden reference PNGs are generated
locally, not shipped from this environment (no Flutter SDK / renderer was
available to produce them here).

Generate them with:

```bash
flutter test --update-goldens test/golden_test.dart
```

This writes the reference PNGs referenced by `test/golden_test.dart`
(`cart_popup_default.png`, `add_to_cart_stepper.png`, etc.) into this
folder. Review each image once by eye before committing — a golden file is
only a useful regression check if a human confirmed the rendering it
captures is correct.

After that, plain `flutter test test/golden_test.dart` compares future
runs against these images and fails on any pixel diff.

Golden images are sensitive to the Flutter SDK version, font rendering,
and OS — regenerate them if `flutter --version` changes and tests start
failing with diffs that don't correspond to an actual visual change you made.
