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
	
	NSString *name;
	NSString *appleTitle;
	NSURL *url;
	NSString *icon;
	
	NSMutableDictionary *index;	
	NSMutableDictionary *pagesByTag;
	
	NSMutableDictionary *accessLinks;
	NSMutableArray *accessFeatures;
			
}

@property (assign) NSString *appleTitle;
@property (readonly) NSDictionary *pagesByTag;

+ (HelpBook *)bookWithInputBase:(NSString *)input;

- (id)initWithBasePath:(NSString *)path;

- (NSString *)accessPageContent;

- (void)outputToDirectory:(NSString *)dir;

@end
