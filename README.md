# PrivacyManager

Privacy manager for iOS in RxSwift

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


## Usage

```swift
PrivacyManager.sharedInstance.rx_cameraPermission
    .subscribe(
        onNext: { [weak self] granted in
	    if granted {
	        print("authorization")
	    } else {
	        print("unauthorization")
	    }
	})
```

## Dependencies

*   [RxSwift 4.0](https://github.com/ReactiveX/RxSwift)

## Requirements

-   Swift 4.0+
-   Xcode 9.0+
-   iOS 8+

## Others

[Carthage-and-nested-frameworks](http://stylekit.org/blog/2017/02/03/Carthage-and-nested-frameworks/)

## License

Released under the MIT license. See LICENSE for details.
