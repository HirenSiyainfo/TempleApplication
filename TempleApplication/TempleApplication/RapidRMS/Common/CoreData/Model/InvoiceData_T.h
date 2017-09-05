//
//  InvoiceData_T.h
//  RapidRMS
//
//  Created by siya-IOS5 on 3/15/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface InvoiceData_T : NSManagedObject

@property (nonatomic, retain) NSNumber * branchId;
@property (nonatomic, retain) NSDate * invoiceDate;
@property (nonatomic, retain) NSData * invoiceItemData;
@property (nonatomic, retain) NSData * invoiceMstData;
@property (nonatomic, retain) NSNumber * invoiceNo;
@property (nonatomic, retain) NSData * invoicePaymentData;
@property (nonatomic, retain) NSNumber * isUpload;
@property (nonatomic, retain) NSNumber * localShiftId;
@property (nonatomic, retain) NSString * message;
@property (nonatomic, retain) NSNumber * msgCode;
@property (nonatomic, retain) NSString * regInvoiceNo;
@property (nonatomic, retain) NSNumber * regiterid;
@property (nonatomic, retain) NSNumber * serverShiftId;
@property (nonatomic, retain) NSNumber * userId;
@property (nonatomic, retain) NSNumber * zId;

@end
