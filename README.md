# FirebaseLister — FirebaseDatabaseUI Sample iOS App

FirebaseDatabaseUI is an open-source library for iOS that allows you to quickly connect common UI elements to the [Firebase](https://firebase.google.com?utm_source=FirebaseUI-iOS) database for data storage, allowing views to be updated in realtime as they change, and providing simple interfaces for common tasks like displaying lists or collections of items.




## Mandatory Sample Project Configuration

have to configure the Xcode project in order to run the sample.

1. You project should contain `GoogleService-Info.plist` downloaded from [Firebase console](https://console.firebase.google.com).<br>
Copy `GoogleService-Info.plist` into sample project folder (`samples/obj-c/GoogleService-Info.plist` or `samples/swift/GoogleService-Info.plist`).<br>
Find more instructions and download a plist file from the [Firebase console](https://console.firebase.google.com).

2. Don't forget to configure your Firebase App Database using [Firebase console](https://console.firebase.google.com).<br>
Database should contain appropriate read/write permissions.

3. Run 'pod install' in the directory of the sample project to install necessary dependencies.