//
//  ItemPricingOptionCell.m
//  RapidRMS
//
//  Created by Siya9 on 25/04/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "ItemPricingOptionCell.h"

@implementation ItemPricingOptionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)configureCellWithType:(PricingOptionTypes)type {
    self.btnWeightScale.selected = FALSE;
    self.btnRetailPrice.selected = FALSE;
    self.btnVariations.selected = FALSE;
    self.btnVariationsAndRetailPrice.selected = FALSE;
    UIButton * btnSelected = (UIButton *)[self viewWithTag:type];
    if ([btnSelected isKindOfClass:[UIButton class]]) {
        btnSelected.selected = TRUE;
    }
}
-(IBAction)ChangePricingOption:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(willChangePriceOptionTypeTo:)]) {
        [self configureCellWithType:(PricingOptionTypes)sender.tag];
        [self.delegate willChangePriceOptionTypeTo:(PricingOptionTypes)sender.tag];
    }
}
@end
