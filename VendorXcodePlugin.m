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
    [[vendorMenu addItemWithTitle:@"Vendor Update" action:@selector(vendorUpdate:) keyEquivalent:@""]setTarget:self];
    [vendorMenu addItem:[NSMenuItem separatorItem]];
    [[vendorMenu addItemWithTitle:@"Setup Current Project" action:@selector(vendorSetup:) keyEquivalent:@""]setTarget:self];
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

+ (void)displayError: (NSString*)errorString {
    NSLog(@"VendorKit Error: %@", errorString);
    NSRunCriticalAlertPanel(@"VendorKit Error", errorString, @"OK", nil, nil);
}

// Check to make sure that the vendor rubygem is installed and
// responds correctly.
+ (bool)vendorIsInstalled {
    
    NSTask *task = [[NSTask new] autorelease];
    
    [task setLaunchPath:@"/bin/bash"];
    [task setArguments:[NSArray arrayWithObjects:@"-l", @"-c", @"vendor", nil]];
    [task launch];
    [task waitUntilExit];
    
    if ([task terminationStatus] == 0) {
        return YES;
    }

    [self displayError:@"The VendorKit RubyGem is not installed, visit vendorkit.com for installation instructions"];
    return NO;
    
}

+ (void)runVendorCommand: (NSString*)commandString withTitle:(NSString*)title {

    if([self vendorIsInstalled]) {

        NSTask *task = [[NSTask new] autorelease];
        NSPipe *pipe = [NSPipe pipe];
        NSData *output = nil;
        NSString *outputString = nil;
        
        [task setLaunchPath:@"/bin/bash"];
        [task setArguments:[NSArray arrayWithObjects:@"-l", @"-c", commandString, nil]];
        [task setStandardOutput: pipe];
        [task setStandardError:pipe];
        [task launch];
        [task waitUntilExit];

        output = [[pipe fileHandleForReading] readDataToEndOfFile];
        outputString = [[NSString alloc] initWithData:output encoding:NSUTF8StringEncoding];

        if ([task terminationStatus] == 0) {
            NSLog(@"Return Output: %@", outputString);
        } else {
            NSLog(@"ERROR %@", outputString);
            [self displayError:[NSString stringWithFormat:@"Cannot run %@: %@", title, outputString]];
        }
        
    }
         
}


+ (void)vendorInstall: (id)sender {
    [self runVendorCommand:@"vendor install" withTitle:@"Vendor Install"];
}

+ (void)vendorUpdate: (id)sender {
    [self runVendorCommand:@"vendor update" withTitle:@"Vendor Update"];
}

+ (void)vendorSetup: (id)sender {
    [self runVendorCommand:@"vendor setup" withTitle:@"Vendor Setup"];
}

@end
