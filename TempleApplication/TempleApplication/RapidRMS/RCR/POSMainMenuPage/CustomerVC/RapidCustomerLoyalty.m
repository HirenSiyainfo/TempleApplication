//
//  RapidCustomerLoyalty.m
//  RapidRMS
//
//  Created by siya-IOS5 on 8/21/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "RapidCustomerLoyalty.h"
#import "NSString+Methods.h"
#import "RmsDbController.h"

@interface RapidCustomerLoyalty ()<NSCoding>
@property (nonatomic,strong) RmsDbController *rmsDbController;

@end

@implementation RapidCustomerLoyalty


-(instancetype)init
{
    self = [super init];

    if (self) {
        self.rmsDbController = [RmsDbController sharedRmsDbController];
        [self resetRapidCustomerLoyalty];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.address1 forKey:@"address1"];
    [aCoder encodeObject:self.address2 forKey:@"address2"];
    [aCoder encodeObject:self.branchId forKey:@"branchId"];
    [aCoder encodeObject:self.city forKey:@"city"];
    [aCoder encodeObject:self.contactNo forKey:@"contactNo"];
    [aCoder encodeObject:self.country forKey:@"country"];
    [aCoder encodeObject:self.custId forKey:@"custId"];
    [aCoder encodeObject:self.dateOfBirth forKey:@"dateOfBirth"];
    [aCoder encodeObject:self.drivingLienceNo forKey:@"drivingLienceNo"];
    [aCoder encodeObject:self.email forKey:@"email"];
    [aCoder encodeObject:self.firstName forKey:@"firstName"];
    [aCoder encodeObject:self.customerServerId forKey:@"customerServerId"];
    [aCoder encodeObject:self.lastName forKey:@"lastName"];
    [aCoder encodeObject:self.registrationDate forKey:@"registrationDate"];
    [aCoder encodeObject:self.shipAddress1 forKey:@"shipAddress1"];
    [aCoder encodeObject:self.shipAddress2 forKey:@"shipAddress2"];
    [aCoder encodeObject:self.shipCity forKey:@"shipCity"];
    [aCoder encodeObject:self.shipCountry forKey:@"shipCountry"];
    [aCoder encodeObject:self.shipZipCode forKey:@"shipZipCode"];
    [aCoder encodeObject:self.state forKey:@"state"];
    [aCoder encodeObject:self.zipCode forKey:@"zipCode"];
    [aCoder encodeObject:self.chkRedemption forKey:@"chkRedemption"];
    [aCoder encodeObject:self.shipState forKey:@"shipState"];
    [aCoder encodeObject:self.customerNo forKey:@"customerNo"];
    [aCoder encodeObject:self.creditLimit forKey:@"creditLimit"];

    [aCoder encodeBool:self.isSameAsAddesss forKey:@"isSameAsAddesss"];

}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.address1 = [aDecoder decodeObjectForKey:@"address1"];
        self.address2 = [aDecoder decodeObjectForKey:@"address2"];
        self.branchId = [aDecoder decodeObjectForKey:@"branchId"];
        self.city = [aDecoder decodeObjectForKey:@"city"];
        self.contactNo = [aDecoder decodeObjectForKey:@"contactNo"];
        self.country = [aDecoder decodeObjectForKey:@"country"];
        self.custId = [aDecoder decodeObjectForKey:@"custId"];
        self.dateOfBirth = [aDecoder decodeObjectForKey:@"dateOfBirth"];
        self.drivingLienceNo = [aDecoder decodeObjectForKey:@"drivingLienceNo"];
        self.email = [aDecoder decodeObjectForKey:@"email"];
        self.firstName = [aDecoder decodeObjectForKey:@"firstName"];
        self.customerServerId = [aDecoder decodeObjectForKey:@"customerServerId"];
        self.lastName = [aDecoder decodeObjectForKey:@"lastName"];
        self.registrationDate = [aDecoder decodeObjectForKey:@"registrationDate"];
        self.shipAddress1 = [aDecoder decodeObjectForKey:@"shipAddress1"];
        self.shipAddress2 = [aDecoder decodeObjectForKey:@"shipAddress2"];
        self.shipCity = [aDecoder decodeObjectForKey:@"shipCity"];
        self.shipCountry = [aDecoder decodeObjectForKey:@"shipCountry"];
        self.shipZipCode = [aDecoder decodeObjectForKey:@"shipZipCode"];
        self.state = [aDecoder decodeObjectForKey:@"state"];
        self.zipCode = [aDecoder decodeObjectForKey:@"zipCode"];
        self.chkRedemption = [aDecoder decodeObjectForKey:@"chkRedemption"];
        self.shipState = [aDecoder decodeObjectForKey:@"shipState"];
        self.customerNo = [aDecoder decodeObjectForKey:@"customerNo"];
        self.creditLimit = [aDecoder decodeObjectForKey:@"creditLimit"];

        self.isSameAsAddesss = [aDecoder decodeBoolForKey:@"isSameAsAddesss"];
    }
    return self;
}



