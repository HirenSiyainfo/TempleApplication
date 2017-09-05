//
//  popOverController.h
//  POSFrontEnd
//
//  Created by Minesh Purohit on 04/12/11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppropriatePriceLevelCell.h"

@protocol WeightScaleDelegate <NSObject>

-(void)didEnterWeightScale:(id)inputControl inputValue:(CGFloat)inputValue unitType:(NSString *)unitType;
-(void)didCancelWeightScale;

@end

@interface WeightScalePopOverDelegate : UIViewController <UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, weak) id inputControl;
@property (nonatomic, weak) id<WeightScaleDelegate> weightScaleDelegate;

@end