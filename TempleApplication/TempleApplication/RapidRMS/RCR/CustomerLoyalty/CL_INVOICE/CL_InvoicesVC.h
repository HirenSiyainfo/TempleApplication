//
//  CL_InvoicesVC.h
//  RapidRMS
//
//  Created by Siya Infotech on 27/11/15.
//  Copyright © 2015 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RapidCustomerLoyalty.h"
@protocol InvoicesVCDelegate <NSObject>
@end

@interface CL_InvoicesVC : UIViewController

@property (nonatomic ,weak) id<InvoicesVCDelegate> invoicesVCDelegate;

-(void)updateInvoiceDataWith:(RapidCustomerLoyalty *)rapidCustomerloyaltyObject withInvoiceDetail:(NSMutableArray *)invoiceDetail withItemDetail:(NSMutableArray *)itemDetail strMonthDate:(NSString*)stringMonthdate;

@end
