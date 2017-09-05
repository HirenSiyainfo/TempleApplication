//
//  Customer.m
//  RapidRMS
//
//  Created by Siya Infotech on 08/06/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "Customer.h"

@implementation Customer

// Insert code here to add functionality to your managed object subclass

-(NSDictionary *)customerInfoDictionary {
    
    NSMutableDictionary * customerInfoDictionary = [[NSMutableDictionary alloc]init];
    customerInfoDictionary[@"Address1"] = [NSString stringWithFormat:@"%@", self.address1];
    customerInfoDictionary[@"Address2"] = [NSString stringWithFormat:@"%@", self.address2];
    customerInfoDictionary[@"BranchId"] = [NSString stringWithFormat:@"%@", self.branchId];
    customerInfoDictionary[@"City"] = [NSString stringWithFormat:@"%@", self.city];
    customerInfoDictionary[@"ContactNo"] = [NSString stringWithFormat:@"%@", self.contactNo] ;
    customerInfoDictionary[@"Country"] = [NSString stringWithFormat:@"%@", self.country];
    customerInfoDictionary[@"CreditLimit"] = [NSString stringWithFormat:@"%.2f", self.creditLimit.floatValue];
    customerInfoDictionary[@"CustId"] = [NSString stringWithFormat:@"%@", self.custId.stringValue];
    customerInfoDictionary[@"DateOfBirth"] = [NSString stringWithFormat:@"%@", self.dateOfBirth];
    customerInfoDictionary[@"DrivingLienceNo"] = [NSString stringWithFormat:@"%@", self.drivingLienceNo];
    customerInfoDictionary[@"Email"] = [NSString stringWithFormat:@"%@", self.email];
    customerInfoDictionary[@"FirstName"] = [NSString stringWithFormat:@"%@", self.firstName];
    customerInfoDictionary[@"ISDeleted"] = @(self.isDelete.boolValue);
    customerInfoDictionary[@"LastName"] = [NSString stringWithFormat:@"%@", self.lastName];
    customerInfoDictionary[@"QRCode"] = [NSString stringWithFormat:@"%@", self.qRCode];
    customerInfoDictionary[@"RegistrationDate"] = [NSString stringWithFormat:@"%@", self.registrationDate];
    customerInfoDictionary[@"ShipAddress1"] = [NSString stringWithFormat:@"%@", self.shipAddress1];
    customerInfoDictionary[@"ShipAddress2"] = [NSString stringWithFormat:@"%@", self.shipAddress2];
    customerInfoDictionary[@"ShipCity"] = [NSString stringWithFormat:@"%@", self.shipCity];
    customerInfoDictionary[@"ShipCountry"] =[NSString stringWithFormat:@"%@", self.shipCountry];
    customerInfoDictionary[@"ShipZipCode"] = [NSString stringWithFormat:@"%@", self.shipZipCode];
    customerInfoDictionary[@"State"] = [NSString stringWithFormat:@"%@", self.state];
    customerInfoDictionary[@"ZipCode"] = [NSString stringWithFormat:@"%@", self.zipCode];
    customerInfoDictionary[@"chkRedemption"] = @(self.chkRedemption.boolValue);
    customerInfoDictionary[@"CustomerNo"] = [NSString stringWithFormat:@"%@", self.qRCode];

    return customerInfoDictionary;
}


-(void)updateCustomerDetailDictionary :(NSDictionary *)customerDictionary
{
    self.address1 = [NSString stringWithFormat:@"%@",[customerDictionary valueForKey:@"Address1"]];
    self.address2 = [NSString stringWithFormat:@"%@",[customerDictionary valueForKey:@"Address2"]];
    self.branchId = @([customerDictionary[@"BranchId"] integerValue]);
    self.city = [NSString stringWithFormat:@"%@",[customerDictionary valueForKey:@"City"]];
    self.contactNo = [NSString stringWithFormat:@"%@",[customerDictionary valueForKey:@"ContactNo"]];
    self.country = [NSString stringWithFormat:@"%@",[customerDictionary valueForKey:@"Country"]];
    self.creditLimit = @([customerDictionary[@"CreditLimit"] floatValue]);
    self.custId = @([customerDictionary[@"CustId"] floatValue]);
    self.dateOfBirth = [NSString stringWithFormat:@"%@",[customerDictionary valueForKey:@"DateOfBirth"]];
    self.drivingLienceNo = [NSString stringWithFormat:@"%@",[customerDictionary valueForKey:@"DrivingLienceNo"]];
    self.email = [NSString stringWithFormat:@"%@",[customerDictionary valueForKey:@"Email"]];
    self.firstName = [NSString stringWithFormat:@"%@",[customerDictionary valueForKey:@"FirstName"]];
    self.lastName = [NSString stringWithFormat:@"%@",[customerDictionary valueForKey:@"LastName"]];
    self.qRCode = [NSString stringWithFormat:@"%@",[customerDictionary valueForKey:@"CustomerNo"]];
    self.registrationDate = [NSString stringWithFormat:@"%@",[customerDictionary valueForKey:@"RegistrationDate"]];
    self.shipAddress1 = [NSString stringWithFormat:@"%@",[customerDictionary valueForKey:@"ShipAddress1"]];
    self.shipAddress2 = [NSString stringWithFormat:@"%@",[customerDictionary valueForKey:@"ShipAddress2"]];
    self.shipCity = [NSString stringWithFormat:@"%@",[customerDictionary valueForKey:@"ShipCity"]];
    self.shipCountry = [NSString stringWithFormat:@"%@",[customerDictionary valueForKey:@"ShipCountry"]];
    self.shipZipCode = @([customerDictionary[@"ShipZipCode"] integerValue]);
    self.state = [NSString stringWithFormat:@"%@",[customerDictionary valueForKey:@"State"]];
    self.zipCode = @([customerDictionary[@"ZipCode"] integerValue]);
    self.chkRedemption = @([customerDictionary[@"chkRedemption"] boolValue]);
   self.isDelete = @([customerDictionary[@"ISDeleted"] boolValue]);
    
}

@end
