//
//  SupplierRepresentative.h
//  RapidRMS
//
//  Created by Siya on 18/03/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SupplierCompany;

@interface SupplierRepresentative : NSManagedObject

@property (nonatomic, retain) NSNumber * srno;
@property (nonatomic, retain) NSNumber * brnSupplierId;
@property (nonatomic, retain) NSNumber * branchId;
@property (nonatomic, retain) NSNumber * companyName;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSString * position;
@property (nonatomic, retain) NSString * address1;
@property (nonatomic, retain) NSString * address2;
@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSString * state;
@property (nonatomic, retain) NSString * zipCode;
@property (nonatomic, retain) NSString * contactNo;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSNumber * createdBy;
@property (nonatomic, retain) NSDate * createdDate;
@property (nonatomic, retain) NSString * isDelete;
@property (nonatomic, retain) NSString * selectedPhoneNo;
@property (nonatomic, retain) NSNumber * companyId;
@property (nonatomic, retain) SupplierCompany *company;

@end
