//
//  AddPaymentMasterButtonCell.m
//  RapidRMS
//
//  Created by Siya Infotech on 26/09/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "AddPaymentMasterButtonCell.h"

@implementation AddPaymentMasterButtonCell

- (void)awakeFromNib
{
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

}
-(void)updatePaymentMasterButtonCell:(RapidPaymentMaster *)rapidPaymentmaster addPaymentField:(AddPaymentField)addPaymentField
{
    switch (addPaymentField) {
            
        case PaymentNameField:
            break;
        case PaymentCodeField:
            break;
            
        case PaymentTypeField:
            break;
            
        case SurchargeCheckBox:
            self.btnCheckBox.selected = rapidPaymentmaster.flgSurcharge;
            
            if (!rapidPaymentmaster.surchargeType)
            {
                rapidPaymentmaster.surchargeType = @"1";
            }
            break;
            
        case SurchargeDollorType:
            if ([rapidPaymentmaster.surchargeType isEqualToString:@"1"])
            {
                self.btnCheckBox.selected = YES;
            }
            else
            {
                self.btnCheckBox.selected = NO;
            }
            break;
            
        case SurchargePercentageType:
            if ([rapidPaymentmaster.surchargeType isEqualToString:@"0"])
            {
                self.btnCheckBox.selected = YES;
            }
            else
            {
                self.btnCheckBox.selected = NO;
            }
            break;
            
        case SurchargeAmount:
            break;
            
        case DropCheckBox:
            self.btnCheckBox.selected = rapidPaymentmaster.chkDropAmt.boolValue;
                        
            break;
            
        default:
            break;
    }
}

-(IBAction)btnCheckBoxClick:(id)sender
{
    self.btnCheckBox.selected = ! self.btnCheckBox.selected;
    [self.addPaymentMasterButtonCellDelegate addSurchargeAtIndexPath:self.currentCellIndexpath];
}

@end
