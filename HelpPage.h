//
//  HelpPage.h
//  HelpGenerator
//
//  Created by Jonas Witt on 12/22/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class PageTemplate;
@class HelpBook;

@interface HelpPage : NSObject {
	
	NSMutableArray *tags;
	
	NSString *title;
	
	NSXMLNode *content;
	
}

@property (assign) NSMutableArray *tags;
@property (assign) NSString *title;
@property (assign) NSXMLNode *content;

- (void)writeToFile:(NSString *)file ofBook:(HelpBook *)book usingTemplate:(PageTemplate *)template;

- (void)writeContentNode:(NSXMLNode *)node toBuffer:(NSMutableString *)buffer forBook:(HelpBook *)book;

@end