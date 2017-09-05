//
//  ImageCacheObject.h
//  YellowJacket
//
//  Created by Wayne Cochran on 7/26/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ImageCacheObject : NSObject {
//    NSUInteger size;    // size in bytes of image data
//    NSDate *timeStamp;  // time of last access
//    UIImage *image;     // cached image
}

@property (nonatomic, readonly) NSUInteger size;
@property (nonatomic, readonly) NSDate *timeStamp;
@property (nonatomic, readonly) UIImage *image;

-(instancetype)initWithSize:(NSUInteger)sz Image:(UIImage*)anImage NS_DESIGNATED_INITIALIZER;
-(void)resetTimeStamp;

@end
 