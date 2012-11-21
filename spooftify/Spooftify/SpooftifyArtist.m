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

#pragma mark NSObject

// When SpooftifyArtist is first used
+(void) initialize
{
    // Check we have the right class
    if(self == [SpooftifyArtist class])
    {
        // Initialise the pool of artists
        artistPool = [[NSMutableArray alloc] init];
        
        // Sign up to receive application memory warnings
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveMemoryWarning) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    }
}

#pragma mark SpooftifyArtist

// Create a SpooftifyArtist with a despotify artist
+(id) artistWithArtist:(struct artist*)_artist
{
    // Create an NSString with the artist id
    NSString* artistId = [NSString stringWithUTF8String:(const char*)_artist->id];
    
    // Loop through the artists in the pool
    for(SpooftifyArtist* artist in artistPool)
    {
        // If an artist contains our id we'll use that
        if([[artist artistId] isEqualToString:artistId])
            return artist;
    }
    
    // Else just create an artist and return it
    SpooftifyArtist* artist = [[SpooftifyArtist alloc] initWithArtist:_artist];
    return artist;
}

// Create a SpooftifyArtist with a despotify artist_browse
+(id) artistWithArtistBrowse:(struct artist_browse*)_artist_browse
{
    // Create an NSString with the artist ID
    NSString* artistId = [NSString stringWithUTF8String:(const char*)_artist_browse->id];
    
    // Loop through the artists in the pool
    for(SpooftifyArtist* artist in artistPool)
    {
        // If we find one that contains our ID return it
        if([[artist artistId] isEqualToString:artistId])
        {
            // Check if it has browse information
            if(![artist hasBrowseInformation])
                // If not add it
                [artist addBrowseInformation:_artist_browse];
            
            return artist;
        }
    }
    
    // Else just create an artist with the information
    SpooftifyArtist* artist = [[SpooftifyArtist alloc] initWithArtistBrowse:_artist_browse];
    return artist;
}

// Initialise with a despotify artist
-(id) initWithArtist:(struct artist*)artist
{
    self = [super init];
    
    _artist = *artist;
    
    // Fill in the artist variables
    name = [[NSString alloc] initWithUTF8String:_artist.name];
    artistId = [[NSString alloc] initWithUTF8String:(const char*)_artist.id];
    portraitId = [[NSString alloc] initWithUTF8String:_artist.portrait_id];
    albums = [[NSMutableArray alloc] init];
    
    // Add our artist to the pool
    [artistPool addObject:self];
    
    return self;
}

// Initialise with a despotify artist_browse
-(id) initWithArtistBrowse:(struct artist_browse*)artistBrowse
{
    self = [super init];
    
    _artist_browse = *artistBrowse;
    
    // Fill in the artist variables
    name = [[NSString alloc] initWithUTF8String:_artist_browse.name];
    artistId = [[NSString alloc] initWithUTF8String:(const char*)_artist_browse.id];
    portraitId = [[NSString alloc] initWithUTF8String:_artist_browse.portrait_id];
    albums = [[NSMutableArray alloc] init];
    
    // Add the browse information
    [self addBrowseInformation:artistBrowse];
    
    // Add this artist to the pool
    [artistPool addObject:self];
    
    return self;
}

// Add browse information to this artist
-(void) addBrowseInformation:(struct artist_browse*)artist_browse
{
    _artist_browse = *artist_browse;
    
    // Loop through the albums and add them to the artist
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

#pragma mark UIApplication Notification

// If the app is running low on memory
+(void) didReceiveMemoryWarning
{
    // Drain the pool
    [artistPool removeAllObjects];
}

@end
