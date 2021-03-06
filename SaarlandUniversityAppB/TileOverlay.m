//
//  TileOverlay.m
//  SaarlandUniversityApp
//
//  Created by Tom Michels on 16.05.12.
//  Copyright (c) 2012 Universität des Saarlandes. All rights reserved.
//

#import "TileOverlay.h"

#define TILE_SIZE 256.0

@interface ImageTile (FileInternal)
- (id)initWithFrame:(MKMapRect)f path:(NSString *)p;
@end

@implementation ImageTile

@synthesize frame, imagePath;

- (id)initWithFrame:(MKMapRect)f path:(NSString *)p
{
    if (self = [super init]) {
        imagePath = p;
        frame = f;
    }
    return self;
}



@end

// Convert an MKZoomScale to a zoom level where level 0 contains 4 256px square tiles,
// which is the convention used by gdal2tiles.py.
static NSInteger zoomScaleToZoomLevel(MKZoomScale scale) {
    double numTilesAt1_0 = MKMapSizeWorld.width / TILE_SIZE;
    NSInteger zoomLevelAt1_0 = log2(numTilesAt1_0);  // add 1 because the convention skips a virtual level with 1 tile.
    NSInteger zoomLevel = MAX(0, zoomLevelAt1_0 + floor(log2f(scale) + 0.5));
    return zoomLevel;
}

@implementation TileOverlay

- (id)initWithTileDirectory:(NSString *)tileDirectory
{
    if (self = [super init]) {
        tileBase = tileDirectory ;
        // scan tilePath to determine what files are available
        NSFileManager *fileman = [NSFileManager defaultManager];
        NSDirectoryEnumerator *e = [fileman enumeratorAtPath:tileDirectory];
        NSString *path = nil;
        NSMutableSet *pathSet = [[NSMutableSet alloc] init];
        NSInteger minZ = INT_MAX;
        while (path = [e nextObject]) {
            if (NSOrderedSame == [[path pathExtension] caseInsensitiveCompare:@"png"]) {
                NSArray *components = [[path stringByDeletingPathExtension] pathComponents];
                if ([components count] == 3) {
                    NSInteger z = [[components objectAtIndex:0] integerValue];
                    NSInteger x = [[components objectAtIndex:1] integerValue];
                    NSInteger y = [[components objectAtIndex:2] integerValue];
                    
                    NSString *tileKey = [[NSString alloc] initWithFormat:@"%d/%d/%d", z, x, y];
                    
                    [pathSet addObject:tileKey];

                    
                    if (z < minZ)
                        minZ = z;
                }
            }
        }
        
        if ([pathSet count] == 0) {
            NSLog(@"Could not locate any tiles at %@", tileDirectory);

            return nil;
        }
        
        // find bounds of base level of tiles to determine boundingMapRect
        
        NSInteger minX = INT_MAX;
        NSInteger minY = INT_MAX;
        NSInteger maxX = 0;
        NSInteger maxY = 0;
        for (NSString *tileKey in pathSet) {
            NSArray *components = [tileKey pathComponents];
            NSInteger z = [[components objectAtIndex:0] integerValue];
            NSInteger x = [[components objectAtIndex:1] integerValue];
            NSInteger y = [[components objectAtIndex:2] integerValue];
            if (z == minZ) {
                minX = MIN(minX, x);
                minY = MIN(minY, y);
                maxX = MAX(maxX, x);
                maxY = MAX(maxY, y);
            }            
        }
        
        NSInteger tilesAtZ = pow(2, minZ);
        double sizeAtZ = tilesAtZ * TILE_SIZE;
        double zoomScaleAtMinZ = sizeAtZ / MKMapSizeWorld.width;
        
        // gdal2tiles convention is that the 0th tile in the y direction
        // is at the bottom. MKMapPoint convention is that the 0th point
        // is in the upper left.  So need to flip y to correctly address
        // the tile path.
        NSInteger flippedMinY = abs(minY + 1 - tilesAtZ);
        NSInteger flippedMaxY = abs(maxY + 1 - tilesAtZ);
        
        double x0 = (minX * TILE_SIZE) / zoomScaleAtMinZ;
        double x1 = ((maxX+1) * TILE_SIZE) / zoomScaleAtMinZ;
        double y0 = (flippedMaxY * TILE_SIZE) / zoomScaleAtMinZ;
        double y1 = ((flippedMinY+1) * TILE_SIZE) / zoomScaleAtMinZ;
        
        boundingMapRect = MKMapRectMake(x0, y0, x1 - x0, y1 - y0);
        
        tilePaths = pathSet;
    }
    return self;
}

- (CLLocationCoordinate2D)coordinate
{
    return MKCoordinateForMapPoint(MKMapPointMake(MKMapRectGetMidX(boundingMapRect),
                                                  MKMapRectGetMidY(boundingMapRect)));
}

- (MKMapRect)boundingMapRect
{
    return boundingMapRect;
}


- (NSArray *)tilesInMapRect:(MKMapRect)rect zoomScale:(MKZoomScale)scale
{
    NSInteger z = zoomScaleToZoomLevel(scale);
    
    // Number of tiles wide or high (but not wide * high)
    NSInteger tilesAtZ = pow(2, z);
    
    NSInteger minX = floor((MKMapRectGetMinX(rect) * scale) / TILE_SIZE);
    NSInteger maxX = floor((MKMapRectGetMaxX(rect) * scale) / TILE_SIZE);
    NSInteger minY = floor((MKMapRectGetMinY(rect) * scale) / TILE_SIZE);
    NSInteger maxY = floor((MKMapRectGetMaxY(rect) * scale) / TILE_SIZE);
    
    NSMutableArray *tiles = nil;
    
    for (NSInteger x = minX; x <= maxX; x++) {
        for (NSInteger y = minY; y <= maxY; y++) {
            // As in initWithTilePath, need to flip y index to match the gdal2tiles.py convention.
            NSInteger flippedY = abs(y + 1 - tilesAtZ);
            
            NSString *tileKey = [[NSString alloc] initWithFormat:@"%d/%d/%d", z, x, flippedY];
            
            if ([tilePaths containsObject:tileKey]) {
                if (!tiles) {
                    tiles = [NSMutableArray array];
                }
                
                MKMapRect frame = MKMapRectMake((double)(x * TILE_SIZE) / scale,
                                                (double)(y * TILE_SIZE) / scale,
                                                TILE_SIZE / scale,
                                                TILE_SIZE / scale);
                
                NSString *path = [[NSString alloc] initWithFormat:@"%@/%@.png", tileBase, tileKey];
                ImageTile *tile = [[ImageTile alloc] initWithFrame:frame path:path];

                [tiles addObject:tile];

            }
        }
    }
    
    return tiles;
}

@end