-(void)resetRapidCustomerLoyalty
{
    self.address1 = @"";
    self.address2 = @"";
    self.branchId = 0;
    self.city = @"";
    self.contactNo = @"";
    self.country = @"";
    self.custId = @"";
    self.dateOfBirth = @"";
    self.drivingLienceNo = @"";
    self.email = @"";
    self.firstName = @"";
    self.customerServerId = @"";
    self.lastName = @"";
    self.registrationDate = @"";
    self.shipAddress1 = @"";
    self.shipAddress2 = @"";
    self.shipCity = @"";
    self.shipCountry = @"";
    self.shipZipCode = @(0);
    self.state = @"";
    self.zipCode = @(0);
    self.chkRedemption = 0;
    self.shipState = @"";
    self.customerNo = @"";
    self.creditLimit =@(0);

}
-(void)setCustomerId:(NSString *)customerId customerEmail:(NSString *)email
{
    self.custId = customerId;
    self.email = email;
}
-(void)setupCustomerDetail:(NSDictionary *)customerDetailDictionary
{
    
    self.address1 = [NSString stringWithFormat:@"%@",[customerDetailDictionary valueForKey:@"Address1"]];
    self.address2 = [NSString stringWithFormat:@"%@",[customerDetailDictionary valueForKey:@"Address2"]];
    self.branchId = @([[customerDetailDictionary valueForKey:@"BranchId"] integerValue]);
    self.city = [NSString stringWithFormat:@"%@",[customerDetailDictionary valueForKey:@"City"]];
    self.contactNo = [NSString stringWithFormat:@"%@",[customerDetailDictionary valueForKey:@"ContactNo"]];
    self.country = [NSString stringWithFormat:@"%@",[customerDetailDictionary valueForKey:@"Country"]];
    self.custId = [NSString stringWithFormat:@"%@",[customerDetailDictionary valueForKey:@"CustId"]];
    self.dateOfBirth = [NSString stringWithFormat:@"%@",[customerDetailDictionary valueForKey:@"DateOfBirth"]];
    self.drivingLienceNo = [NSString stringWithFormat:@"%@",[customerDetailDictionary valueForKey:@"DrivingLienceNo"]];
    self.email = [NSString stringWithFormat:@"%@",[customerDetailDictionary valueForKey:@"Email"]];
    self.firstName = [NSString stringWithFormat:@"%@",[customerDetailDictionary valueForKey:@"FirstName"]];
    self.customerServerId = [NSString stringWithFormat:@"%@",[customerDetailDictionary valueForKey:@"Id"]];
    self.lastName = [NSString stringWithFormat:@"%@",[customerDetailDictionary valueForKey:@"LastName"]];
    self.registrationDate = [NSString stringWithFormat:@"%@",[customerDetailDictionary valueForKey:@"RegistrationDate"]];
    self.shipAddress1 = [NSString stringWithFormat:@"%@",[customerDetailDictionary valueForKey:@"ShipAddress1"]];
    self.shipAddress2 = [NSString stringWithFormat:@"%@",[customerDetailDictionary valueForKey:@"ShipAddress2"]];
    self.shipCity = [NSString stringWithFormat:@"%@",[customerDetailDictionary valueForKey:@"ShipCity"]];
    self.shipCountry = [NSString stringWithFormat:@"%@",[customerDetailDictionary valueForKey:@"ShipCountry"]];
    self.shipZipCode = @([[customerDetailDictionary valueForKey:@"ShipZipCode"] integerValue]);
    self.state = [NSString stringWithFormat:@"%@",[customerDetailDictionary valueForKey:@"State"]];
    self.zipCode = @([[customerDetailDictionary valueForKey:@"ZipCode"] integerValue]);
    self.chkRedemption = @([[customerDetailDictionary valueForKey:@"chkRedemption"] boolValue]);
    self.customerNo = [NSString stringWithFormat:@"%@",[customerDetailDictionary valueForKey:@"CustomerNo"]];
    self.creditLimit = @([[customerDetailDictionary valueForKey:@"CreditLimit"] floatValue]);

}

