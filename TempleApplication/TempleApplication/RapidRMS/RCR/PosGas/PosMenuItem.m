//
//  PosMenuItem.m
//  RapidRMS
//
//  Created by siya-IOS5 on 4/10/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "PosMenuItem.h"

@implementation PosMenuItem

- (instancetype)initWithTitle:(NSString*)title menuId:(NSInteger)posMenuId normalImages:(NSString *)normalImage selectedImages:(NSString *)selectedImage
{
    self = [super init];
    if (self)
    {
        self.menuId = posMenuId;
        self.title = title;
        self.normalImage = normalImage;
        self.selectedImage = selectedImage;
    }
    return self;
}







@end
