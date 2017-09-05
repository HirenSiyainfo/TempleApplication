//
//  ItemInfoPricingCell.h
//  RapidRMS
//
//  Created by Siya Infotech on 21/07/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
//
#import "ItemInfoVC.h"


@protocol PriceChangeDelegate <NSObject>
    -(void)didPriceChangeOf:(PricingSectionItem)PriceValueType inputValue:(NSNumber *)inputValue ValueIndex:(int)IndexNumber;
    -(void)didPriceChangeOfInputWeight:(NSNumber *)inputValue InputWeightUnit:(NSString *)weightUnit  ValueIndex:(int)IndexNumber;
    -(BOOL)willChangeItemQtyOHat:(int)index;
    -(void)showMessageOfChangePriceTitle:(NSString *) messageTitle withMessage:(NSString *) message;
    @property (NS_NONATOMIC_IOSONLY, readonly, strong) UITextField *currentEditingView;
    -(void)setCurrentEdintingViewWithTextField:(UITextField *)textField;
    -(int)willGetOfQtyValueForQtyOH:(int)IndexNumber;
@end

@interface ItemInfoPricingCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel * lblCellName;
@property (nonatomic, weak) IBOutlet UITextField * txtInputSingle;
@property (nonatomic, weak) IBOutlet UITextField * txtInputCase;
@property (nonatomic, weak) IBOutlet UITextField * txtInputPack;

@property (nonatomic, weak) IBOutlet UILabel * lblInputSingle;
@property (nonatomic, weak) IBOutlet UILabel * lblInputCase;
@property (nonatomic, weak) IBOutlet UILabel * lblInputPack;

@property (nonatomic, weak) IBOutlet UIImageView * imageBackGround;
@property (nonatomic, weak) IBOutlet UIImageView * imageMarginMarkUp;
@property (nonatomic, weak) UIView *containerView;

@property (nonatomic, weak) NSDictionary * priceInfo;
@property (nonatomic) PricingSectionItem cellType;
@property (nonatomic ,weak) id<PriceChangeDelegate> priceChangeDelegate;

@property (nonatomic, assign) BOOL cashPackQtyChaange;


@end
