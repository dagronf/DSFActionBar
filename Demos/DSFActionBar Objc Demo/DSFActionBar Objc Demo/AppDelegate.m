//
//  AppDelegate.m
//  DSFActionBar Objc Demo
//
//  Created by Darren Ford on 8/1/21.
//

#import "AppDelegate.h"



@interface AppDelegate ()

@property (strong) IBOutlet NSWindow *window;
@property (weak) IBOutlet DSFActionBar *actionBar;
@property (weak) IBOutlet DSFActionTabBar *actionTabBar;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application

	[_actionBar add:@"All Items" identifier:nil block:^{
		NSLog(@"Pressed All Items");
	}];
	[_actionBar add:@"Passwords" identifier:nil block:^{
		NSLog(@"Pressed Passwords");
	}];
	[_actionBar add:@"Secure Notes" identifier:nil block:^{
		NSLog(@"Pressed Secure Notes");
	}];
	[_actionBar add:@"My Certificates" identifier:nil block:^{
		NSLog(@"Pressed My Certificates");
	}];
	[_actionBar add:@"Keys" identifier:nil block:^{
		NSLog(@"Pressed Keys");
	}];
	[_actionBar add:@"Certificates" identifier:nil block:^{
		NSLog(@"Pressed Certificates");
	}];

	////

	[_actionTabBar setActionTabDelegate:self];
	[_actionTabBar setCentered:NO];
	[_actionTabBar setItemSpacing:2];
	[_actionTabBar setControlSize:NSControlSizeRegular]; 

	[_actionTabBar add:@"All Items" identifier: nil];
	[_actionTabBar add:@"Passwords" identifier: nil];
	[_actionTabBar add:@"Secure Notes" identifier: nil];
	[_actionTabBar add:@"My Certificates" identifier: nil];
	[_actionTabBar add:@"Keys" identifier: nil];
	[_actionTabBar add:@"Certificates" identifier: nil];
}

- (void)actionTabBar:(DSFActionTabBar *)actionTabBar didSelectItem:(id<DSFActionBarItem>)item atIndex:(NSInteger)index {
	NSLog(@"Selected tab item %ld (%@)", index, [item title]);
}



- (void)applicationWillTerminate:(NSNotification *)aNotification {
	// Insert code here to tear down your application
}


@end
