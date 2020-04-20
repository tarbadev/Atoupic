# Atoupic  ![Release](https://github.com/tarbadev/Atoupic/workflows/Release/badge.svg?branch=master)

A Belote card game

## Setup
### Install Flutter
https://flutter.dev/docs/get-started/install

## Build Dependency Injection
`flutter packages pub run build_runner build --delete-conflicting-outputs`

## Update application icon
`flutter pub run flutter_launcher_icons:main`

## Deploy
`fastlane deploy_internal_test`  
Specify environment variables to override parameters:
- `SUPPLY_VERSION_CODE=<Build Number>`
- `SUPPLY_AAB=<Path to aab file>`