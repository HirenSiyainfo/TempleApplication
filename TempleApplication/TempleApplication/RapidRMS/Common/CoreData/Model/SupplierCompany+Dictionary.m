//
//  SupplierCompany+Dictionary.m
//  RapidRMS
//
//  Created by Siya Infotech on 29/01/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "SupplierCompany+Dictionary.h"

@implementation SupplierCompany (Dictionary)



-(void)updateSupplierCompanyDictionary :(NSDictionary *)csupplierDictionary;
{
    self.companyId =  @([[csupplierDictionary valueForKey:@"Id"] integerValue]);
    self.companyName =  [csupplierDictionary valueForKey:@"CompanyName"];
    self.companyZone = [csupplierDictionary valueForKey:@"CompanyZone"];
    
    if([[csupplierDictionary valueForKey:@"CreatedDate"] isKindOfClass:[NSString class]])
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss.zzz";
        NSDate *currentDate = [dateFormatter dateFromString:[csupplierDictionary valueForKey:@"CreatedDate"]];
        self.createdDate = currentDate;
    }
    else  if([[csupplierDictionary valueForKey:@"CreatedDate"] isKindOfClass:[NSDate class]])
    {
        self.createdDate = [csupplierDictionary valueForKey:@"CreatedDate"];
    }

    self.isDelete = @([[csupplierDictionary valueForKey:@"IsDeleted"] integerValue]);
    
    self.address = [csupplierDictionary valueForKey:@"Address"];
    self.city = [csupplierDictionary valueForKey:@"City"];
    self.state = [csupplierDictionary valueForKey:@"State"];
    self.branchId = [csupplierDictionary valueForKey:@"BranchId"];
    self.createdBy = @([[csupplierDictionary valueForKey:@"CreatedBy"]integerValue]);
    self.email = [csupplierDictionary valueForKey:@"Email"];
    self.phoneNo = [csupplierDictionary valueForKey:@"PhoneNo"];
    self.zipCode = [csupplierDictionary valueForKey:@"ZipCode"];
    
    self.venderId = [csupplierDictionary valueForKey:@"VenderId"];
    self.supplierZone = [csupplierDictionary valueForKey:@"SupplierZone"];
    self.supplierDatabase = [csupplierDictionary valueForKey:@"SupplierDatabase"];
}

-(NSDictionary *)getSupplierCompanyDictionary;
{
    NSMutableDictionary *companySupplier=[[NSMutableDictionary alloc]init];
    companySupplier[@"Id"] = self.companyId;
    companySupplier[@"CompanyName"] = self.companyName;
    companySupplier[@"CompanyZone"] = self.companyZone;
    companySupplier[@"CreatedDate"] = self.createdDate;
    companySupplier[@"IsDeleted"] = self.isDelete;
    companySupplier[@"Address"] = self.address;
    companySupplier[@"City"] = self.city;
    companySupplier[@"State"] = self.state;
    companySupplier[@"BranchId"] = self.branchId;
    companySupplier[@"CreatedBy"] = self.createdBy;
    companySupplier[@"Email"] = self.email;
    companySupplier[@"PhoneNo"] = self.phoneNo;
    companySupplier[@"ZipCode"] = self.zipCode;
    companySupplier[@"VenderId"] = self.venderId;
    companySupplier[@"SupplierZone"] = self.supplierZone;
    companySupplier[@"SupplierDatabase"] = self.supplierDatabase;
    return  companySupplier;
}

-(NSDictionary *)getSupplierCompanyDetailsDictionary
{
    NSMutableDictionary *supplierDetailDictionary=[[NSMutableDictionary alloc]init];
    supplierDetailDictionary[@"BrnSupplierId"] = self.companyId;
    supplierDetailDictionary[@"FirstName"] = self.companyName;
    supplierDetailDictionary[@"LastName"] = self.companyName;
    supplierDetailDictionary[@"ContactNo"] = self.phoneNo;
    supplierDetailDictionary[@"Email"] = self.email;
    supplierDetailDictionary[@"CompanyName"] = self.companyName;
    return supplierDetailDictionary;
}

@end
