/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "KKAppStoreHelper.h"

@implementation KKAppStoreHelper

+(NSString*) appStoreURLforSearchTerm:(const NSString* const)searchTerm
{
	NSString* escapedSearchTerm = [searchTerm stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSString* url = @"http://phobos.apple.com/WebObjects/MZSearch.woa/wa/search?";
	NSString* urlParams = @"WOURLEncoding=ISO8859_1&lang=1&output=lm&country=US";
	return [NSString stringWithFormat:@"%@%@&term=%@&media=software", url, urlParams, escapedSearchTerm];
}

+(NSString*) artistURL:(const NSString* const)artist
{
	return [NSString stringWithFormat:@"http://itunes.apple.com/us/artist/%@", artist];
}

@end
