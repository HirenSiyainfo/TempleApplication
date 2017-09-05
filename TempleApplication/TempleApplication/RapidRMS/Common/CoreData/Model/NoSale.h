//
//  NoSale.h
//  RapidRMS
//
//  Created by siya-IOS5 on 3/4/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface NoSale : NSManagedObject

@property (nonatomic, retain) NSString * branchId;
@property (nonatomic, retain) NSString * registerId;
@property (nonatomic, retain) NSString * zId;
@property (nonatomic, retain) NSString * userId;
@property (nonatomic, retain) NSDate * datetime;
@property (nonatomic, retain) NSString * noSaleType;
@property (nonatomic, retain) NSString * noSaleID;

@end
