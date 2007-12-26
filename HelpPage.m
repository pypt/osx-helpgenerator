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

@synthesize tags, title, content, related;

- (id)initWithXMLDocument:(NSXMLDocument *)document inHelpBook:(HelpBook *)book
{
	if (![super init])
		return nil;
	
	helpBook = book;
		
	tags = [[NSMutableArray alloc] init];
	for (NSXMLNode *tagNode in [document nodesForXPath:@"/page/tag" error:nil])
		[tags addObject:[tagNode stringValue]];
	
	title = [[[[document nodesForXPath:@"/page/title" error:nil] lastObject] stringValue] copy];
	
	content = [[[document nodesForXPath:@"/page/content" error:nil] lastObject] retain];
	related = [[[document nodesForXPath:@"/page/related" error:nil] lastObject] retain];
	
	return self;
}

- (void)writeToFile:(NSString *)file usingTemplate:(PageTemplate *)template contentXSLT:(NSString *)xslt
{
	NSMutableString *tagString = [NSMutableString string];
	for (NSString *tag in tags)
		[tagString appendFormat:@"<a name=\"%@\"></a>\n", tag];
	
	NSXMLDocument *contDoc = [NSXMLDocument documentWithRootElement:(NSXMLElement *)[[content copy] autorelease]];
	id cont = [contDoc objectByApplyingXSLTString:xslt arguments:nil error:nil];
	
	NSString *transformedOutput = nil;
	if ([cont isKindOfClass:[NSData class]])
		transformedOutput = [[[NSString alloc] initWithData:cont encoding:NSUTF8StringEncoding] autorelease];
	else
		transformedOutput = [[cont rootElement] XMLString];

	NSMutableString *relatedString = [NSMutableString string];
	NSArray *relatedLinks = [related children];
	if ([relatedLinks count]) {
		[relatedString appendFormat:@"<div id=\"linkinternalbox\"><h3>%@</h3>", [helpBook localize:@"Related Topics"]];
		for (NSXMLNode *item in relatedLinks) {
			NSString *link = [[(NSXMLElement *)item attributeForName:@"tag"] stringValue];
			[relatedString appendFormat:@"<p class=\"linkinternal\"><a href=\"help:anchor='%@' bookID='%@'\">%@ <span class=\"linkarrow\"></span></a></p>", link, helpBook.appleTitle, [[helpBook.pagesByTag objectForKey:link] valueForKey:@"title"]];
		}
		[relatedString appendString:@"</div>"];		
	}
	
	NSDictionary *keys = [NSDictionary dictionaryWithObjectsAndKeys:
						  title, @"title",
						  tagString, @"tags",
						  transformedOutput, @"content",
						  helpBook.appleTitle, @"APPLETITLE",
						  [helpBook valueForKey:@"icon"], @"icon",
						  relatedString, @"related",
						  helpBook.name, @"appname",
						  [helpBook localize:@"Home"], @"home",
						  [helpBook localize:@"Index"], @"index",
						  nil];
	
	NSString *output = [template stringByInsertingValues:keys];
	[output writeToFile:file atomically:NO encoding:NSUTF8StringEncoding error:nil];
}

@end
