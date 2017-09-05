//
//  popOverController.h
//  POSFrontEnd
//
//  Created by Minesh Purohit on 04/12/11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppropriatePriceLevelCell.h"
#import "PopOverControllerDelegate.h"


@interface PercentagePopUpVC : UIViewController 

@property (nonatomic, weak) id<PriceInputDelegate> priceInputDelegate;

@property (nonatomic, weak) id inputControl;
@property (nonatomic) BOOL isQty;

@end