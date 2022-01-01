// binutils. Copyright © 2016 Electric Bolt Limited. See LICENSE file

@import Foundation;

static void haltSyntax() {
    fprintf(stderr, "bin2c Version 1.1.0; Copyright © 2016-2022 Electric Bolt Limited\n");
    fprintf(stderr, "Syntax: bin2c [-h|-dart] input-file-1 [input-file-2] ... [input-file-n]\n");
    fprintf(stderr, "    -h = output .h file\n");
    fprintf(stderr, "    -dart = output .dart file\n");
    exit(1);
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        if (argc < 2)
            haltSyntax();

        int inputFileIndex = 1;
        BOOL outputHeaderFile = NO;
        BOOL outputDartFile = NO;
        NSString* header = [NSString stringWithCString: argv[1] encoding: NSUTF8StringEncoding];
        if ([header isEqualToString: @"-h"]) {
            if (argc < 3)
                haltSyntax();
            outputHeaderFile = YES;
            inputFileIndex = 2;
        } else if ([header isEqualToString: @"-dart"]) {
            if (argc < 3)
                haltSyntax();
            outputDartFile = YES;
            inputFileIndex = 2;
        }

        printf("// Auto-generated with bin2c. Do not change.\n\n");
        if (outputDartFile) {
            printf("// ignore_for_file: non_constant_identifier_names\n\n");
            printf("import 'dart:typed_data';\n");
            printf("\n");
            printf("import 'package:flutter/widgets.dart';\n\n");
        }
        for (int i = inputFileIndex; i < argc; i++) {
            NSString* inputFile = [NSString stringWithCString: argv[i] encoding: NSUTF8StringEncoding];
            NSData* data = [NSData dataWithContentsOfFile: inputFile];
            if (data == nil) {
                fprintf(stderr, "Could not read input-file %s\n", [inputFile UTF8String]);
                exit(1);
            }

            NSString* f = [inputFile.lastPathComponent uppercaseString];
            f = [f stringByReplacingOccurrencesOfString: @"-" withString: @"_"]; // change - into _
            f = [f stringByReplacingOccurrencesOfString: @"." withString: @"_"]; // change .PNG into _PNG
            f = [f stringByReplacingOccurrencesOfString: @"@" withString: @"_"]; // change @2X into _2X

            if (outputDartFile) {
                unsigned char* buf = (unsigned char*) data.bytes;
                NSMutableString* sb = [NSMutableString new];
                [sb appendFormat: @"final %@ = Uint8List.fromList([", f];
                for (int j = 0; j < [data length]; j++) {
                    if ([sb length] >= 70) {
                        printf("%s\n", [sb UTF8String]);
                        sb = [NSMutableString new];
                        [sb appendString: @"\t"];
                    }
                    unsigned char c = buf[j];
                    [sb appendFormat: @"0x%.2X", c];
                    if (j < [data length] - 1)
                        [sb appendString: @","];
                    else
                        [sb appendString: @"]);"];
                }
                printf("%s\n", [sb UTF8String]);
            } else if (outputHeaderFile) {
                NSMutableString* sb = [NSMutableString new];
                [sb appendFormat: @"extern unsigned char %@[%ld];", f, [data length]];
                printf("%s\n", [sb UTF8String]);
            } else {
                unsigned char* buf = (unsigned char*) data.bytes;
                NSMutableString* sb = [NSMutableString new];
                [sb appendFormat: @"const unsigned char %@[%ld] = {", f, [data length]];
                for (int j = 0; j < [data length]; j++) {
                    if ([sb length] >= 70) {
                        printf("%s\n", [sb UTF8String]);
                        sb = [NSMutableString new];
                        [sb appendString: @"\t"];
                    }
                    unsigned char c = buf[j];
                    [sb appendFormat: @"0x%.2X", c];
                    if (j < [data length] - 1)
                        [sb appendString: @","];
                    else
                        [sb appendString: @"};"];
                }
                printf("%s\n", [sb UTF8String]);
            }
        }
    }
    
    return 0;
}
