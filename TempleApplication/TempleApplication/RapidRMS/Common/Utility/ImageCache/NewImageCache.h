//
//  NewImageCache.h
//  RapidRMS
//
//  Created by Paras Joshi on 15/06/17.
//  Copyright © 2017 Siya Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NewImageCache : NSObject

@property (nonatomic, retain) NSCache *imgCache;


#pragma mark - Methods

+ (NewImageCache*)sharedImageCache;
//- (void) AddImage:(NSString *)imageURL: (UIImage *)image;
- (void) AddImage:(NSString *)imageURL withImage:(UIImage *)image;
- (UIImage*) GetImage:(NSString *)imageURL;
- (BOOL) DoesExist:(NSString *)imageURL;
-(UIImage *)resizeImage:(UIImage *)image scaledToSize:(CGSize)newSize;

@end
