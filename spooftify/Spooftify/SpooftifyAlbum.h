/*
 Copyright (c) 2012 Will Sackfield
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
#import <Foundation/Foundation.h>
#include "despotify.h"

@interface SpooftifyAlbum : NSObject
{
    NSString* name;
    NSString* albumId;
    NSString* artistName;
    NSString* coverId;
    NSMutableArray* tracks;
    int year;
    
    BOOL hasBrowseInformation;
    
    struct album _album;
    struct album_browse _album_browse;
}

@property (nonatomic,readonly) NSString* name;
@property (nonatomic,readonly) NSString* albumId;
@property (nonatomic,readonly) NSString* artistName;
@property (nonatomic,readonly) NSString* coverId;
@property (nonatomic,readonly) NSArray* tracks;
@property (nonatomic,readonly) int year;
@property (nonatomic,readonly) BOOL hasBrowseInformation;

+(id) albumWithAlbum:(struct album*)album;
+(id) albumWithAlbumBrowse:(struct album_browse*)album_browse;
-(void) addBrowseInformation:(struct album_browse*)album_browse;

@end
