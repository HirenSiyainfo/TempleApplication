	//
//  ItemPricingVC.h
//  RapidRMS
//
//  Created by Siya Infotech on 20/07/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ItemInfoVC.h"
#import "ItemInfoDataObject.h"
typedef NS_ENUM(NSInteger, PricingTab)
{
    PricingPriceAtPos,
    PricingOption,
    PricingWeightScale,
    PricingAppropreate,
    PricingVariations,
    PricingVariations_Appropreate,
    PricingVariation_1,
    PricingVariation_2,
    PricingVariation_3,
};

typedef NS_ENUM(NSInteger, PricingTabRows)
{
    PricingPriceAtPosRows,
    PricingOptionRows,
    PricingWeightScaleRows,
    PricingAppropreateRows,
    PricingVariationRows,
    PricingVariationAppropreateRows,
};
@protocol PriceChangeItemPricingAndCalculationDelegate <NSObject>
    -(void)didPriceChangeOf:(PricingSectionItem)PriceValueType inputValue:(NSNumber *)inputValue ValueIndex:(int)IndexNumber;
@end

@interface ItemPricingVC : UIViewController

@property (nonatomic, weak) id<PriceChangeAndCalculationDelegate> priceChangeAndCalculationDelegate;
@property (nonatomic, weak) IBOutlet UITableView *tblItemPricing;
@property (nonatomic, strong) ItemInfoDataObject * itemInfoDataObject;

@property (nonatomic) NSInteger selectedPricingOption;

@end
