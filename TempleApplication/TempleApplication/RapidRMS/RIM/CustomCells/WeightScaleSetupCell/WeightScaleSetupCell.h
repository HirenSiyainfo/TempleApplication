//
//  DiscountMixMatchCellTableViewCell.h
//  RapidRMS
//
//  Created by Siya Infotech on 13/06/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ItemInfoVC.h"

@protocol PriceChangeInfoPricingDelegate <NSObject>
    -(void)didPriceChangeOf:(PricingSectionItem)PriceValueType inputValue:(NSNumber *)inputValue ValueIndex:(int)IndexNumber;
    -(void)didPriceChangeOfInputWeight:(NSNumber *)inputValue InputWeightUnit:(NSString *)weightUnit  ValueIndex:(int)IndexNumber;
    @property (NS_NONATOMIC_IOSONLY, readonly, strong) UITextField *currentEditingView;
    -(void)setCurrentEdintingViewWithTextField:(UITextField *)textField;
    -(BOOL)willChangeItemQtyOHat:(int)index;
    -(void)showMessageOfChangePriceTitle:(NSString *) messageTitle withMessage:(NSString *) message;
@end

@interface WeightScaleSetupCell : UITableViewCell <UIPopoverControllerDelegate>
{
    UITextField *currentEditedTextField;
}

@property (nonatomic, weak) IBOutlet UILabel *productName;
@property (nonatomic, weak) IBOutlet UILabel *avgCost;

@property (nonatomic, weak) IBOutlet UITextField *qty;
@property (nonatomic, weak) IBOutlet UITextField *costPrice;
@property (nonatomic, weak) IBOutlet UITextField *profit;

@property (nonatomic, weak) IBOutlet UIButton *unitPriceBtn;
@property (nonatomic, weak) IBOutlet UITextField *unitPrice;

@property (nonatomic, weak) IBOutlet UIButton *aLevelBtn;
@property (nonatomic, weak) IBOutlet UITextField *priceLevelA;

@property (nonatomic, weak) IBOutlet UIButton *bLevelBtn;
@property (nonatomic, weak) IBOutlet UITextField *priceLevelB;

@property (nonatomic, weak) IBOutlet UIButton *cLevelBtn;
@property (nonatomic, weak) IBOutlet UITextField *priceLevelC;

@property (nonatomic, weak) IBOutlet UISwitch *allowPackageType;

@property (nonatomic, weak) IBOutlet UITextField *unitQty;
@property (nonatomic, weak) IBOutlet UILabel *lblMeasurement;

@property (nonatomic, weak) UIView *containerView;

@property (nonatomic, weak) NSString *applyPrice;
@property (nonatomic, weak) NSString *profit_type;

@property (nonatomic, strong) NSMutableDictionary *weightDictionary;

@property (nonatomic) BOOL isMargin;

@property (nonatomic) NSIndexPath * cellIndex;
@property (nonatomic ,weak) id<PriceChangeInfoPricingDelegate> PriceChangeInfoPricingDelegate;

-(void)refreshWeightPriceCell;

@end
