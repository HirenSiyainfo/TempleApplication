//
//  CL_InvoiceListVC.h
//  RapidRMS
//
//  Created by Siya Infotech on 02/12/15.
//  Copyright © 2015 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RapidCustomerLoyalty.h"
#import "CL_HouseChargeVC.h"

@interface CL_InvoiceListVC : UIViewController

-(void)updateInvoiceListViewWithRapidCustomerLoyaltyObject:(RapidCustomerLoyalty *)rapidCustomerLoyalty withInvoiceList:(NSMutableArray *)invoiceList;
-(void)searchInvoiceListData:(NSString*)invoiceListSearchString arrInvoicelListdata:(NSMutableArray *)invoicelListArray;
-(NSMutableArray *)invoiceListArray:(NSString*)invoiceListSearchString arrInvoicelListdata:(NSMutableArray *)invoicelListSearchArray;


@end
