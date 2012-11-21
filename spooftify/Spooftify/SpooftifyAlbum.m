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

#pragma mark NSObject

// When SpooftifyAlbum is first used
+(void) initialize
{
    // Check if we are in the right class
    if(self == [SpooftifyAlbum class])
    {
        // Create a pool for album objects
        albumPool = [[NSMutableArray alloc] init];
        
        // Sign up to receive application memory warnings
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveMemoryWarning) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    }
}

#pragma mark SpooftifyAlbum

// Create an album with a despotify album
+(id) albumWithAlbum:(struct album*)_album
{
    // Create an NSString with the album ID
    NSString* albumId = [NSString stringWithUTF8String:(const char*)_album->id];
    
    // Loop through the albums in the pool
    for(SpooftifyAlbum* album in albumPool)
    {
        // If one is found that matches the ID
        if([[album albumId] isEqualToString:albumId])
            return album;
    }
    
    // If none are found, create the album and return it
    SpooftifyAlbum* album = [[SpooftifyAlbum alloc] initWithAlbum:_album];
    return album;
}

// Create an album with a despotify album_browse
+(id) albumWithAlbumBrowse:(struct album_browse*)_album_browse
{
    // Create an NSString with the album ID
    NSString* albumId = [NSString stringWithUTF8String:(const char*)_album_browse->id];
    
    // Loop through the albums in the pool
    for(SpooftifyAlbum* album in albumPool)
    {
        // If one is found that matches the ID
        if([[album albumId] isEqualToString:albumId])
        {
            // If the album does not have browse information
            if(![album hasBrowseInformation])
                // Add the browse information
                [album addBrowseInformation:_album_browse];
            return album;
        }
    }
    
    // If none are found, create the album and return it
    SpooftifyAlbum* album = [[SpooftifyAlbum alloc] initWithAlbumBrowse:_album_browse];
    return album;
}

// Initialise with despotify album
-(id) initWithAlbum:(struct album*)album
{
    self = [super init];
    
    _album = *album;
    
    // Setup the albums variables from the despotify album
    name = [[NSString alloc] initWithUTF8String:_album.name];
    albumId = [[NSString alloc] initWithUTF8String:(const char*)_album.id];
    artistName = [[NSString alloc] initWithUTF8String:_album.artist];
    coverId = [[NSString alloc] initWithUTF8String:_album.cover_id];
    tracks = [[NSMutableArray alloc] init];
    
    // Add this album to the pool
    [albumPool addObject:self];
    
    return self;
}

// Initialise with despotify album_browse
-(id) initWithAlbumBrowse:(struct album_browse*)album_browse
{
    self = [super init];
    
    _album_browse = *album_browse;
    
    // Setup the albums variables from the despotify album_browse
    name = [[NSString alloc] initWithUTF8String:_album_browse.name];
    albumId = [[NSString alloc] initWithUTF8String:(const char*)_album_browse.id];
    artistName = [[NSString alloc] initWithUTF8String:_album_browse.tracks[0].artist->name];
    coverId = [[NSString alloc] initWithUTF8String:_album_browse.cover_id];
    tracks = [[NSMutableArray alloc] init];
    
    // Add the browse information for this album
    [self addBrowseInformation:album_browse];
    
    // Add the album to the pool
    [albumPool addObject:self];
    
    return self;
}

// Add browse information to the album
-(void) addBrowseInformation:(struct album_browse*)album_browse
{
    _album_browse = *album_browse;
    
    // Fill in the browse information
    year = _album_browse.year;
    
    // Loop through the tracks and create a SpooftifyTrack for each one
    struct track* track = _album_browse.tracks;
    while(track != NULL)
    {
        SpooftifyTrack* _track = [SpooftifyTrack trackWithTrack:track];
        [tracks addObject:_track];
        track = track->next;
    }
    
    // Tell the album we have browse information
    hasBrowseInformation = YES;
}

#pragma mark UIApplication Notification

// If the app is running low on memory
+(void) didReceiveMemoryWarning
{
    // Drain the pool
    [albumPool removeAllObjects];
}

@end
