//
//  TaxMaster.h
//  RapidRMS
//
//  Created by Siya on 10/02/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface TaxMaster : NSManagedObject

@property (nonatomic, retain) NSDecimalNumber * amount;
@property (nonatomic, retain) NSDecimalNumber * percentage;
@property (nonatomic, retain) NSNumber * taxId;
@property (nonatomic, retain) NSString * taxNAME;
@property (nonatomic, retain) NSString * type;

@end
