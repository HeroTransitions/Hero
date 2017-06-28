#Installation

#### Manual

Drag the `Sources` folder into your project. [(Download)](https://github.com/lkzhao/Hero/releases)

#### Carthage

`github "lkzhao/Hero"`

#### CocoaPods

`pod "Hero"`

#### Swift Package Manager

##### Step 1

`File > New > Project`

##### Step 2

Create a `Package.swift` in root directory.

```swift
import PackageDescription

let package = Package(
    name: "NameOfYourPackage",
    dependencies: [
        .Package(url: "https://github.com/lkzhao/Hero")
    ]
)
```

Run `swift package fetch`

##### Step 3

Open the Xcode Project File.
File > New > Target > **Cocoa Touch Framework**
If you don't need Obj-C support remove the <target_name>.h files in the navigator.

##### Step 4

Go in Finder and drag & drop the sources from `Packages/Hero/Sources` into your project and add it to the Hero target.

##### Step 5

Link your Project to the Hero dependency. Select your main target and add the CocoaTouchFramework to the **Linked Frameworks and Libraries** in the General Tab.