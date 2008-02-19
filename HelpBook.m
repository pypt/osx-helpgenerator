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

int sortIndex(id o1, id o2, void* context) {
	NSString *t1 = [o1 objectAtIndex:1];
	NSString *t2 = [o2 objectAtIndex:1];
	return [t1 caseInsensitiveCompare:t2];
}

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
	
	localization = [infoDictionary objectForKey:@"Language"];
	if (!localization)
		localization = @"en";
	NSString *stringsPath = [[NSBundle mainBundle] pathForResource:@"Localizable" ofType:@"strings" inDirectory:@"" forLocalization:localization];
	strings = [[NSDictionary alloc] initWithContentsOfFile:stringsPath];
		
	pagesByTag = [[NSMutableDictionary alloc] init];
	pages = [[NSMutableSet alloc] init];
	
	for (NSString *item in [[NSFileManager defaultManager] directoryContentsAtPath:path]) {
		if (![[item lowercaseString] hasSuffix:@".xml"])
			continue;

		NSXMLDocument *document = [[NSXMLDocument alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[path stringByAppendingPathComponent:item]] options:NSXMLDocumentTidyXML error:nil];
		if (!document) {
			NSLog(@"Warning: invalid XML document at %@", item);
			continue;
		}
		
		if ([[[document rootElement] name] isEqualToString:@"index"]) {
			index = [[NSMutableArray alloc] init];
			for (id node in [document nodesForXPath:@"/index/entry" error:nil]) {
				NSString *xname = [node stringValue];
				NSString *tag = [[node attributeForName:@"tag"] stringValue];
				[index addObject:[NSArray arrayWithObjects:tag, xname, nil]];
			}
			[index sortUsingFunction:sortIndex context:nil];
		}
		else if ([[[document rootElement] name] isEqualToString:@"access"]) {
			accessLinks = [[NSMutableArray alloc] init];
			for (id node in [document nodesForXPath:@"/access/main/item" error:nil]) {
				NSString *href = [[node attributeForName:@"href"] stringValue];
				NSString *desc = [node stringValue];
				[accessLinks addObject:[NSArray arrayWithObjects:href, desc, nil]];
			}
			
			accessFeatures = [[NSMutableArray alloc] init];
			for (id node in [document nodesForXPath:@"/access/featured/item" error:nil]) {
				NSString *href = [[node attributeForName:@"href"] stringValue];
				[accessFeatures addObject:href];
			}
		}
		else {
			HelpPage *page = [[HelpPage alloc] initWithXMLDocument:document inHelpBook:self];
			for (NSString *tag in page.tags) {
				NSMutableSet *set = [pagesByTag objectForKey:tag];
				if (!set)
					set = [NSMutableSet set];
				[set addObject:page];
				[pagesByTag setObject:set forKey:tag];
			}
			[pages addObject:page];
			[page release];
		}
				
		[document release];
	}
	
	return self;
}

- (NSString *)linkToTag:(NSString *)tag listTitle:(NSString *)title
{
	if ([[pagesByTag objectForKey:tag] count] > 1) 
		return [NSString stringWithFormat:@"help:topic_list=%@ bookID='%@' template=sty/genlist.html stylesheet=sty/genlist_style.css Other='%@'", tag, appleTitle, title];
	return [NSString stringWithFormat:@"help:anchor='%@' bookID='%@'", tag, appleTitle];
}

