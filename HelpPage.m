//
//  HelpPage.m
//  HelpGenerator
//
//  Created by Jonas Witt on 12/22/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "HelpPage.h"

#import "HelpBook.h"
#import "PageTemplate.h"

@implementation HelpPage

@synthesize tags, title, content;

- (void)writeToFile:(NSString *)file ofBook:(HelpBook *)book usingTemplate:(PageTemplate *)template
{
	NSMutableString *tagString = [NSMutableString string];
	for (NSString *tag in tags) {
		[tagString appendFormat:@"<a name=\"%@\"></a>\n", tag];
	}
	
	NSDictionary *keys = [NSDictionary dictionaryWithObjectsAndKeys:
						  title, @"title",
						  tagString, @"tags",
						  [content stringValue], @"content",
						  book.appleTitle, @"APPLETITLE",
						  [book valueForKey:@"icon"], @"icon",
						  nil];
	
	NSString *output = [template stringByInsertingValues:keys];
	[output writeToFile:file atomically:NO encoding:NSUTF8StringEncoding error:nil];
}

@end
