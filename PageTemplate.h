//
//  PageTemplate.h
//  HelpGenerator
//
//  Created by Jonas Witt on 12/22/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PageTemplate : NSObject {

	NSString *source;
	
}

- (id)initWithURL:(NSURL *)url;

- (NSString *)stringByInsertingValues:(NSDictionary *)dictionary;

@end
