//
//  DiscountMixMatchCellTableViewCell.h
//  RapidRMS
//
//  Created by Siya Infotech on 13/06/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WeightScaleSetupCell.h"

@interface VariationCustomCell : UITableViewCell
{
    UITextField *currentEditedTextField;
}

@property (nonatomic, weak) IBOutlet UILabel *productName;
@property (nonatomic, weak) IBOutlet UILabel *avgCost;

@property (nonatomic, weak) IBOutlet UITextField *costPrice;
@property (nonatomic, weak) IBOutlet UITextField *profit;

@property (nonatomic, weak) IBOutlet UIButton *unitPriceBtn;
@property (nonatomic, weak) IBOutlet UITextField *unitPrice;

@property (nonatomic, weak) IBOutlet UIButton *btnPriceLevel;

@property (nonatomic, weak) IBOutlet UIButton *aLevelBtn;
@property (nonatomic, weak) IBOutlet UITextField *priceLevelA;

@property (nonatomic, weak) IBOutlet UIButton *bLevelBtn;
@property (nonatomic, weak) IBOutlet UITextField *priceLevelB;

@property (nonatomic, weak) IBOutlet UIButton *cLevelBtn;
@property (nonatomic, weak) IBOutlet UITextField *priceLevelC;

@property (nonatomic, weak) IBOutlet UISwitch *allowPackageType;

@property (nonatomic, weak) NSString *applyPrice;
@property (nonatomic, weak) NSString *profit_type;

@property (nonatomic, weak) UIView *containerView;
@property (nonatomic, strong) NSMutableDictionary *pricingDictionary;

@property (nonatomic) BOOL isMargin;

@property (nonatomic ,weak) id<PriceChangeInfoPricingDelegate> PriceChangeInfoPricingDelegate;

-(void)refreshAppropriatePriceCell;
@end