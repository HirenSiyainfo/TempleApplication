//
//  LastInvoiceData.h
//  RapidRMS
//
//  Created by Siya on 10/02/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface LastInvoiceData : NSManagedObject

@property (nonatomic, retain) NSNumber * branchId;
@property (nonatomic, retain) NSNumber * changeDue;
@property (nonatomic, retain) NSNumber * collectAmount;
@property (nonatomic, retain) NSData * invoiceData;
@property (nonatomic, retain) NSDate * invoiceDate;
@property (nonatomic, retain) NSString * paymentType;
@property (nonatomic, retain) NSString * regInvoiceNo;
@property (nonatomic, retain) NSNumber * regiterid;
@property (nonatomic, retain) NSNumber * tenderAmount;
@property (nonatomic, retain) NSNumber * zId;

@end
