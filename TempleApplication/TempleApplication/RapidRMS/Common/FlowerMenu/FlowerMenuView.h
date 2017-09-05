//
//  FlowerMenuView.h
//  FlowerMenuApp
//
//  Created by Siya Infotech on 04/06/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FlowerMenuViewDelegate <NSObject>
//- (NSInteger)numberOfMenuItems;
//- (NSString*)normalImageForMenuIndex:(NSInteger)index;
//- (NSString*)selectedImageForMenuIndex:(NSInteger)index;
//- (NSString*)disabledImageForMenuIndex:(NSInteger)index;
//- (NSString*)titleForMenuIndex:(NSInteger)index;
//- (BOOL)isMenuItemEnabled:(NSInteger)index;
- (void)didSelectMenuItem:(NSInteger)index;
@end


@interface FlowerMenuView : UIView
@property (assign) CGFloat quadrantOffset;
@property (assign) CGFloat totalAngle;
@property (assign) CGFloat bloomFactor;


- (void)setupMenuWithTitles:(NSArray*)titles delegate:(id<FlowerMenuViewDelegate>)delegate;
- (void)setupMenuWithTitles:(NSArray*)titles normalImages:(NSArray*)normalImages selectedImages:(NSArray*)selectedImages disabledImages:(NSArray*)disabledImages delegate:(id<FlowerMenuViewDelegate>)delegate;
- (void)enableMenuItem:(BOOL)enable atIndex:(NSInteger)index;

- (void)snapToPoint:(CGPoint)somePoint;
- (void)attachToPoint:(CGPoint)somePoint;
@end
