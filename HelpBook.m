//
//  HelpBook.m
//  HelpGenerator
//
//  Created by Jonas Witt on 12/22/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "HelpBook.h"

#import "HelpPage.h"
#import "PageTemplate.h"

@implementation HelpBook

@synthesize appleTitle;

+ (HelpBook *)bookWithInputBase:(NSString *)input
{
	HelpBook *book = [[[self alloc] init] autorelease];
	
	NSXMLDocument *doc = [[NSXMLDocument alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[input stringByAppendingPathComponent:@"help.xml"]] options:NSXMLDocumentTidyXML error:nil];
	
	[book setValue:input forKey:@"inputBase"];
	[book setValue:doc forKey:@"document"];
	
	NSString *name = [[[doc nodesForXPath:@"/help/head/name" error:nil] lastObject] stringValue];
	[book setValue:name forKey:@"name"];
	
	NSString *appleTitle = [[[doc nodesForXPath:@"/help/head/AppleTitle" error:nil] lastObject] stringValue];
	[book setValue:appleTitle forKey:@"appleTitle"];
	
	NSString *link = [[[[doc nodesForXPath:@"/help/head/website" error:nil] lastObject] attributeForName:@"href"] stringValue];
	[book setValue:[NSURL URLWithString:link] forKey:@"url"];

	NSString *icon = [[[[doc nodesForXPath:@"/help/head/icon" error:nil] lastObject] attributeForName:@"href"] stringValue];
	[book setValue:icon forKey:@"icon"];
	
	NSString *base = @"/Users/jonaswitt/Development/HelpGenerator";
	
	[book setValue:[base stringByAppendingPathComponent:@"Template"] forKey:@"templateBase"];
	[book setValue:[base stringByAppendingPathComponent:@"Skeleton"] forKey:@"skeletonBase"];
	
	[book setValue:[NSArray arrayWithObjects:@"a", @"b", @"c", @"d", @"e", @"f", @"g", @"h", @"i", @"j", @"k", @"l", @"m", @"n", @"o", @"p", @"q", @"r", @"s", @"t", @"u", @"v", @"w", @"x", @"y", @"z", @"all", nil] forKey:@"letters"];
	
	return book;
}

- (NSDictionary *)pagesByTag
{
	if (pagesByTag)
		return pagesByTag;
	
	NSMutableDictionary *result = [NSMutableDictionary dictionary];
	
	for (NSXMLNode *node in [document nodesForXPath:@"/help/pages/page" error:nil]) {

		NSMutableArray *tags = [NSMutableArray array];
		for (NSXMLNode *tagNode in [node nodesForXPath:@"tag" error:nil])
			[tags addObject:[tagNode stringValue]];
		
		NSString *title = [[[node nodesForXPath:@"title" error:nil] lastObject] stringValue];
		
		NSXMLNode *content = [[node nodesForXPath:@"content" error:nil] lastObject];
		
		HelpPage *page = [[HelpPage alloc] init];
		
		page.tags = tags;
		page.title = title;
		page.content = content;
		
		for (NSString *tag in tags) 
			[result setObject:page forKey:tag];
		
	}
	
	return pagesByTag = result;
}

- (NSString *)indexPageContent
{
	NSMutableString *left = [NSMutableString string];
	for (NSXMLNode *node in [document nodesForXPath:@"/help/access/main/item" error:nil]) {
		NSString *href = [[(NSXMLElement *)node attributeForName:@"href"] stringValue];
		NSString *desc = [node stringValue];
		NSString *title = [[[self pagesByTag] objectForKey:href] valueForKey:@"title"];
		[left appendFormat:@"<p class=\"topleft_p\"><a href=\"help:anchor='%@' bookID=%@\">%@</a><br/>%@</p>\n\n", href, appleTitle, title, desc];
	}
	
	NSMutableString *featured = [NSMutableString string];
	for (NSXMLNode *node in [document nodesForXPath:@"/help/access/featured/item" error:nil]) {
		NSString *href = [[(NSXMLElement *)node attributeForName:@"href"] stringValue];
		NSString *title = [[[self pagesByTag] objectForKey:href] valueForKey:@"title"];
		[featured appendFormat:@"<p><a href=\"help:anchor='%@' bookID=%@\">%@</a></p>\n\n", href, appleTitle, title];
	}
	
	PageTemplate *indexTemplate = [[[PageTemplate alloc] initWithURL:[NSURL fileURLWithPath:[templateBase stringByAppendingPathComponent:@"index.html"]]] autorelease];
	NSDictionary *keys = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%@ Help", name], @"title", left, @"left", featured, @"featured", appleTitle, @"appleTitle", [url absoluteString], @"link", [url host], @"linkdesc", icon, @"icon", nil];
	
	return [indexTemplate stringByInsertingValues:keys];
}

