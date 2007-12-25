//
//  Controller.m
//  HelpGenerator
//
//  Created by Jonas Witt on 12/25/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "Controller.h"
#import "HelpBook.h"

@implementation Controller

- (BOOL)application:(NSApplication *)theApplication openFile:(NSString *)filename
{
	[self processInputDirectory:filename];
	
	return YES;
}

- (BOOL)applicationOpenUntitledFile:(NSApplication *)theApplication
{
	NSOpenPanel *panel = [NSOpenPanel openPanel];
	[panel setCanChooseFiles:NO];
	[panel setCanChooseDirectories:YES];
	[panel setAllowsMultipleSelection:NO];
	[panel setTitle:@"Select your Help Source directory"];
	
	if ([panel runModal] != NSFileHandlingPanelOKButton) {
		[NSApp terminate:nil];
		return NO;
	}
	
	NSString *input = [panel filename];
	[self processInputDirectory:input];
	
	return YES;
}

- (void)processInputDirectory:(NSString *)input
{
	if (!input)
		return;
	
	NSOpenPanel *panel2 = [NSOpenPanel openPanel];
	[panel2 setCanChooseFiles:NO];
	[panel2 setCanChooseDirectories:YES];
	[panel2 setAllowsMultipleSelection:NO];
	[panel2 setTitle:@"Select the output destination"];
	
	if ([panel2 runModal] != NSFileHandlingPanelOKButton) {
		[NSApp terminate:nil];
		return;
	}
	
	NSString *output = [panel2 filename];
	if (!output)
		return;
	
	NSString *template = [[NSBundle mainBundle] pathForResource:@"Template" ofType:@""];
	
	HelpBook *book = [HelpBook bookWithInputBase:input templateBase:template];
	[book outputToDirectory:output];
	
	[NSApp terminate:nil];	
}

@end
