//
//  ImageCache.h
//  YellowJacket
//
//  Created by Wayne Cochran on 7/26/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ImageCacheObject;

@interface ImageCache : NSObject {
    NSUInteger totalSize;  // total number of bytes
    NSUInteger maxSize;    // maximum capacity
}

@property (nonatomic, readonly) NSUInteger totalSize;

-(instancetype)initWithMaxSize:(NSUInteger) max NS_DESIGNATED_INITIALIZER;
-(void)insertImage:(UIImage*)image withSize:(NSUInteger)sz forKey:(NSString*)key;
-(UIImage*)imageForKey:(NSString*)key;

@end
 