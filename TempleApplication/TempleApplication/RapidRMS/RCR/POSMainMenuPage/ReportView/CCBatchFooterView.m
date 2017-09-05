//
//  CCBatchFooterView.m
//  RapidRMS
//
//  Created by siya-IOS5 on 7/7/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "CCBatchFooterView.h"
#import "NSString+Methods.h"
@implementation CCBatchFooterView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)updateCCBatchFooterViewWith:(CCBatchFooterStruct)ccBatchFooter
{
    lblTotalTransaction.text = [NSString stringWithFormat:@"%@",ccBatchFooter.totalTransction] ;
    
    NSString *totalAvgTicket = [NSString stringWithFormat:@"%@",ccBatchFooter.totalAvgTicket];
    lblTotalTicket.text = [totalAvgTicket applyCurrencyFormatter:totalAvgTicket.floatValue];
 
    NSString *totalTipAmount = [NSString stringWithFormat:@"%@",ccBatchFooter.totalTipAmount];
    lblTotalTips.text = [totalTipAmount applyCurrencyFormatter:totalTipAmount.floatValue];
    
    NSString *totalTransctionAmount = [NSString stringWithFormat:@"%@",ccBatchFooter.totalTransctionAmount];
    lblTotalTransactionAmount.text = [totalTransctionAmount applyCurrencyFormatter:totalTransctionAmount.floatValue];
    
    NSString *totalAmount = [NSString stringWithFormat:@"%@",ccBatchFooter.totalAmount];
    lblTotalAmount.text = [totalAmount applyCurrencyFormatter:totalAmount.floatValue];
}


@end
