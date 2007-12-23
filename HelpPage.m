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
		
	NSMutableString *cont = [NSMutableString string];
	for (NSXMLNode *c in [content children])
		[self writeContentNode:c toBuffer:cont forBook:book];
	
	NSLog(cont);
	
	NSDictionary *keys = [NSDictionary dictionaryWithObjectsAndKeys:
						  title, @"title",
						  tagString, @"tags",
						  cont, @"content",
						  book.appleTitle, @"APPLETITLE",
						  [book valueForKey:@"icon"], @"icon",
						  nil];
	
	NSString *output = [template stringByInsertingValues:keys];
	[output writeToFile:file atomically:NO encoding:NSUTF8StringEncoding error:nil];
}

- (void)writeContentNode:(NSXMLNode *)node toBuffer:(NSMutableString *)buffer forBook:(HelpBook *)book
{
	if ([node kind] == NSXMLTextKind) {
		[buffer appendString:[node stringValue]];
	}
	else {
		NSString *link = nil;
		if ([[node name] isEqualToString:@"help:a"]) {
			link = [[(NSXMLElement *)node attributeForName:@"href"] stringValue];
			[buffer appendFormat:@"<a href=\"help:anchor='%@' bookID=%@\">", link, book.appleTitle];
		}
		else if ([node kind] == NSXMLElementKind) {
			NSMutableString *attr = [NSMutableString string];
			for (NSXMLNode *a in [(NSXMLElement *)node attributes])
				[attr appendFormat:@" %@", [a XMLString]];
			[buffer appendFormat:@"<%@%@>", [node name], attr];
		}
		
		for (NSXMLNode *child in [node children]) {
			[self writeContentNode:child toBuffer:buffer forBook:book];
		}
		
		if (link) 
			[buffer appendString:@"</a> "];
		else if ([node kind] == NSXMLElementKind)
			[buffer appendFormat:@"</%@> ", [node name]];
	}
}

@end
