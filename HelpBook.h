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
	NSString *smallIcon;
	NSString *localization;
	
	NSMutableSet *pages;
	NSMutableDictionary *pagesByTag;
	
	NSMutableArray *index;
	NSMutableArray *accessLinks;
	NSMutableArray *accessFeatures;
	
	NSDictionary *strings;
	
}

@property (assign) NSString *appleTitle;
@property (assign) NSString *name;
@property (readonly) NSDictionary *pagesByTag;

+ (HelpBook *)bookWithInputBase:(NSString *)input templateBase:(NSString *)template;

- (id)initWithBasePath:(NSString *)path templateBase:(NSString *)template;

- (NSString *)accessPageContent;

- (NSString *)linkToTag:(NSString *)tag listTitle:(NSString *)title;

- (void)outputToDirectory:(NSString *)dir;

- (NSString *)localize:(NSString *)key;

@end
