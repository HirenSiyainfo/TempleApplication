//
//  RapidInvoicePrint.h
//  RapidRMS
//
//  Created by siya-IOS5 on 11/27/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RapidCustomerLoyalty.h"

@protocol RapidInvoicePrintDelegate <NSObject>
-(void)didFinishPrintProcessSuccessFully;
-(void)didFailPrintProcess;

@end

@interface RapidInvoicePrint : NSObject
-(instancetype)initWithPortName:(NSString *)portName portSetting:(NSString *)portSettings ItemDetail:(NSMutableArray *)itemDetail withPaymentDetail:(NSMutableArray *)paymentDetail withMasterDetails:(NSMutableArray *)masterDetail fromViewController:(UIViewController *)viewController withTipSetting:(NSNumber *)tipSettting tipsPercentArray:(NSMutableArray *)tipPercentageArray withChangeDue:(NSString *)changeDue withPumpCart:(NSMutableArray *)pumpCartDetail;
@property(assign) BOOL isVoidInvoice;
@property(nonatomic , strong) NSString *cashierName;
@property(nonatomic , strong) NSString *registerName;
@property(nonatomic , strong) NSMutableArray *rapidCustomerArray;

@property(assign) BOOL isInvoiceReceipt;
@property(assign) BOOL isFromCustomerLoyalty;

-(void)startPrint;

@property (nonatomic,weak) id<RapidInvoicePrintDelegate> rapidInvoicePrintDelegate;

@end
