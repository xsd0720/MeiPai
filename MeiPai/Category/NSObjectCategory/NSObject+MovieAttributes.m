//
//  NSObject+MovieAttributes.m
//  ImitationWeChat
//
//  Created by xwmedia01 on 16/8/3.
//  Copyright © 2016年 wany. All rights reserved.
//

#import "NSObject+MovieAttributes.h"
#import <AVFoundation/AVFoundation.h>
@implementation NSObject (MovieAttributes)

+ (CGSize)getVideoSizeFromURL:(NSURL *)inputVideoURL
{
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:inputVideoURL options:nil];
    NSArray *assetVideoTracks = [asset tracksWithMediaType:AVMediaTypeVideo];
    if (assetVideoTracks.count <= 0)
    {
        NSLog(@"Video track is empty!");
        return CGSizeZero;
    }
    AVAssetTrack *videoAssetTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    
    // If this if from system camera, it will rotate 90c, and swap width and height
    CGSize sizeVideo = CGSizeMake(videoAssetTrack.naturalSize.width, videoAssetTrack.naturalSize.height);

    return sizeVideo;
}

@end