-(NSString *)customerName
{
    NSString *customerName = @"";
    if (self.firstName.blank == FALSE || self.lastName.blank == FALSE) {
        
        customerName = self.firstName.trimeString;
        customerName = [customerName stringByAppendingString:self.lastName.trimeString];
    }
    else if (self.email.blank == FALSE)
    {
        customerName = self.email;
    }
    else if(self.contactNo.blank == FALSE)
    {
        customerName = self.contactNo;
    }
    return customerName;
}

- (NSMutableDictionary *)customerDetailDictionary
{
    
    NSMutableDictionary *customerDetailDictionary = [[NSMutableDictionary alloc]init];
    [customerDetailDictionary setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
    
    if (self.custId.integerValue > 0)
    {
        customerDetailDictionary[@"CustId"] = self.custId;
    }
    
    [customerDetailDictionary setValue:self.firstName forKey:@"FirstName"];
    [customerDetailDictionary setValue:self.lastName forKey:@"LastName"];
    [customerDetailDictionary setValue:self.address1 forKey:@"Address1"];
    [customerDetailDictionary setValue:self.address2 forKey:@"Address2"];
    [customerDetailDictionary setValue:self.zipCode forKey:@"ZipCode"];
    [customerDetailDictionary setValue:self.city forKey:@"City"];
    [customerDetailDictionary setValue:self.state forKey:@"State"];
    [customerDetailDictionary setValue:self.country forKey:@"Country"];
    [customerDetailDictionary setValue:self.contactNo forKey:@"ContactNo"];
    [customerDetailDictionary setValue:self.email forKey:@"Email"];
    [customerDetailDictionary setValue:self.shipAddress1 forKey:@"ShipAddress1"];
    [customerDetailDictionary setValue:self.shipAddress2 forKey:@"ShipAddress2"];
    [customerDetailDictionary setValue:self.shipCity forKey:@"ShipCity"];
    [customerDetailDictionary setValue:self.shipZipCode forKey:@"ShipZipCode"];
    [customerDetailDictionary setValue:self.shipCountry forKey:@"ShipCountry"];
    [customerDetailDictionary setValue:self.creditLimit forKey:@"CreditLimit"];
    
    NSDate * date = [NSDate date];
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"MM/dd/yyyy";
    [customerDetailDictionary setValue:[dateFormatter stringFromDate:date] forKey:@"RegistrationDate"];
    
    [customerDetailDictionary setValue:self.drivingLienceNo forKey:@"DrivingLienceNo"];
    [customerDetailDictionary setValue:self.dateOfBirth forKey:@"DateOfBirth"];
    
    if (self.isSameAsAddesss) {
        [customerDetailDictionary setValue:@"1" forKey:@"chkRedemption"];
    }
    else{
        [customerDetailDictionary setValue:@"0" forKey:@"chkRedemption"];
    }
    [customerDetailDictionary setValue:self.customerNo forKey:@"CustomerNo"];
    return customerDetailDictionary;
    
}


@end
