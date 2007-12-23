//
//  PageTemplate.m
//  HelpGenerator
//
//  Created by Jonas Witt on 12/22/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "PageTemplate.h"


@implementation PageTemplate

- (id)initWithURL:(NSURL *)url
{
	if (![super init])
		return nil;
	
	source = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
	
	return self;
}

- (NSString *)stringByInsertingValues:(NSDictionary *)dictionary
{
	NSString *string = source;
	for (NSString *key in dictionary) {
		string = [string stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"$$%@$$", [key uppercaseString]] withString:[dictionary objectForKey:key]];
	}
	return string;
}

@end
