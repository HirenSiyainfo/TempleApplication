//
//  CCBatchFooterView.h
//  RapidRMS
//
//  Created by siya-IOS5 on 7/7/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XCCbatchReportVC.h"

@interface CCBatchFooterView : UIView
{
    IBOutlet UILabel *lblTotalTransaction;
    IBOutlet UILabel *lblTotalTicket;
    IBOutlet UILabel *lblTotalTips;
    IBOutlet UILabel *lblTotalTransactionAmount;
    IBOutlet UILabel *lblTotalAmount;
    
}

-(void)updateCCBatchFooterViewWith:(CCBatchFooterStruct)ccBatchFooter;

@end
