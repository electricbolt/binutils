// binutils. Copyright © 2016 Electric Bolt Limited. See LICENSE file

#import "AppDelegate.h"
#import "ViewController.h"

@interface AppDelegate () {
    UIWindow* window;
}

@end

@implementation AppDelegate

- (BOOL) application: (UIApplication*) application didFinishLaunchingWithOptions: (NSDictionary*) launchOptions {
    ViewController* viewCtrl = [ViewController new];
    UINavigationController* navCtrl = [[UINavigationController alloc] initWithRootViewController: viewCtrl];
    window = [[UIWindow alloc] initWithFrame: [[UIScreen mainScreen] bounds]];
    [window makeKeyAndVisible];
    window.rootViewController = navCtrl;
    return YES;
}

@end