- (NSDictionary *)indexItems
{
	NSMutableDictionary *result = [NSMutableDictionary dictionary];
	for (NSXMLNode *node in [document nodesForXPath:@"/help/index/item" error:nil]) {
		NSString *xname = [node stringValue];
		NSString *tag = [[(NSXMLElement *)node attributeForName:@"tag"] stringValue];
		[result setObject:tag forKey:xname];
	}
	return result;
}

- (NSString *)indexHeadForPage:(NSString *)page
{
	NSMutableString *result = [NSMutableString string];
	for (NSString *letter in letters) {
		BOOL active = [page isEqualToString:letter];
		if (active)
			[result appendFormat:@"<td width=\"19\"><div class=\"alphacircle\">%@</div></td>\n", [letter capitalizedString]];
		else
			[result appendFormat:@"<td width=\"19\"><a href=\"help:anchor='x%@' bookID=%@\">%@</a></td>\n", letter, appleTitle, [letter capitalizedString]];
	}
	return result;
}

- (NSString *)replaceInString:(NSString *)string keys:(NSDictionary *)dict
{
	for (NSString *key in dict) {
		string = [string stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"$$%@$$", [key uppercaseString]] withString:[dict objectForKey:key]];
	}
	return string;
}

- (void)outputToDirectory:(NSString *)dir
{
	dir = [dir stringByAppendingPathComponent:appleTitle];
	
	NSFileManager *fm = [NSFileManager defaultManager];
	[fm removeItemAtPath:dir error:nil];	
	[fm copyPath:skeletonBase toPath:dir handler:nil];
	
	// cpy gfx
	for (NSString *path in [fm directoryContentsAtPath:[inputBase stringByAppendingPathComponent:@"gfx"]]){
		NSString *from = [[inputBase stringByAppendingPathComponent:@"gfx"] stringByAppendingPathComponent:path];
		[fm copyPath:from toPath:[[dir stringByAppendingPathComponent:@"gfx"] stringByAppendingPathComponent:path] handler:nil];
	}
	
	[[self indexPageContent] writeToFile:[dir stringByAppendingPathComponent:@"index.html"] atomically:NO encoding:NSUTF8StringEncoding error:nil];
		
	NSMutableSet *pagesWritten = [NSMutableSet set];
	NSInteger count = 0;
	NSDictionary *pages = [self pagesByTag];
	PageTemplate *simpleTemplate = [[[PageTemplate alloc] initWithURL:[NSURL fileURLWithPath:[templateBase stringByAppendingPathComponent:@"page.html"]]] autorelease];
	for (NSString *tag in pages) {
		HelpPage *page = [pages objectForKey:tag];
		if ([pagesWritten containsObject:page])
			continue;
		
		[page writeToFile:[[dir stringByAppendingPathComponent:@"pgs"] stringByAppendingPathComponent:[NSString stringWithFormat:@"%d.html", count++]] ofBook:self usingTemplate:simpleTemplate];
		[pagesWritten addObject:page];
	}
	
	
	PageTemplate *xTemplate = [[[PageTemplate alloc] initWithURL:[NSURL fileURLWithPath:[templateBase stringByAppendingPathComponent:@"x.html"]]] autorelease];
	
	for (NSString *letter in letters) {

		NSMutableString *content = [NSMutableString string];
		NSDictionary *index = [self indexItems];
		for (NSString *x in index) {
			if (![[x lowercaseString] hasPrefix:letter] && ![letter isEqualToString:@"all"])
				continue;
			[content appendFormat:@"<tr><td><a href=\"help:topic_list=%@ bookID='%@' template=sty/genlist.html stylesheet=sty/genlist_style.css Other=%@\">%@</a></td><td></td></tr>\n\n", [index objectForKey:x], appleTitle, x, x, nil];
		}
		
		NSDictionary *keys = [NSDictionary dictionaryWithObjectsAndKeys:
							  appleTitle, @"appleTitle",
							  content, @"content",
							  [self indexHeadForPage:letter], @"HEADLIST",
							  letter, @"letter",
							  nil];
		NSString *xall = [xTemplate stringByInsertingValues:keys];
		
		[xall writeToFile:[[dir stringByAppendingPathComponent:@"xpgs"] stringByAppendingPathComponent:[NSString stringWithFormat:@"x%@.html", letter]] atomically:NO encoding:NSUTF8StringEncoding error:nil];

	}
	
	system([[NSString stringWithFormat:@"\"/Developer/Applications/Utilities/Help Indexer.app/Contents/MacOS/Help Indexer\" \"%@\"", dir] UTF8String]);
	
}

@end
