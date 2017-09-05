//
//  SupplierMaster.h
//  RapidRMS
//
//  Created by Siya on 10/02/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface SupplierMaster : NSManagedObject

@property (nonatomic, retain) NSNumber * brnSupplierId;
@property (nonatomic, retain) NSString * companyName;
@property (nonatomic, retain) NSString * contactNo;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSString * selectedPhoneNo;

@end
