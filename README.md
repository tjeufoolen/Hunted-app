# hunted_app

A new Flutter project.

## Getting Started
1. Clone this repository.
2. Setup API/DB from [HuntedAPI](https://github.com/tjeufoolen/Hunted-api)
3. Create a .env from the .env.example and fill in the fields.
3.1. *Disclaimer: Be sure to set the right API_URL. (android doesn't have `localhost` but uses `10.0.2.2` instead)*
4. Download dependencies using `flutter pub get`
5. Enjoy! :tada:

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

To run using a specific url, first open a adb shell:
`adb shell`
Then send a command to the emulator:
`am start -a android.intent.action.VIEW -c android.intent.category.BROWSABLE -d "huntedApp://hunted.app.com/login?code=123"`
