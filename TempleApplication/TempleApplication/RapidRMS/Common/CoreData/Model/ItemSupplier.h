//
//  ItemSupplier.h
//  RapidRMS
//
//  Created by Siya Infotech on 13/04/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ItemSupplier : NSManagedObject

@property (nonatomic, retain) NSNumber * itemCode;
@property (nonatomic, retain) NSNumber * supId;
@property (nonatomic, retain) NSNumber * vendorId;

@end
