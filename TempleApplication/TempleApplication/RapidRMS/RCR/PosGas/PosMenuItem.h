//
//  PosMenuItem.h
//  RapidRMS
//
//  Created by siya-IOS5 on 4/10/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PosMenuItem : NSObject

@property (nonatomic,strong) NSString * title;
@property (nonatomic,strong) NSString * selectedImage;
@property (nonatomic,strong) NSString * normalImage;

@property (assign) NSInteger  menuId;

- (instancetype)initWithTitle:(NSString*)title menuId:(NSInteger)posMenuId normalImages:(NSString *)normalImage selectedImages:(NSString *)selectedImage NS_DESIGNATED_INITIALIZER;

@end
