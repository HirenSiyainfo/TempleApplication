//
//  InvoiceDetail.h
//  POSRetail
//
//  Created by Keyur Patel on 04/07/13.
//  Copyright (c) 2013 Nirav Patel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CKCalendarView.h"
#import "InvoiceVoidPopupVC.h"
#import "RapidCustomerLoyalty.h"

@protocol InvoiceDetailDelegate<NSObject>
-(void)didAddItemFromInvoiceListWithInvoiceDetail:(NSMutableArray *)invoiceListArray;
-(void)didCancelInvoiceList;
-(void)creditCardVoidTransactionProcess;
-(void)voidTransactionProcessWithMultiplePayment;
@end

@interface InvoiceDetail : UIViewController<UpdateDelegate,NSFetchedResultsControllerDelegate,NSXMLParserDelegate,InvoiceVoidePopUpDelegate>
{

}

@property (nonatomic, weak) id<InvoiceDetailDelegate> invoiceDetailDelegate;
@property (nonatomic, strong)RapidCustomerLoyalty *rcrRapidCustomerLoayalty;

-(IBAction)btnNextClick:(id)sender;
-(IBAction)btnPreviousClick:(id)sender;
-(IBAction)btninvtypeClick:(id)sender;
-(IBAction)btnCancelClick:(id)sender;
-(IBAction)btnCalcenderClick:(id)sender;
-(IBAction)btnInvRcptClick:(UIButton *)sender;

@end
