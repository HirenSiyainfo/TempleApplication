//
//  WeightScaleUnit.h
//  RapidRMS
//
//  Created by Siya on 10/02/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface WeightScaleUnit : NSManagedObject

@property (nonatomic, retain) NSString * unitScale;
@property (nonatomic, retain) NSString * unitType;
@property (nonatomic, retain) NSString * weightScaleType;

@end
