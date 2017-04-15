# PrivacyManager

Privacy manager for iOS in RxSwift

Currently supported:

*   Location Services
*   Contacts
*   Photos
*   Microphone
*   Camera

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

-   Add Input files *$(SRCROOT)/Carthage/Build/iOS/PrivacyManager.framework


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
         }
     )
```

## Requirements

-   Swift 3.0+
-   Xcode 8.0+
-   iOS 9+
-   RxSwift 3.4+

## License

Released under the MIT license. See LICENSE for details.