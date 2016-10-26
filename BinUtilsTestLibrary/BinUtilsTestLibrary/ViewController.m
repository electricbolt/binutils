// binutils. Copyright © 2016 Electric Bolt Limited. See LICENSE file

#import "ViewController.h"
#import "CustomView.h"
#import "CustomViewBin.h"
#import "UIImage+Images.h"

@interface ViewController () {
    UINib* nib;
    CustomView* customView;
}

@end

@implementation ViewController

- (UIView*) viewWithClazz: (Class) clazz {
    NSArray* nibContents = [nib instantiateWithOwner: self options: nil];
    NSEnumerator* nibEnumerator = [nibContents objectEnumerator];
    NSObject* nibItem = nil;
    while ((nibItem = [nibEnumerator nextObject]) != nil) {
        if ([nibItem isKindOfClass: clazz])
            return (UIView*) nibItem;
    }
    return nil;
}

- (void) loadView {
    [super loadView];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage: [UIImage SettingsIcon] style: UIBarButtonItemStylePlain target:self action: @selector(settingsPressed:)];

    self.view.backgroundColor = [UIColor whiteColor];

    nib = [UINib nibWithData: [NSData dataWithBytes: CUSTOMVIEW_NIB length: sizeof(CUSTOMVIEW_NIB)] bundle: nil];

    customView = (CustomView*) [self viewWithClazz: [CustomView class]];
    customView.frame = CGRectMake([UIScreen mainScreen].bounds.size.width/2-125, 100, 250, 100);
    [self.view addSubview: customView];
    customView.label.text = @"Database conversion progress";
    customView.progressView.progress = 0.35;
}

- (void) settingsPressed: (id) target {
}

@end
