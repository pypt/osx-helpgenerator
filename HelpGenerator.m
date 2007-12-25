#import <Foundation/Foundation.h>

#import "HelpBook.h"

int main (int argc, const char * argv[]) 
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		
	NSMutableArray *args = [NSMutableArray array];
	NSFileManager *fm = [NSFileManager defaultManager];
	int i;
	for (i = 1; i < argc; i++) {
		NSString *arg = [[NSString stringWithUTF8String:argv[i]] stringByExpandingTildeInPath];
		if (![fm fileExistsAtPath:arg])
			continue;
		[args addObject:arg];
	}
		
	if ([args count]) {
		NSString *base = [args objectAtIndex:0];
		NSString *output = nil;
		if ([args count] > 1)
			output = [args objectAtIndex:1];
		else
			output = base;
		NSString *template = [[NSBundle mainBundle] pathForResource:@"Template" ofType:@""];
				
		HelpBook *book = [HelpBook bookWithInputBase:base templateBase:template];
		[book outputToDirectory:output];
	}
	else
		NSApplicationMain(argc, argv);
    
    [pool drain];
    return 0;
}
