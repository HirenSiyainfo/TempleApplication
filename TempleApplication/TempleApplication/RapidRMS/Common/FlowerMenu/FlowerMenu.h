//
//  FlowerMenu.h
//  FlowerMenuApp
//
//  Created by Siya Infotech on 05/06/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FlowerMenuView.h"

@class FlowerMenu;

@protocol FlowerMenuDelegate <NSObject>
- (void)flowerMenu:(FlowerMenu*)flowerMenu didSelectMenuItem:(NSInteger)index;
@end

@interface FlowerMenu : NSObject <FlowerMenuViewDelegate>

- (instancetype)initWithMenuView:(FlowerMenuView*)menuView NS_DESIGNATED_INITIALIZER;

- (void)setupMenuWithTitles:(NSArray*)titles delegate:(id<FlowerMenuDelegate>)delegate;
- (void)setupMenuWithTitles:(NSArray*)titles normalImages:(NSArray*)normalImages selectedImages:(NSArray*)selectedImages disabledImages:(NSArray*)disabledImages delegate:(id<FlowerMenuDelegate>)delegate;
- (void)enableMenuItem:(BOOL)enable atIndex:(NSInteger)index;

- (void)snapToPoint:(CGPoint)somePoint;
- (void)attachToPoint:(CGPoint)somePoint;
@end
