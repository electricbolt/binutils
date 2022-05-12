// binutils. Copyright © 2016-2022 Electric Bolt Limited. See LICENSE file

@import Foundation;

static void haltSyntax() {
    fprintf(stderr, "image2c Version 1.1.2; Copyright © 2016-2022 Electric Bolt Limited\n");
    fprintf(stderr, "Syntax: image2c [-h|-dart] category-name header-file input-file-1 [input-file-2] ... [input-file-n]\n");
    fprintf(stderr, "    -h = output .h file\n");
    fprintf(stderr, "    -dart = output .dart file\n");
    exit(1);
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        if (argc < 2)
            haltSyntax();

        int categoryNameIndex = 1;
        int headerFileIndex = 2;
        int inputFileIndex = 3;
        BOOL outputHeaderFile = NO;
        BOOL outputDartFile = NO;
        NSString* header = [NSString stringWithCString: argv[1] encoding: NSUTF8StringEncoding];
        if ([header isEqualToString: @"-h"]) {
            if (argc < 5)
                haltSyntax();
            outputHeaderFile = YES;
            categoryNameIndex = 2;
            headerFileIndex = 3;
            inputFileIndex = 4;
        } else if ([header isEqualToString: @"-dart"]) {
            if (argc < 5)
                haltSyntax();
            outputDartFile = YES;
            categoryNameIndex = 2;
            headerFileIndex = 3;
            inputFileIndex = 4;
        } else {
            if (argc < 4)
                haltSyntax();
        }

        NSString* categoryName = [NSString stringWithCString: argv[categoryNameIndex] encoding: NSUTF8StringEncoding];
        NSString* headerFile = [NSString stringWithCString: argv[headerFileIndex] encoding: NSUTF8StringEncoding];

        // Combine all scales (@1x,@2x,@3x) of identically named images together.
        NSMutableDictionary* distinctImageNames = [NSMutableDictionary new];
        for (int i = inputFileIndex; i < argc; i++) {
            NSString* inputFile = [NSString stringWithCString: argv[i] encoding: NSUTF8StringEncoding];
            NSString* f = inputFile.lastPathComponent;

            if (![f hasSuffix: @".png"]) {
                fprintf(stderr, "%s is not a png file", [f UTF8String]);
                exit(1);
            }
            f = [f substringToIndex: [f length] - 4]; // remove .png

            int scale = 1;
            NSUInteger location = [f rangeOfString: @"@"].location;
            if (location != NSNotFound) {
                scale = [[f substringFromIndex: location + 1] intValue];
                f = [f substringToIndex: location];
            }

            f = [f stringByReplacingOccurrencesOfString: @"-" withString: @"_"];
            
            NSMutableArray* scales = [distinctImageNames objectForKey: f];
            if (scales == nil) {
                scales = [NSMutableArray new];
                [distinctImageNames setObject: scales forKey: f];
            }
            [scales addObject: [NSNumber numberWithInt: scale]];
        }

        printf("// Auto-generated with image2c. Do not change.\n\n");
        if (outputHeaderFile) {
            NSMutableString* sb = [NSMutableString new];
            [sb appendString: @"@import UIKit;\n"];
            [sb appendString: @"\n"];
            [sb appendFormat: @"@interface UIImage (%@)\n", categoryName];
            [sb appendString: @"\n"];
            printf("%s", [sb UTF8String]);
        } else if (outputDartFile) {
            NSMutableString* sb = [NSMutableString new];
            
            [sb appendString: @"// ignore_for_file: non_constant_identifier_names\n\n"];
            [sb appendString: @"import 'dart:core';\n"];
            [sb appendString: @"\n"];
            [sb appendFormat: @"import 'package:%@';\n", headerFile];
            [sb appendString: @"import 'package:flutter/cupertino.dart';\n\n"];
            [sb appendFormat: @"class %@ {\n", categoryName];
            printf("%s", [sb UTF8String]);
        } else {
            NSMutableString* sb = [NSMutableString new];
            [sb appendFormat: @"#import \"UIImage+%@.h\"\n", categoryName];
            [sb appendFormat: @"#import \"%@\"\n", headerFile];
            [sb appendString: @"\n"];
            [sb appendFormat: @"@implementation UIImage (%@)\n", categoryName];
            [sb appendString: @"\n"];
            printf("%s", [sb UTF8String]);
        }

        for (NSString* f in distinctImageNames) {
            if (outputHeaderFile) {
                NSMutableString* sb = [NSMutableString new];
                [sb appendFormat: @"+ (UIImage*) %@;\n", f];
                printf("%s", [sb UTF8String]);
            } else if (outputDartFile) {
                // Sort scale into ascending order @1x,@2x,@3x
                NSMutableArray* scales = [distinctImageNames objectForKey: f];
                [scales sortUsingComparator: ^NSComparisonResult(NSNumber* obj1, NSNumber* obj2) {
                    if (obj1.intValue < obj2.intValue)
                        return NSOrderedAscending;
                    else if (obj1.intValue > obj2.intValue)
                        return NSOrderedDescending;
                    else
                        return NSOrderedSame;
                }];

                NSMutableString* sb = [NSMutableString new];
                [sb appendFormat: @"\tstatic Image %@({double? width, double? height}) {\n", f];
                if ([scales count] > 1)
                    [sb appendString: @"\t\tvar data = MediaQueryData.fromWindow(WidgetsBinding.instance.window);\n\t\t"];
                for (int i = 0; i < [scales count]; i++) {
                    NSString* s = [f uppercaseString];
                    int scale = [[scales objectAtIndex: i] intValue];
                    if (scale != 1)
                        s = [s stringByAppendingFormat: @"_%ldX", (long) scale];
                    s = [s stringByAppendingString: @"_PNG"];
                    if (i < [scales count] - 1) {
                        [sb appendFormat: @"if ((data.devicePixelRatio - %ld.0).abs() < 0.01) {\n", (long) scale];
                        [sb appendFormat: @"\t\t\treturn Image.memory(%@, scale: %ld.0, width: width, height: height);\n", s, (long) scale];
                        [sb appendString: @"\t\t} else "];
                    } else {
                        if ([scales count] > 1)
                            [sb appendString: @"{\n\t"];
                        [sb appendFormat: @"\t\treturn Image.memory(%@, scale: %ld.0, width: width, height: height);\n", s, (long) scale];
                        if ([scales count] > 1)
                            [sb appendString: @"\t\t}\n"];
                    }
                }
                [sb appendString: @"\t}\n"];
                printf("%s", [sb UTF8String]);
            } else {
                // Sort scale into ascending order @1x,@2x,@3x
                NSMutableArray* scales = [distinctImageNames objectForKey: f];
                [scales sortUsingComparator: ^NSComparisonResult(NSNumber* obj1, NSNumber* obj2) {
                    if (obj1.intValue < obj2.intValue)
                        return NSOrderedAscending;
                    else if (obj1.intValue > obj2.intValue)
                        return NSOrderedDescending;
                    else
                        return NSOrderedSame;
                }];

                NSMutableString* sb = [NSMutableString new];
                [sb appendFormat: @"+ (UIImage*) %@ {\n\t", f];
                for (int i = 0; i < [scales count]; i++) {
                    NSString* s = [f uppercaseString];
                    int scale = [[scales objectAtIndex: i] intValue];
                    if (scale != 1)
                        s = [s stringByAppendingFormat: @"_%ldX", (long) scale];
                    s = [s stringByAppendingString: @"_PNG"];
                    if (i < [scales count] - 1) {
                        [sb appendFormat: @"if ([UIScreen mainScreen].scale == %ld.0)\n", (long) scale];
                        [sb appendFormat: @"\t\treturn [UIImage imageWithData: [NSData dataWithBytes: %@ length: sizeof(%@)] scale: %ld.0];\n", s, s, (long) scale];
                        [sb appendString: @"\telse "];
                    } else {
                        if ([scales count] > 1)
                            [sb appendString: @"\n\t\t"];
                        [sb appendFormat: @"return [UIImage imageWithData: [NSData dataWithBytes: %@ length: sizeof(%@)] scale: %ld.0];\n", s, s, (long) scale];
                    }
                }
                [sb appendString: @"}\n"];
                [sb appendString: @"\n"];
                printf("%s", [sb UTF8String]);
            }
        }

        if (outputHeaderFile)
            printf("\n");

        if (!outputDartFile) {
            NSMutableString* sb = [NSMutableString new];
            [sb appendString: @"@end\n"];
            printf("%s", [sb UTF8String]);
        } else {
            printf("}\n");
        }
    }
    return 0;
}
