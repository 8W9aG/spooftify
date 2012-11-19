/*
 Copyright (c) 2012 Will Sackfield
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
#import "SpooftifyAlbum.h"
#import "Spooftify.h"

static NSMutableArray* albumPool = nil;

@interface SpooftifyAlbum ()
-(id) initWithAlbum:(struct album*)album;
-(id) initWithAlbumBrowse:(struct album_browse*)album_browse;
@end

@implementation SpooftifyAlbum

@synthesize name;
@synthesize albumId;
@synthesize artistName;
@synthesize coverId;
@synthesize tracks;
@synthesize year;
@synthesize hasBrowseInformation;

+(void) initialize
{
    if(self == [SpooftifyAlbum class])
    {
        albumPool = [[NSMutableArray alloc] init];
    }
}

+(id) albumWithId:(NSString*)albumId
{
    for(SpooftifyAlbum* album in albumPool)
    {
        if([[album albumId] isEqualToString:albumId])
            return album;
    }
    
    int albumLen = [albumId length];
    char _albumId[albumLen+1];
    memset(_albumId,'\0',albumLen+1);
    strcpy(_albumId,[albumId UTF8String]);

    struct album_browse* album_browse = despotify_get_album([Spooftify sharedSpooftify].ds,_albumId);
    if(album_browse != NULL)
        return [SpooftifyAlbum albumWithAlbumBrowse:album_browse];
    
    return nil;
}

+(id) albumWithAlbum:(struct album*)_album
{
    NSString* albumId = [NSString stringWithUTF8String:(const char*)_album->id];
    
    for(SpooftifyAlbum* album in albumPool)
    {
        if([[album albumId] isEqualToString:albumId])
            return album;
    }
    
    SpooftifyAlbum* album = [[SpooftifyAlbum alloc] initWithAlbum:_album];
    return album;
}

+(id) albumWithAlbumBrowse:(struct album_browse*)_album_browse
{
    NSString* albumId = [NSString stringWithUTF8String:(const char*)_album_browse];
    
    for(SpooftifyAlbum* album in albumPool)
    {
        if([[album albumId] isEqualToString:albumId])
        {
            if(![album hasBrowseInformation])
                [album addBrowseInformation:_album_browse];
            return album;
        }
    }
    
    SpooftifyAlbum* album = [[SpooftifyAlbum alloc] initWithAlbumBrowse:_album_browse];
    return album;
}

-(id) initWithAlbum:(struct album*)album
{
    self = [super init];
    
    _album = *album;
    
    name = [[NSString alloc] initWithUTF8String:_album.name];
    albumId = [[NSString alloc] initWithUTF8String:(const char*)_album.id];
    artistName = [[NSString alloc] initWithUTF8String:_album.artist];
    coverId = [[NSString alloc] initWithUTF8String:_album.cover_id];
    tracks = [[NSMutableArray alloc] init];
    
    [albumPool addObject:self];
    
    return self;
}

-(id) initWithAlbumBrowse:(struct album_browse*)album_browse
{
    self = [super init];
    
    _album_browse = *album_browse;
    
    name = [[NSString alloc] initWithUTF8String:_album_browse.name];
    albumId = [[NSString alloc] initWithUTF8String:(const char*)_album_browse.id];
    artistName = [[NSString alloc] initWithUTF8String:_album_browse.tracks->artist->name];
    coverId = [[NSString alloc] initWithUTF8String:_album_browse.cover_id];
    tracks = [[NSMutableArray alloc] init];
    
    [self addBrowseInformation:album_browse];
    
    [albumPool addObject:self];
    
    return self;
}

-(void) addBrowseInformation:(struct album_browse*)album_browse
{
    _album_browse = *album_browse;
    
    year = _album_browse.year;
    struct track* track = _album_browse.tracks;
    while(track != NULL)
    {
        SpooftifyTrack* _track = [SpooftifyTrack trackWithTrack:track];
        [tracks addObject:_track];
        track = track->next;
    }
    
    hasBrowseInformation = YES;
}

@end
