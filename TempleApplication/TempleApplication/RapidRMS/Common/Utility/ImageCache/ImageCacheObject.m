//
//  ImageCacheObject.m
//  YellowJacket
//
//  Created by Wayne Cochran on 7/26/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ImageCacheObject.h"


@interface ImageCacheObject ()
@property (nonatomic) NSUInteger size;
@property (nonatomic, strong) NSDate *timeStamp;
@property (nonatomic, strong) UIImage *image;

@end

@implementation ImageCacheObject

//@synthesize size;
//@synthesize timeStamp;
//@synthesize image;

-(instancetype)initWithSize:(NSUInteger)sz Image:(UIImage*)anImage{
    if (self = [super init]) {
        self.size = sz;
        self.timeStamp = [NSDate date];
        self.image = anImage;
    }
    return self;
}

-(void)resetTimeStamp {
    self.timeStamp = [NSDate date];
//    [timeStamp release];
//    timeStamp = [[NSDate date] retain];
}

-(void) dealloc {
//    [timeStamp release];
//    [image release];
//    [super dealloc];
}

@end 
