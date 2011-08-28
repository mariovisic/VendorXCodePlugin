#import <Cocoa/Cocoa.h>
#import <objc/runtime.h>

#define HDNoOp (void)0


@interface VendorXcodeProject : NSObject
@end

@implementation VendorXcodeProject

+ (void)pluginDidLoad: (NSBundle *)plugin
{

    NSLog(@"%@ initializing...", NSStringFromClass([self class]));
    
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(applicationFinishedLaunching:)
        name: NSApplicationDidFinishLaunchingNotification object: nil];
    
    NSLog(@"%@ complete!", NSStringFromClass([self class]));
    return;
    failed:
    {
    
        NSLog(@"%@ failed. :(", NSStringFromClass([self class]));
    
    }

}

+ (void)applicationFinishedLaunching: (NSNotification *)notification
{

    NSMenu *mainMenu = [NSApp mainMenu];
    NSMenuItem *vendorMenuItem = [NSMenuItem new];
    NSMenu *vendorMenu = [[NSMenu alloc]initWithTitle:@"Vendor"];

    [vendorMenu addItemWithTitle:@"Setup current Project" action:nil keyEquivalent:@""];
    [vendorMenu addItemWithTitle:@"Vendor Install" action:nil keyEquivalent:@""];
    [vendorMenu addItemWithTitle:@"Vendor Update" action:nil keyEquivalent:@""];
    [vendorMenu addItemWithTitle:@"Find Libraries" action:nil keyEquivalent:@""];
    
    [vendorMenuItem setSubmenu:vendorMenu];
    [mainMenu insertItem:vendorMenuItem atIndex:7]; // Insert 7th down the line (usually just before window).
 
}

@end
