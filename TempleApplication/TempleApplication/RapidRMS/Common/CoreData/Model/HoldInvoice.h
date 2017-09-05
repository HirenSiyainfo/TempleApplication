//
//  HoldInvoice.h
//  RapidRMS
//
//  Created by siya-IOS5 on 3/2/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface HoldInvoice : NSManagedObject

@property (nonatomic, retain) NSDate * holdDate;
@property (nonatomic, retain) NSString * holdRemark;
@property (nonatomic, retain) NSString * holdUserName;
@property (nonatomic, retain) NSNumber * transActionNo;
@property (nonatomic, retain) NSNumber * billAmount;
@property (nonatomic, retain) NSData * holdData;

@end
