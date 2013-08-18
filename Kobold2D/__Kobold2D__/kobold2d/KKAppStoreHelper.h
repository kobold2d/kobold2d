/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import <Foundation/Foundation.h>

/** Helper methods for App Store & iTunes related things */
@interface KKAppStoreHelper : NSObject 
{
@private
}

/** Creates an App Store URL for the iPhone's App Store that shows the desired search term.
 This seems to be the only way to show all the Apps of a particular company.
 Original code obtained from here: http://arstechnica.com/apple/news/2008/12/linking-to-the-stars-hacking-itunes-to-solicit-reviews.ars */
+(NSString*) appStoreURLforSearchTerm:(const NSString* const)searchTerm;

/** Returns the URL of an artist (developer). */
+(NSString*) artistURL:(const NSString* const)artist;

@end
