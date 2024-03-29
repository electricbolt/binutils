# binutils

Build time utilities for allowing resources to be included into:

* iOS static libraries (which could otherwise only be included into an iOS dynamic framework).
* Flutter plugin or apps directly in the binary instead of using the `images/` directory.

## bin2c

Converts any binary file (e.g. PNG, NIB) into a static array of bytes. The array is output into either:

* `.h` and `.m` files for inclusion into an iOS static library OR
* `.dart` file for inclusion into a Flutter plugin or app.

bin2c has specific knowledge about @2x, @3x PNG file suffixes.

### bin2c converting PNG files (Objective-C output)

The following example converts all PNG files in a directory into a static array in images.h and images.m. Assuming 3 PNG files named `sheep.png`, `sheep@2x.png`, `cow.png`:

> Terminal

```bash
bin2c -h *.png >images.h
bin2c *.png >images.m
```

> Resulting Objective-C `images.h` file:

```objective-c
extern unsigned char SHEEP_PNG[1683];
extern unsigned char SHEEP_2X_PNG[2439];
extern unsigned char COW_PNG[1215];
```

> Resulting Objective-C `images.m` file:

```objective-c
const unsigned char SHEEP_PNG[1683] = {0x89,0x50,0x4E,0x47...
const unsigned char SHEEP_2X_PNG[2439] = {0x2E,0x34,0x2E,0x30...
const unsigned char COW_PNG[1215] = {0x3A,0x43,0x6F,0x6D...
```

Ensure your PNG files to be converted are not ticked on in your static library target.

### bin2c converting PNG files (Dart/Flutter output)

The following example converts all PNG files in a directory into a static array in images.dart. Assuming 3 PNG files named `sheep.png`, `sheep@2x.png`, `cow.png`:

> Terminal

```bash
bin2c -dart *.png >rawimages.dart
```

> Resulting Dart `rawimages.dart` file:

```dart
import 'dart:typed_data';

import 'package:flutter/widgets.dart';

final SHEEP_PNG = Uint8List.fromList([0x89,0x50,0x4E,0x47...
final SHEEP_2X_PNG = Uint8List.fromList([0x2E,0x34,0x2E,0x30...
final COW_PNG = Uint8List.fromList([0x3A,0x43,0x6F,0x6D...
```

Ensure your PNG files to be converted are not included in your Flutter plugin or app by excluding the directory. (In Intelli-J, right click directory name in Project explorer, Mark Directory as, Excluded).

### bin2c converting NIB files

First compile your Interface Builder XIB file into a NIB file (see BinUtilsTestLibrary example RunScript phase "ibtool"). Convert the NIB using bin2c as follows:

> Terminal

```
bin2c -h CustomView.nib >CustomViewBin.h
bin2c CustomView.nib >CustomViewBin.m
```

Ensure your XIB files to be converted are not ticked on in your static library target. 

You can continue to edit your XIB files normally with Interface Builder.

Note that some compiled NIB files are not actually files but directory structures. These cannot currently be converted with bin2c.

You can load the NIB file programmatically from within your static library with the following code:

> Example Objective-C usage

```objective-c
// Load NIB file from static array of bytes
UINib* nib = [UINib nibWithData: [NSData dataWithBytes: CUSTOMVIEW_NIB length: sizeof(CUSTOMVIEW_NIB)] bundle: nil];

// Create an instance of the NIB
NSArray* nibContents = [nib instantiateWithOwner: self options: nil];

// Find the CustomView class
CustomView* customView = nil;
NSEnumerator* nibEnumerator = [nibContents objectEnumerator];
NSObject* nibItem = nil;
while ((nibItem = [nibEnumerator nextObject]) != nil) {
  if ([nibItem isKindOfClass: [CustomView class]]) {
     customView = (CustomView*) nibItem;
     break;
  }
}

// Use the customView
customView.textColor = ...
```

## image2c

Generates either:

* an UIImage category extension *or*
* a Flutter class

from a list of PNG files. image2c has specific knowledge about @2x, @3x PNG file suffixes.

### image2c generating UIImage category extension (Objective-C)

Assuming 3 PNG files named `sheep.png`, `sheep@2x.png` and `cow.png` the following example converts these into:

- a static array in `images.h` and `images.m` *and*
- an UIImage category extension `UIImage+Images.h` and `UIImages+Images.m`.

> Terminal

```bash
bin2c -h *.png >images.h
bin2c *.png >images.m
image2c -h Images images.h *.png >UIImage+Images.h
image2c Images images.h *.png >UIImage+Images.m
```

> Resulting Objective-C `UIImage+Images.h` file:

```objective-c
@interface UIImage (Images)

+ (UIImage*) sheep;
+ (UIImage*) cow;

@end
```

> Resulting Objective-C `UIImage+Images.m` file:

```objective-c
@implementation UIImage (Images)

+ (UIImage*) sheep {
  if ([UIScreen mainScreen].scale == 1.0)
	  return [UIImage imageWithData: [NSData dataWithBytes: SHEEP_PNG length: sizeof(SHEEP_PNG)] scale: 1.0];
  else
     return [UIImage imageWithData: [NSData dataWithBytes: SHEEP_2X_PNG length: sizeof(SHEEP_2X_PNG)] scale: 2.0];
};

+ (UIImage*) cow {
	return [UIImage imageWithData: [NSData dataWithBytes: COW_PNG length: sizeof(COW_PNG)] scale: 1.0];
};

@end
```

Ensure you use the same set of PNG files for bin2c and image2c

### image2c generating Images class (Dart/Flutter)

Assuming 3 PNG files named `sheep.png`, `sheep@2x.png` and `cow.png` the following example converts these into:

- a static array in `rawimages.dart` *and*
- an Images class in `images.dart`.

> Terminal

```bash
bin2c -dart *.png >rawimages.dart
image2c -dart Images example/ui/images/rawimages *.png >images.dart
```

> Resulting Dart `images.dart` file:

```dart
import 'dart:core';

import 'package:example/ui/images/rawimages.dart';
import 'package:flutter/cupertino.dart';

class Images {
	static double _devicePixelRatio = WidgetsBinding.instance.platformDispatcher.implicitView!.devicePixelRatio;
	static bool _1x = (_devicePixelRatio - 1.0).abs() < 0.01;
	static Image sheep({double? width, double? height}) {
		if (_1x) {
			return Image.memory(SHEEP_PNG, scale: 1.0, width: width, height: height);
		} else {
			return Image.memory(SHEEP_2X_PNG, scale: 2.0, width: width, height: height);
		}
	}
	static Image cow({double? width, double? height}) {
		return Image.memory(COW_PNG, scale: 1.0, width: width, height: height);
	}	
}
```

Ensure you use the same set of PNG files for bin2c and image2c.

## Examples

Included in the workspace are an iOS application BinUtilsTestApp and static library BinUtilsTestLibrary. The BinUtilsTestLibrary includes a `CustomView.xib` Interface Builder file and two images `SettingsIcon.png` and `SettingsIcon@2x.png`. Two RunScript phases are included in the BinUtilsTestLibrary to convert the XIB file and PNG files.

## Building

The `bin` directory contains pre-compiled versions of the bin2c and image2c utilities. These are used by the RunScript phases in the BinUtilsTestLibrary. You can also rebuild these utilities using the `./build.sh` command or using Xcode IDE.
