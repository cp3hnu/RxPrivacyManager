# RxPrivacyManager

Privacy manager for iOS based on RxSwift

Currently supported:

*   Camera
*   Photos
*   Location Services
*   Microphone
*   Contacts

## Installation

### Carthage

```swift
github "cp3hnu/PrivacyManager"
```

-   Drag and drop *PrivacyManager.framework* from /Carthage/Build/iOS/ to *Linked Frameworks and Libraries* in Xcode (Project>Target>General>Linked Frameworks and Libraries)
-   Add new run script

```ruby
  /usr/local/bin/carthage copy-frameworks
```

-   Add Input files *$(SRCROOT)/Carthage/Build/iOS/PrivacyManager.framework*


### Swift Package

File -> Swift Packages -> Add Package Dependency,  then search rxprivacymanager.

## Usage

**It's so easy!** Just a function call

```swift
// In UIViewController and subclasses
privacyPermission(for: PermissionType.camera, authorized: {
	// Picker photos
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
-   iOS 9+

## Others

[Carthage-and-nested-frameworks](http://stylekit.org/blog/2017/02/03/Carthage-and-nested-frameworks/)

## License

Released under the MIT license. See LICENSE for details.
