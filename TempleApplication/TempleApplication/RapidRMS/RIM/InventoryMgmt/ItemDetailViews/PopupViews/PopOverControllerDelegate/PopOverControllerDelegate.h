//
//  popOverController.h
//  POSFrontEnd
//
//  Created by Minesh Purohit on 04/12/11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppropriatePriceLevelCell.h"

@protocol PriceInputDelegate <NSObject>

-(void)didEnter:(id)inputControl inputValue:(CGFloat)inputValue;
-(void)didCancel;

@end

@interface PopOverControllerDelegate : UIViewController 

@property (nonatomic, weak) id inputControl;
@property (nonatomic) BOOL isQty;
@property (nonatomic, weak) id<PriceInputDelegate> priceInputDelegate;

@end