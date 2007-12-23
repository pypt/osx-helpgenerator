#import <Foundation/Foundation.h>

#import "HelpBook.h"

int main (int argc, const char * argv[]) 
{
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	HelpBook *book = [HelpBook bookWithInputBase:@"/Users/jonaswitt/Desktop/Input"];
	
	NSLog(@"%@", [book pagesByTag]);
		
	[book outputToDirectory:@"/Users/jonaswitt/Development/Aurora/App/Resources/en.lproj/"];
    
    [pool drain];
    return 0;
}
