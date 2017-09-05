//
//  UnitConversion.h
//  RapidRMS
//
//  Created by Siya on 10/02/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface UnitConversion : NSManagedObject

@property (nonatomic, retain) NSNumber * factor;
@property (nonatomic, retain) NSString * fromUnitType;
@property (nonatomic, retain) NSString * toUnitType;

@end
