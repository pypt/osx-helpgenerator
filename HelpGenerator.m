#import <Foundation/Foundation.h>

#import "HelpBook.h"

int main (int argc, const char * argv[]) 
{
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	NSString *base = @"/Users/jonaswitt/Desktop/AuroraInput";
	
	HelpBook *book = [HelpBook bookWithInputBase:base];
			
	[book outputToDirectory:@"/Users/jonaswitt/Development/Aurora/App/Resources/en.lproj/"];
    
    [pool drain];
    return 0;
}
