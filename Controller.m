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
	return [self processInputDirectory:filename];
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
	
	return [self processInputDirectory:[panel filename]];
}

- (BOOL)processInputDirectory:(NSString *)input
{
	if (!input)
		return NO;
	
	NSOpenPanel *panel2 = [NSOpenPanel openPanel];
	[panel2 setCanChooseFiles:NO];
	[panel2 setCanChooseDirectories:YES];
	[panel2 setAllowsMultipleSelection:NO];
	[panel2 setTitle:@"Select the output destination"];
	
	if ([panel2 runModal] != NSFileHandlingPanelOKButton) {
		[NSApp terminate:nil];
		return NO;
	}
	
	NSString *output = [panel2 filename];
	if (!output)
		return NO;
	
	NSString *template = [[NSBundle mainBundle] pathForResource:@"Template" ofType:@""];
	
	HelpBook *book = [HelpBook bookWithInputBase:input templateBase:template];
	[book outputToDirectory:output];
	
	[NSApp terminate:nil];
	return YES;
}

@end
