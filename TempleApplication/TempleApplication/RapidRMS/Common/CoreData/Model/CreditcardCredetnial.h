//
//  CreditcardCredetnial.h
//  RapidRMS
//
//  Created by Siya on 10/02/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface CreditcardCredetnial : NSManagedObject

@property (nonatomic, retain) NSString * aCCOUNT_TOKEN;
@property (nonatomic, retain) NSString * aPI_KEY;
@property (nonatomic, retain) NSString * branchId;
@property (nonatomic, retain) NSString * cardInfoId;
@property (nonatomic, retain) NSString * createdDate;
@property (nonatomic, retain) NSString * gateway;
@property (nonatomic, retain) NSNumber * isActive;
@property (nonatomic, retain) NSNumber * isManualProcess;
@property (nonatomic, retain) NSNumber * merchantId;
@property (nonatomic, retain) NSString * password;
@property (nonatomic, retain) NSString * paymentMode;
@property (nonatomic, retain) NSString * uRL;
@property (nonatomic, retain) NSString * username;

@end
