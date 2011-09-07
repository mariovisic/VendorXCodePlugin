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

    
    [[vendorMenu addItemWithTitle:@"Vendor Install" action:@selector(vendorInstall:) keyEquivalent:@"d"] setTarget:self];
    [vendorMenu addItemWithTitle:@"Vendor Update" action:nil keyEquivalent:@""];

    [vendorMenu addItem:[NSMenuItem separatorItem]];
    
    [vendorMenu addItemWithTitle:@"Setup Current Project" action:nil keyEquivalent:@""];
    
    [vendorMenu addItem:[NSMenuItem separatorItem]];
    
    [[vendorMenu addItemWithTitle:@"Find Vendor Packages" action:@selector(findVendorPackages:) keyEquivalent:@""] setTarget:self];
    
    // Attach the menus created to the main menu.
    // Insert the Vendor menu 7th down the line (usually just before window).
    [vendorMenuItem setSubmenu:vendorMenu];
    [mainMenu insertItem:vendorMenuItem atIndex:7]; 
    

 
}

+ (void)findVendorPackages: (id) sender {
    
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://vendorkit.com/"]];
    
}


+ (NSString*)getVendorPath {
    
    NSTask *task = [[NSTask new] autorelease];
    NSPipe *pipe = [NSPipe pipe];
    NSData *standardOutput = nil;

    [task setLaunchPath:@"/bin/bash"];
    [task setStandardOutput:pipe];    
    [task setArguments: [NSArray arrayWithObjects:@"-l",
    				 @"-c",
    				 @"which vendor",
    				 nil]];
    [task launch];
    [task waitUntilExit];
    
    if ([task terminationStatus] == 0) {
        NSLog(@"Vendor path detected successfully");
        standardOutput = [[pipe fileHandleForReading] readDataToEndOfFile];
        return [[NSString alloc] initWithData:standardOutput encoding:NSUTF8StringEncoding];
    } else {
        NSLog(@"Had an error, oh noes");
        return nil;
    }
    
}

+ (void)vendorInstall: (id)sender {

    NSString *vendorPath = [self getVendorPath];
    NSTask *task = [NSTask new];    
    
    vendorPath = [self getVendorPath];
    
    NSLog(@"vendor path: %@", vendorPath);
    
    if(vendorPath != nil) {
        
        [task setLaunchPath:vendorPath];
        [task setArguments:[NSArray arrayWithObject:@"install"]];
        [task launch];
        [task waitUntilExit];
         
         if ([task terminationStatus] == 0) {
             NSLog(@"Vendor Install OK");
         } else {
             NSLog(@"Had an error, oh noes");
         }
    }
         
}

@end
