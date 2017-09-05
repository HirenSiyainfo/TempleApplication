//
//  ShiftHistoryCell.m
//  RapidRMS
//
//  Created by siya-IOS5 on 6/13/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "ShiftHistoryCell.h"

@implementation ShiftHistoryCell

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)updateWithShiftDetailDict :(NSMutableDictionary *)shiftDict
{
   self.lblRegisterName.text = [shiftDict valueForKey:@"RegisterName"];
    self.lblDate.text = [shiftDict valueForKey:@"ClsDate"];
    self.lblSales.text = [NSString stringWithFormat:@"%.2f",[[shiftDict valueForKey:@"Sales"] floatValue]];
    self.lblTax.text = [NSString stringWithFormat:@"%.2f",[[shiftDict valueForKey:@"Taxes"] floatValue]];
    self.lblTotalSales.text = [NSString stringWithFormat:@"%.2f",[[shiftDict valueForKey:@"TotalSales"] floatValue]];
    self.lblShiftCount.text = [shiftDict valueForKey:@""];
}
@end
