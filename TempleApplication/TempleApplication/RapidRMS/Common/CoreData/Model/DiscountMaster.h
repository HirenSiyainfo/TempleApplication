//
//  DiscountMaster.h
//  RapidRMS
//
//  Created by siya-IOS5 on 5/29/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface DiscountMaster : NSManagedObject

@property (nonatomic, retain) NSNumber * discountId;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSNumber * amount;
@property (nonatomic, retain) NSNumber * salesDiscount;
@property (nonatomic, retain) NSDate * createdDate;
@property (nonatomic, retain) NSNumber * isDelete;
@property (nonatomic, retain) NSNumber * branchId;
@property (nonatomic, retain) NSNumber * createdBy;

@end
