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
	NSXMLNode *related;
	
}

@property (assign) NSMutableArray *tags;
@property (assign) NSString *title;
@property (assign) NSXMLNode *content;
@property (assign) NSXMLNode *related;

- (void)writeToFile:(NSString *)file ofBook:(HelpBook *)book usingTemplate:(PageTemplate *)template contentXSLT:(NSString *)xslt;

@end
