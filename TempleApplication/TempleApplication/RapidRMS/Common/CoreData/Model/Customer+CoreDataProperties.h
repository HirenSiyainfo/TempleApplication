//
//  Customer+CoreDataProperties.h
//  RapidRMS
//
//  Created by Siya Infotech on 16/08/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Customer.h"

NS_ASSUME_NONNULL_BEGIN

@interface Customer (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *address1;
@property (nullable, nonatomic, retain) NSString *address2;
@property (nullable, nonatomic, retain) NSNumber *branchId;
@property (nullable, nonatomic, retain) NSNumber *chkRedemption;
@property (nullable, nonatomic, retain) NSString *city;
@property (nullable, nonatomic, retain) NSString *contactNo;
@property (nullable, nonatomic, retain) NSString *country;
@property (nullable, nonatomic, retain) NSNumber *creditLimit;
@property (nullable, nonatomic, retain) NSNumber *custId;
@property (nullable, nonatomic, retain) NSString *dateOfBirth;
@property (nullable, nonatomic, retain) NSString *drivingLienceNo;
@property (nullable, nonatomic, retain) NSString *email;
@property (nullable, nonatomic, retain) NSString *firstName;
@property (nullable, nonatomic, retain) NSNumber *isDelete;
@property (nullable, nonatomic, retain) NSString *lastName;
@property (nullable, nonatomic, retain) NSString *qRCode;
@property (nullable, nonatomic, retain) NSString *registrationDate;
@property (nullable, nonatomic, retain) NSString *shipAddress1;
@property (nullable, nonatomic, retain) NSString *shipAddress2;
@property (nullable, nonatomic, retain) NSString *shipCity;
@property (nullable, nonatomic, retain) NSString *shipCountry;
@property (nullable, nonatomic, retain) NSNumber *shipZipCode;
@property (nullable, nonatomic, retain) NSString *state;
@property (nullable, nonatomic, retain) NSNumber *zipCode;

@end

NS_ASSUME_NONNULL_END
