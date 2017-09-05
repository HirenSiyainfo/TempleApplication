//
//  RapidCustomerLoyalty.h
//  RapidRMS
//
//  Created by siya-IOS5 on 8/21/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RapidCustomerLoyalty : NSObject

@property (nonatomic,strong) NSString *address1;
@property (nonatomic,strong) NSString *address2;
@property (nonatomic,strong) NSNumber *branchId;
@property (nonatomic,strong) NSString *city;
@property (nonatomic,strong) NSString *contactNo;
@property (nonatomic,strong) NSString *country;
@property (nonatomic,strong) NSString *custId;
@property (nonatomic,strong) NSString *dateOfBirth;
@property (nonatomic,strong) NSString *drivingLienceNo;
@property (nonatomic,strong) NSString *email;
@property (nonatomic,strong) NSString *firstName;
@property (nonatomic,strong) NSString *customerServerId;
@property (nonatomic,strong) NSString *lastName;
@property (nonatomic,strong) NSString *registrationDate;
@property (nonatomic,strong) NSString *shipAddress1;
@property (nonatomic,strong) NSString *shipAddress2;
@property (nonatomic,strong) NSString *shipCity;
@property (nonatomic,strong) NSString *shipCountry;
@property (nonatomic,strong) NSNumber *shipZipCode;
@property (nonatomic,strong) NSString *state;
@property (nonatomic,strong) NSString *shipState;
@property (nonatomic,retain) NSString *customerNo;

@property (nonatomic,strong) NSNumber *zipCode;
@property (nonatomic,strong) NSNumber *chkRedemption;
@property (nonatomic,strong) NSNumber *balanceAmount;
@property (nonatomic,strong) NSNumber *creditLimit;

@property (assign) BOOL isSameAsAddesss;

-(instancetype)init;
-(void)setupCustomerDetail:(NSDictionary *)customerDetailDictionary;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSMutableDictionary *customerDetailDictionary;
-(void)setCustomerId:(NSString *)customerId customerEmail:(NSString *)email;


@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *customerName;


@end
