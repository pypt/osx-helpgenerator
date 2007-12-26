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


#define INDEX_LETTERS [NSArray arrayWithObjects:@"a", @"b", @"c", @"d", @"e", @"f", @"g", @"h", @"i", @"j", @"k", @"l", @"m", @"n", @"o", @"p", @"q", @"r", @"s", @"t", @"u", @"v", @"w", @"x", @"y", @"z", @"all", nil]

@implementation HelpBook

@synthesize appleTitle, pagesByTag, name;

+ (HelpBook *)bookWithInputBase:(NSString *)input templateBase:(NSString *)template
{
	return [[[self alloc] initWithBasePath:input templateBase:template] autorelease];
}

- (id)initWithBasePath:(NSString *)path templateBase:(NSString *)template
{
	if (![super init])
		return nil;
	
	inputBase = path;
	
	templateBase = template;
	skeletonBase = [templateBase stringByAppendingPathComponent:@"Skeleton"];
	
	NSDictionary *infoDictionary = [NSDictionary dictionaryWithContentsOfFile:[path stringByAppendingPathComponent:@"Info.plist"]];
	name = [infoDictionary objectForKey:@"AppName"];
	appleTitle = [infoDictionary objectForKey:@"AppleTitle"];
	if ([infoDictionary objectForKey:@"Website"])
		url = [NSURL URLWithString:[infoDictionary objectForKey:@"Website"]];
	icon = [infoDictionary objectForKey:@"AppIcon"];
	smallIcon = [infoDictionary objectForKey:@"HelpIcon"];
	
	pagesByTag = [[NSMutableDictionary alloc] init];
	
	for (NSString *item in [[NSFileManager defaultManager] directoryContentsAtPath:path]) {
		if (![[item lowercaseString] hasSuffix:@".xml"])
			continue;

		NSXMLDocument *document = [[NSXMLDocument alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[path stringByAppendingPathComponent:item]] options:NSXMLDocumentTidyXML error:nil];
		if (!document) {
			NSLog(@"Warning: invalid XML document at %@", item);
			continue;
		}
		
		if ([[[document rootElement] name] isEqualToString:@"index"]) {
			index = [[NSMutableDictionary alloc] init];
			for (NSXMLNode *node in [document nodesForXPath:@"/index/item" error:nil]) {
				NSString *xname = [node stringValue];
				NSString *tag = [[(NSXMLElement *)node attributeForName:@"tag"] stringValue];
				[index setObject:tag forKey:xname];
			}
		}
		else if ([[[document rootElement] name] isEqualToString:@"access"]) {
			accessLinks = [[NSMutableDictionary alloc] init];
			for (id node in [document nodesForXPath:@"/access/main/item" error:nil]) {
				NSString *href = [[node attributeForName:@"href"] stringValue];
				NSString *desc = [node stringValue];
				[accessLinks setObject:desc forKey:href];
			}
			
			accessFeatures = [[NSMutableArray alloc] init];
			for (id node in [document nodesForXPath:@"/access/featured/item" error:nil]) {
				NSString *href = [[node attributeForName:@"href"] stringValue];
				[accessFeatures addObject:href];
			}
		}
		else {
			HelpPage *page = [[HelpPage alloc] initWithXMLDocument:document inHelpBook:self];
			for (NSString *tag in page.tags)
				[pagesByTag setObject:page forKey:tag];
			[page release];
		}
		
		[document release];
	}
	
	return self;
}

- (NSString *)accessPageContent
{
	NSMutableString *left = [NSMutableString string];
	for (NSString *href in accessLinks) {
		NSString *desc = [accessLinks objectForKey:href];
		NSString *title = [[pagesByTag objectForKey:href] valueForKey:@"title"];
		[left appendFormat:@"<p class=\"topleft_p\"><a href=\"help:anchor='%@' bookID='%@'\">%@</a><br/>%@</p>\n\n", href, appleTitle, title, desc];
	}
	
	NSMutableString *featured = [NSMutableString string];
	for (NSString *href in accessFeatures) {
		NSString *title = [[pagesByTag objectForKey:href] valueForKey:@"title"];
		[featured appendFormat:@"<p><a href=\"help:anchor='%@' bookID='%@'\">%@</a></p>\n\n", href, appleTitle, title];
	}
	
	PageTemplate *indexTemplate = [[[PageTemplate alloc] initWithURL:[NSURL fileURLWithPath:[templateBase stringByAppendingPathComponent:@"access.html"]]] autorelease];
	NSDictionary *keys = [NSDictionary dictionaryWithObjectsAndKeys:
						  [NSString stringWithFormat:NSLocalizedString(@"AppName Help", @""), name], @"title", 
						  left, @"left", 
						  featured, @"featured", 
						  appleTitle, @"appleTitle", 
						  [url absoluteString], @"link", 
						  [url host], @"linkdesc", 
						  icon ? icon : @"", @"icon", 
						  smallIcon ? smallIcon : @"", @"helpicon",
						  NSLocalizedString(@"Index", @""), @"index",
						  NSLocalizedString(@"Featured Topics", @""), @"FeaturedTopics",
						  name, @"appname",
						  nil];
	
	return [indexTemplate stringByInsertingValues:keys];
}

