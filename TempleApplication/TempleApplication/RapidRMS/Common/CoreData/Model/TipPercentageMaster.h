//
//  TipPercentageMaster.h
//  RapidRMS
//
//  Created by Siya on 10/02/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface TipPercentageMaster : NSManagedObject

@property (nonatomic, retain) NSNumber * branchId;
@property (nonatomic, retain) NSNumber * brnTipPercentageId;
@property (nonatomic, retain) NSNumber * createdBy;
@property (nonatomic, retain) NSNumber * isDelete;
@property (nonatomic, retain) NSNumber * tipPercentage;

@end
