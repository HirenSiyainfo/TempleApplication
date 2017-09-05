//
//  FlowerMenu.m
//  FlowerMenuApp
//
//  Created by Siya Infotech on 05/06/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "FlowerMenu.h"

@interface FlowerMenu ()
@property (nonatomic, weak) FlowerMenuView *menuView;
@property (nonatomic, weak) id<FlowerMenuDelegate> menuDelegate;
@end

@implementation FlowerMenu
- (instancetype)initWithMenuView:(FlowerMenuView*)menuView {
    self = [super init];

    if (self) {
        self.menuView = menuView;
    }

    return self;
}

- (void)setupMenuWithTitles:(NSArray*)titles delegate:(id<FlowerMenuDelegate>)delegate {
    self.menuDelegate = delegate;
    [self.menuView setupMenuWithTitles:titles delegate:self];
}

- (void)setupMenuWithTitles:(NSArray*)titles normalImages:(NSArray*)normalImages selectedImages:(NSArray*)selectedImages disabledImages:(NSArray*)disabledImages delegate:(id<FlowerMenuDelegate>)delegate {
    self.menuDelegate = delegate;
    [self.menuView setupMenuWithTitles:titles normalImages:normalImages selectedImages:selectedImages disabledImages:disabledImages delegate:self];
}

- (void)enableMenuItem:(BOOL)enable atIndex:(NSInteger)index {
    [self.menuView enableMenuItem:enable atIndex:index];
}

- (void)didSelectMenuItem:(NSInteger)index {
    [self.menuDelegate flowerMenu:self didSelectMenuItem:index];
}

- (void)snapToPoint:(CGPoint)somePoint {
    [self.menuView snapToPoint:somePoint];
}

- (void)attachToPoint:(CGPoint)somePoint {
    [self.menuView attachToPoint:somePoint];
}

@end
