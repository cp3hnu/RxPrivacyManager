# RxPrivacyManager

Privacy manager for iOS based on RxSwift

Currently supported:

*   Camera
*   Photos
*   Location Services
*   Microphone
*   Contacts
*   Speech

Each has a framework that you can add separately to your project.

## Installation

### Carthage

```swift
github "cp3hnu/PrivacyManager"
```

-   Drag and drop *PrivacyManager.framework*, *PrivacyPhoto.framework* or other framework from /Carthage/Build/iOS/ to *Linked Frameworks and Libraries* in Xcode (Project>Target>General>Linked Frameworks and Libraries)
-   Add new run script

```ruby
/usr/local/bin/carthage copy-frameworks
```

-   Add Input files

```sh
$(SRCROOT)/Carthage/Build/iOS/PrivacyManager.framework
$(SRCROOT)/Carthage/Build/iOS/PrivacyPhoto.framework
```


### Swift Package

File -> Swift Packages -> Add Package Dependency,  then search rxprivacymanager.

## Usage

**It's so easy!!!**  Just a function call

```swift
import PrivacyManager
import PrivacyPhoto

// In UIViewController and subclasses
PrivacyManager.shared.privacyCameraPermission(presenting: self, authorized: {
  print("相机已授权")
})
```

## Screenshot

##### For the first time

![](screenshot-1.png)

##### Without authorization

![](screenshot-2.png)



## Dependencies

*   [RxSwift 5.0.0+](https://github.com/ReactiveX/RxSwift)

## Requirements

-   Swift 5.0
-   Xcode 10.0
-   iOS 9+ or iOS 10+（with Speech ）

## License

Released under the MIT license. See LICENSE for details.
