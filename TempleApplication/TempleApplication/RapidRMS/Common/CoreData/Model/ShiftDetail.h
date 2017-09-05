//
//  ShiftDetail.h
//  RapidRMS
//
//  Created by siya-IOS5 on 3/12/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ShiftDetail : NSManagedObject

@property (nonatomic, retain) NSNumber * userId;
@property (nonatomic, retain) NSNumber * zId;
@property (nonatomic, retain) NSDate * startDate;
@property (nonatomic, retain) NSDate * endDate;
@property (nonatomic, retain) NSNumber * isShiftOpen;
@property (nonatomic, retain) NSNumber * serverShiftId;
@property (nonatomic, retain) NSNumber * localShiftId;
@property (nonatomic, retain) NSNumber * shiftOpenAmount;
@property (nonatomic, retain) NSNumber * shiftCloseAmount;

@end