- (NSString *)indexHeadForPage:(NSString *)page
{
	NSMutableString *result = [NSMutableString string];
	for (NSString *letter in INDEX_LETTERS) {
		BOOL active = [page isEqualToString:letter];
		NSString *desc = [letter capitalizedString];
		if ([letter isEqualToString:@"all"])
			desc = NSLocalizedString(@"All", @"");
		if (active)
			[result appendFormat:@"<td width=\"19\"><div class=\"alphacircle\">%@</div></td>\n", desc];
		else
			[result appendFormat:@"<td width=\"19\"><a href=\"help:anchor='x%@' bookID='%@'\">%@</a></td>\n", letter, appleTitle, desc];
	}
	return result;
}

- (void)outputToDirectory:(NSString *)dir
{
	dir = [dir stringByAppendingPathComponent:appleTitle];
	
	// create a copy of the Skeleton directory
	NSFileManager *fm = [NSFileManager defaultManager];
	[fm removeItemAtPath:dir error:nil];	
	[fm copyPath:skeletonBase toPath:dir handler:nil];
	
	// copy additional images to the gfx directory
	for (NSString *path in [fm directoryContentsAtPath:[inputBase stringByAppendingPathComponent:@"gfx"]]){
		NSString *from = [[inputBase stringByAppendingPathComponent:@"gfx"] stringByAppendingPathComponent:path];
		[fm copyPath:from toPath:[[dir stringByAppendingPathComponent:@"gfx"] stringByAppendingPathComponent:path] handler:nil];
	}
	
	// write the customized list template
	PageTemplate *listTemplate = [[[PageTemplate alloc] initWithURL:[NSURL fileURLWithPath:[templateBase stringByAppendingPathComponent:@"genlist.html"]]] autorelease];
	[[listTemplate stringByInsertingValues:[NSDictionary dictionaryWithObjectsAndKeys:
											NSLocalizedString(@"Home", @""), @"home",
											NSLocalizedString(@"Index", @""), @"index",
											appleTitle, @"APPLETITLE", nil]] writeToFile:[dir stringByAppendingPathComponent:@"sty/genlist.html"] atomically:NO encoding:NSUTF8StringEncoding error:nil];
	
	// write the access page
	[[self accessPageContent] writeToFile:[dir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.html", appleTitle]] atomically:NO encoding:NSUTF8StringEncoding error:nil];
		
	// write content pages
	NSInteger count = 1;
	PageTemplate *simpleTemplate = [[[PageTemplate alloc] initWithURL:[NSURL fileURLWithPath:[templateBase stringByAppendingPathComponent:@"page.html"]]] autorelease];
	PageTemplate *xsltTemplate = [[[PageTemplate alloc] initWithURL:[NSURL fileURLWithPath:[templateBase stringByAppendingPathComponent:@"content.xslt"]]] autorelease];
	NSString *xslt = [xsltTemplate stringByInsertingValues:[NSDictionary dictionaryWithObjectsAndKeys:appleTitle, @"appleTitle", nil]];	
	for (HelpPage *page in [NSSet setWithArray:[pagesByTag allValues]])
		[page writeToFile:[[dir stringByAppendingPathComponent:@"pgs"] stringByAppendingPathComponent:[NSString stringWithFormat:@"%d.html", count++]] usingTemplate:simpleTemplate contentXSLT:xslt];
	
	// write index pages
	PageTemplate *xTemplate = [[[PageTemplate alloc] initWithURL:[NSURL fileURLWithPath:[templateBase stringByAppendingPathComponent:@"index.html"]]] autorelease];
	for (NSString *letter in INDEX_LETTERS) {
		NSMutableString *content = [NSMutableString string];
		for (NSString *x in index) {
			if (![[x lowercaseString] hasPrefix:letter] && ![letter isEqualToString:@"all"])
				continue;
			[content appendFormat:@"<tr><td><a href=\"help:topic_list=%@ bookID='%@' template=sty/genlist.html stylesheet=sty/genlist_style.css Other='%@'\">%@</a></td><td></td></tr>\n\n", [index objectForKey:x], appleTitle, x, x, nil];
		}
		
		NSDictionary *keys = [NSDictionary dictionaryWithObjectsAndKeys:
							  appleTitle, @"appleTitle",
							  content, @"content",
							  [self indexHeadForPage:letter], @"HEADLIST",
							  letter, @"letter",
							  NSLocalizedString(@"Index", @""), @"index",
							  NSLocalizedString(@"Home", @""), @"home",
							  nil];
		NSString *xall = [xTemplate stringByInsertingValues:keys];
		
		[xall writeToFile:[[dir stringByAppendingPathComponent:@"xpgs"] stringByAppendingPathComponent:[NSString stringWithFormat:@"x%@.html", letter]] atomically:NO encoding:NSUTF8StringEncoding error:nil];
	}
	
	system([[NSString stringWithFormat:@"\"/Developer/Applications/Utilities/Help Indexer.app/Contents/MacOS/Help Indexer\" \"%@\"", dir] UTF8String]);
}

@end
