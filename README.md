# Hunted-APP

Flutter app build for the Hunted project.

## Prerequisites
- This project can not function without the API running.

## Getting Started
1. Clone this repository.
2. Create a .env from the .env.example and fill in the fields.
2.1. *Disclaimer: Be sure to set the right API_URL. (android doesn't have `localhost` but uses `10.0.2.2` instead)*
3. Download dependencies using `flutter pub get`.
4. Start programming! :tada:

## Building
To build an apk of your app use the following command: `flutter build apk`.

## Running
To run using a specific url, first open a adb shell:
`adb shell`
Then send a command to the emulator:
`am start -a android.intent.action.VIEW -c android.intent.category.BROWSABLE -d "huntedApp://hunted.app.com/login?code=123"`

## Authors
- [Micha Nijenhof](https://github.com/nijenhof)
- [Tjeu Foolen](https://github.com/tjeufoolen)
- [Wouter van Mierlo](https://github.com/wvm28)
- [Tim van den Berg](https://github.com/timvandenber9)
- [Rick van den Berg](https://github.com/thatoneguyrick)
- [Bart Fransen](https://github.com/Bartf6)
