//
//  CS_Invoice.h
//  RapidRMS
//
//  Created by Siya Infotech on 07/12/15.
//  Copyright © 2015 Siya Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CS_Invoice : NSObject
@property (nonatomic,strong) NSNumber *custId;
@property (nonatomic,strong) NSString *invoice;
@property (nonatomic,strong) NSString *invoiceDate;
@property (nonatomic,strong) NSString *contactNo;
@property (nonatomic,strong) NSString *email;
@property (nonatomic,strong) NSString *loyaltyNo;
@property (assign) CGFloat discount;
@property (nonatomic,strong) NSNumber *amount;
@property (assign) CGFloat totalTicket;
@property (nonatomic,strong) NSString *invoiceNo;
@property (nonatomic,strong) NSString *paymentType;
@property (nonatomic,strong) NSString *itemQty;
@property (nonatomic,strong) NSString *lastVisitDate;

@property (nonatomic,strong) NSArray *invoicePaymentDetail;
@property (nonatomic,strong) NSArray *invoiceMasterDetail;
@property (nonatomic,strong) NSArray *invoiceItemDetail;

@property (nonatomic,strong) NSString *changeDue;

@property (nonatomic,strong) NSString *htmlString;
@property (nonatomic,strong) NSArray *tags;



-(void)setupCustomerInvoiceDetail:(NSDictionary *)customerInvoiceDetailDictionary;

-(void)configureInvoiceDetail:(NSMutableArray *)invoiceDetailArray;


@end
