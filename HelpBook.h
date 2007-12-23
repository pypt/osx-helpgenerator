//
//  HelpBook.h
//  HelpGenerator
//
//  Created by Jonas Witt on 12/22/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface HelpBook : NSObject {
	
	NSString *inputBase;

	NSString *templateBase;
	NSString *skeletonBase;
	
	NSXMLDocument *document;

	NSString *name;
	NSString *appleTitle;
	NSURL *url;
	NSString *icon;
	
	NSDictionary *pagesByTag;
	
	NSArray *letters;
		
}

@property (assign) NSString *appleTitle;

+ (HelpBook *)bookWithInputBase:(NSString *)input;

- (NSDictionary *)pagesByTag;

- (NSString *)indexPageContent;

- (NSString *)replaceInString:(NSString *)string keys:(NSDictionary *)dict;

- (void)outputToDirectory:(NSString *)dir;

@end
