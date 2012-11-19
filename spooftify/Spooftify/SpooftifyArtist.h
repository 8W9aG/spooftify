/*
 Copyright (c) 2012 Will Sackfield
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
#import <Foundation/Foundation.h>
#include "despotify.h"

@interface SpooftifyArtist : NSObject
{
    NSString* name;
    NSString* artistId;
    NSString* portraitId;
    NSMutableArray* albums;
    
    BOOL hasBrowseInformation;
    
    struct artist _artist;
    struct artist_browse _artist_browse;
}

@property (nonatomic,readonly) NSString* name;
@property (nonatomic,readonly) NSString* artistId;
@property (nonatomic,readonly) NSString* portraitId;
@property (nonatomic,readonly) NSMutableArray* albums;
@property (nonatomic,readonly) BOOL hasBrowseInformation;

+(id) artistWithId:(NSString*)artistId;
+(id) artistWithArtist:(struct artist*)artist;
+(id) artistWithArtistBrowse:(struct artist_browse*)artist_browse;
-(void) addBrowseInformation:(struct artist_browse*)artist_browse;

@end
