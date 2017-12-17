# binutils

Xcode build time utilities for allowing resources to be included into iOS static libraries (which could otherwise only be included into an iOS dynamic framework).

## bin2c

Converts any binary file (e.g. PNG, NIB) into a static array of bytes. The array is output into .h and .m files for inclusion into an iOS static library. bin2c has specific knowledge about @2x,@3x PNG file suffixes.

### bin2c converting PNG files

The following example converts all PNG files in a directory into a static array in images.h and images.m.
Assuming 3 PNG files named sheep.png, sheep@2x.png, cow.png:

```
bin2c -h *.png >images.h
bin2c *.png >images.m
```

Resulting images.h file:

```
extern unsigned char SHEEP_PNG[1683];
extern unsigned char SHEEP_2X_PNG[2439];
extern unsigned char COW_PNG[1215];
```
Resulting images.m file:

```
const unsigned char SHEEP_PNG[1683] = {0x89,0x50,0x4E,0x47...
const unsigned char SHEEP_2X_PNG[2439] = {0x2E,0x34,0x2E,0x30...
const unsigned char COW_PNG[1215] = {0x3A,0x43,0x6F,0x6D...
```

Ensure your PNG files to be converted are not ticked on in your static library target.

### bin2c converting NIB files

First compile your Interface Builder XIB file into a NIB file (see BinUtilsTestLibrary example RunScript phase "ibtool"). Convert the NIB using bin2c as follows:

```
bin2c -h CustomView.nib >CustomViewBin.h
bin2c CustomView.nib >CustomViewBin.m
```

Ensure your XIB files to be converted are not ticked on in your static library target. 

You can continue to edit your XIB files normally with Interface Builder.

Note that some compiled NIB files are not actually files but directory structures. These cannot currently be converted with bin2c.

You can load the NIB file programmatically from within your static library with the following code:

```
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

Generates a UIImage category extension from a list of PNG files. image2c has specific knowledge about @2x,@3x PNG file suffixes.

### image2c generating UIImage category extension

The following example converts all PNG files in a directory into a static array in images.h and images.m and also a UIImage category extension UIImage+Images.h/m.
Assuming 3 PNG files named sheep.png, sheep@2x.png, cow.png:

```
bin2c -h *.png >images.h
bin2c *.png >images.m
image2c -h Images images.h *.png >UIImage+Images.h
image2c Images images.h *.png >UIImage+Images.m
```

Resulting UIImage+Images.h file:

```
@interface UIImage (Images)

+ (UIImage*) sheep;
+ (UIImage*) cow;

@end
```

Resulting UIImage+Images.m file:

```
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

## Examples

Included in the workspace are an iOS application BinUtilsTestApp and static library BinUtilsTestLibrary. The BinUtilsTestLibrary includes a 'CustomView.xib' Interface Builder file and two images 'SettingsIcon.png' and 'SettingsIcon@2x.png'. Two RunScript phases are included in the BinUtilsTestLibrary to convert the XIB file and PNG files.

## Building
The bin directory contains pre-compiled versions of the bin2c and image2c utilities. These are used by the RunScript phases in the BinUtilsTestLibrary. You can also rebuild these utilities using the ./build.sh command or using Xcode IDE.

## LICENSE
```
binutils

Copyright © 2016 Electric Bolt Limited

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this
list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright notice,
this list of conditions and the following disclaimer in the documentation
and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
```