- (NSString *)accessPageContent
{
	NSMutableString *left = [NSMutableString string];
	for (NSArray *a in accessLinks) {
		NSString *href = [a objectAtIndex:0];
		NSString *desc = [a objectAtIndex:1];
		NSString *title = [[[pagesByTag objectForKey:href] anyObject] valueForKey:@"title"];
		[left appendFormat:@"<p class=\"topleft_p\"><a href=\"%@\">%@</a><br/>%@</p>\n\n", [self linkToTag:href listTitle:title], title, desc];
	}
	
	NSMutableString *featured = [NSMutableString string];
	for (NSString *href in accessFeatures) {
		NSString *title = [[[pagesByTag objectForKey:href] anyObject] valueForKey:@"title"];
		[featured appendFormat:@"<p><a href=\"%@\">%@</a></p>\n\n", [self linkToTag:href listTitle:title], title];
	}
	
	PageTemplate *indexTemplate = [[[PageTemplate alloc] initWithURL:[NSURL fileURLWithPath:[templateBase stringByAppendingPathComponent:@"access.html"]]] autorelease];
	NSDictionary *keys = [NSDictionary dictionaryWithObjectsAndKeys:
						  [NSString stringWithFormat:[self localize:@"AppName Help"], name], @"title", 
						  left, @"left", 
						  featured, @"featured", 
						  appleTitle, @"appleTitle", 
						  [url absoluteString], @"link", 
						  [url host], @"linkdesc", 
						  icon ? icon : @"", @"icon", 
						  smallIcon ? smallIcon : @"", @"helpicon",
						  [self localize:@"Index"], @"index",
						  [self localize:@"Featured Topics"], @"FeaturedTopics",
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
			desc = [self localize:@"All"];
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
											[self localize:@"Home"], @"home",
											[self localize:@"Index"], @"index",
											appleTitle, @"APPLETITLE", nil]] writeToFile:[dir stringByAppendingPathComponent:@"sty/genlist.html"] atomically:NO encoding:NSUTF8StringEncoding error:nil];
	
	// write the access page
	[[self accessPageContent] writeToFile:[dir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.html", appleTitle]] atomically:NO encoding:NSUTF8StringEncoding error:nil];
		
	// write content pages
	NSInteger count = 1;
	PageTemplate *simpleTemplate = [[[PageTemplate alloc] initWithURL:[NSURL fileURLWithPath:[templateBase stringByAppendingPathComponent:@"page.html"]]] autorelease];
	PageTemplate *xsltTemplate = [[[PageTemplate alloc] initWithURL:[NSURL fileURLWithPath:[templateBase stringByAppendingPathComponent:@"content.xslt"]]] autorelease];
	NSString *xslt = [xsltTemplate stringByInsertingValues:[NSDictionary dictionaryWithObjectsAndKeys:appleTitle, @"appleTitle", 						  [self localize:@"Preference"], @"preference", [self localize:@"Explanation"], @"explanation", nil]];	
	[[NSFileManager defaultManager] createDirectoryAtPath:[dir stringByAppendingPathComponent:@"pgs"] attributes:nil];
	for (HelpPage *page in pages) {
		[page writeToFile:[[dir stringByAppendingPathComponent:@"pgs"] stringByAppendingPathComponent:[NSString stringWithFormat:@"%d.html", count++]] usingTemplate:simpleTemplate contentXSLT:xslt];		
	}
	
	// write index pages
	PageTemplate *xTemplate = [[[PageTemplate alloc] initWithURL:[NSURL fileURLWithPath:[templateBase stringByAppendingPathComponent:@"index.html"]]] autorelease];
	[[NSFileManager defaultManager] createDirectoryAtPath:[dir stringByAppendingPathComponent:@"xpgs"] attributes:nil];
	for (NSString *letter in INDEX_LETTERS) {
		NSMutableString *content = [NSMutableString string];
		for (NSArray *a in index) {
			NSString *x = [a objectAtIndex:1];
			if (![[x lowercaseString] hasPrefix:letter] && ![letter isEqualToString:@"all"])
				continue;
			NSString *tag = [a objectAtIndex:0];
			[content appendFormat:@"<tr><td><a href=\"%@\">%@</a></td><td></td></tr>\n\n", [self linkToTag:tag listTitle:x], x, nil];
		}
		
		NSDictionary *keys = [NSDictionary dictionaryWithObjectsAndKeys:
							  appleTitle, @"appleTitle",
							  content, @"content",
							  [self indexHeadForPage:letter], @"HEADLIST",
							  letter, @"letter",
							  [self localize:@"Index"], @"index",
							  [self localize:@"Home"], @"home",
							  nil];
		NSString *xall = [xTemplate stringByInsertingValues:keys];
		
		[xall writeToFile:[[dir stringByAppendingPathComponent:@"xpgs"] stringByAppendingPathComponent:[NSString stringWithFormat:@"x%@.html", letter]] atomically:NO encoding:NSUTF8StringEncoding error:nil];
	}
	
	system([[NSString stringWithFormat:@"\"/Developer/Applications/Utilities/Help Indexer.app/Contents/MacOS/Help Indexer\" \"%@\" -PantherIndexing YES -Tokenizer 1 -ShowProgress NO -UseRemoteRoot NO -LogStyle 1 -IndexAnchors YES -TigerIndexing YES -GenerateSummaries YES -StopWords en -MinTermLength 3", dir] UTF8String]);
}

- (NSString *)localize:(NSString *)key
{
	NSString *value = [strings objectForKey:key];
	if (value)
		return value;
	return key;
}

@end
