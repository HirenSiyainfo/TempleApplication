//
//  ShiftDetail+Dictionary.m
//  RapidRMS
//
//  Created by siya-IOS5 on 3/12/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "ShiftDetail+Dictionary.h"

@implementation ShiftDetail (Dictionary)
-(void)updateShiftDetailDictionary :(NSDictionary *)shiftDetailDictionary
{
    self.serverShiftId =  @([[shiftDetailDictionary valueForKey:@"ServerShiftId"] integerValue]);
    self.localShiftId =  @(1);
    self.userId =  @([[shiftDetailDictionary valueForKey:@"UserId"] integerValue]);
    self.zId =  @([[shiftDetailDictionary valueForKey:@"ZId"] integerValue]);
    if ([[shiftDetailDictionary valueForKey:@"CashType"] isEqualToString:@"CashIn"])
    {
        self.isShiftOpen =  @(TRUE);
        self.shiftOpenAmount =  @([[shiftDetailDictionary valueForKey:@"CashAmt"] integerValue]);
        self.startDate =  [NSDate date];
    }
    else
    {
        self.isShiftOpen =  @(FALSE);
        self.shiftCloseAmount =  @([[shiftDetailDictionary valueForKey:@"CashAmt"] integerValue]);
        self.endDate =  [NSDate date];
    }
}
-(NSDictionary *)shiftDetailDictionary
{
    return nil;
}
@end
