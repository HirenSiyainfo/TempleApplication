//
//  ItemPricingOptionCell.h
//  RapidRMS
//
//  Created by Siya9 on 25/04/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, PricingOptionTypes)
{
    PricingOptionTypesWeightScale = 2,
    PricingOptionTypesAppropreate,
    PricingOptionTypesVariations,
    PricingOptionTypesVariations_Appropreate,
};

@protocol PriceOptionTypeCellDelegate <NSObject>
-(void)willChangePriceOptionTypeTo:(PricingOptionTypes)newType;
@end


@interface ItemPricingOptionCell : UITableViewCell

@property (nonatomic, weak) id<PriceOptionTypeCellDelegate> delegate;
@property (nonatomic, weak) IBOutlet UIButton * btnWeightScale;
@property (nonatomic, weak) IBOutlet UIButton * btnRetailPrice;
@property (nonatomic, weak) IBOutlet UIButton * btnVariations;
@property (nonatomic, weak) IBOutlet UIButton * btnVariationsAndRetailPrice;

-(void)configureCellWithType:(PricingOptionTypes)type;
@end
