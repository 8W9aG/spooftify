/*
 Copyright (c) 2012 Will Sackfield
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
#import "SpooftifyArtist.h"
#import "Spooftify.h"
#import "SpooftifyAlbum.h"

static NSMutableArray* artistPool = nil;

@interface SpooftifyArtist ()
-(id) initWithArtist:(struct artist*)artist;
-(id) initWithArtistBrowse:(struct artist_browse*)artistBrowse;
@end

@implementation SpooftifyArtist

@synthesize name;
@synthesize artistId;
@synthesize portraitId;
@synthesize albums;
@synthesize hasBrowseInformation;

+(void) initialize
{
    if(self == [SpooftifyArtist class])
    {
        artistPool = [[NSMutableArray alloc] init];
    }
}

+(id) artistWithId:(NSString*)artistId
{
    for(SpooftifyArtist* artist in artistPool)
    {
        if([[artist artistId] isEqualToString:artistId])
            return artist;
    }
    
    char _artistId[[artistId length]+1];
    memset(_artistId,'\0',[artistId length]+1);
    strcpy(_artistId,[artistId UTF8String]);
    
    struct artist_browse* artistBrowse = despotify_get_artist([Spooftify sharedSpooftify].ds,_artistId);
    if(artistBrowse != NULL)
        return [SpooftifyArtist artistWithArtistBrowse:artistBrowse];
    
    return nil;
}

+(id) artistWithArtist:(struct artist*)_artist
{
    NSString* artistId = [NSString stringWithUTF8String:(const char*)_artist->id];
    
    for(SpooftifyArtist* artist in artistPool)
    {
        if([[artist artistId] isEqualToString:artistId])
            return artist;
    }
    
    SpooftifyArtist* artist = [[SpooftifyArtist alloc] initWithArtist:_artist];
    return artist;
}

+(id) artistWithArtistBrowse:(struct artist_browse*)_artist_browse
{
    if(_artist_browse == NULL)
        return nil;
    
    NSString* artistId = [NSString stringWithUTF8String:(const char*)_artist_browse->id];
    
    for(SpooftifyArtist* artist in artistPool)
    {
        if([[artist artistId] isEqualToString:artistId])
        {
            if(![artist hasBrowseInformation])
                [artist addBrowseInformation:_artist_browse];
            return artist;
        }
    }
    
    SpooftifyArtist* artist = [[SpooftifyArtist alloc] initWithArtistBrowse:_artist_browse];
    return artist;
}

-(id) initWithArtist:(struct artist*)artist
{
    self = [super init];
    
    _artist = *artist;
    
    name = [[NSString alloc] initWithUTF8String:_artist.name];
    artistId = [[NSString alloc] initWithUTF8String:(const char*)_artist.id];
    portraitId = [[NSString alloc] initWithUTF8String:_artist.portrait_id];
    albums = [[NSMutableArray alloc] init];
    
    [artistPool addObject:self];
    
    return self;
}

-(id) initWithArtistBrowse:(struct artist_browse*)artistBrowse
{
    self = [super init];
    
    _artist_browse = *artistBrowse;
    
    name = [[NSString alloc] initWithUTF8String:_artist_browse.name];
    artistId = [[NSString alloc] initWithUTF8String:(const char*)_artist_browse.id];
    portraitId = [[NSString alloc] initWithUTF8String:_artist_browse.portrait_id];
    albums = [[NSMutableArray alloc] init];
    
    [self addBrowseInformation:artistBrowse];
    
    [artistPool addObject:self];
    
    return self;
}

-(void) addBrowseInformation:(struct artist_browse*)artist_browse
{
    _artist_browse = *artist_browse;
    
    struct album_browse* album_browse = _artist_browse.albums;
    while(album_browse != NULL)
    {
        SpooftifyAlbum* album = [SpooftifyAlbum albumWithAlbumBrowse:album_browse];
        if(![albums containsObject:album])
            [albums addObject:album];
        album_browse = album_browse->next;
    }
    
    hasBrowseInformation = YES;
}

@end
