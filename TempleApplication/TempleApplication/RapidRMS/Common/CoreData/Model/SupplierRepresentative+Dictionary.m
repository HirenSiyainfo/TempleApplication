//
//  SupplierRepresentative+Dictionary.m
//  RapidRMS
//
//  Created by Siya on 18/03/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "SupplierRepresentative+Dictionary.h"

@implementation SupplierRepresentative (Dictionary)


-(void)updateSupplierRepresentativeDictionary :(NSDictionary *)csupplierDictionary;
{
    self.srno =  @([[csupplierDictionary valueForKey:@"SrNo"] integerValue]);
    self.brnSupplierId =  @([[csupplierDictionary valueForKey:@"BrnSupplierId"]integerValue]);
    self.branchId = @([[csupplierDictionary valueForKey:@"BranchId"]integerValue]);
    self.companyName = [csupplierDictionary valueForKey:@"CompanyName"];
    self.firstName = [csupplierDictionary valueForKey:@"FirstName"];
    
    self.position = [csupplierDictionary valueForKey:@"Position"];
    self.address1 = [csupplierDictionary valueForKey:@"Address1"];
    self.address2 = [csupplierDictionary valueForKey:@"Address2"];
    self.city = [csupplierDictionary valueForKey:@"City"];
    self.state = [csupplierDictionary valueForKey:@"State"];
    self.zipCode = [csupplierDictionary valueForKey:@"ZipCode"];
    self.contactNo = [csupplierDictionary valueForKey:@"ContactNo"];
    self.email = [csupplierDictionary valueForKey:@"Email"];
    
    self.createdBy = [csupplierDictionary valueForKey:@"CreatedBy"];
    
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

    self.isDelete = [csupplierDictionary valueForKey:@"IsDelete"];
    
    self.selectedPhoneNo = [csupplierDictionary valueForKey:@"SelectedPhoneNo"];
    self.companyId = @([[csupplierDictionary valueForKey:@"CompanyId"]integerValue]);
}

-(NSDictionary *)getSupplierRepresentativeDictionary;
{

    NSMutableDictionary *supplierRepresentative=[[NSMutableDictionary alloc]init];
    
    supplierRepresentative[@"SrNo"] = self.srno;
    supplierRepresentative[@"BrnSupplierId"] = self.brnSupplierId;
    supplierRepresentative[@"BranchId"] = self.branchId;
    supplierRepresentative[@"CompanyName"] = self.companyName;
    supplierRepresentative[@"FirstName"] = self.firstName;
    
    supplierRepresentative[@"Position"] = self.position;
    supplierRepresentative[@"Address1"] = self.address1;
    supplierRepresentative[@"Address2"] = self.address2;
    supplierRepresentative[@"City"] = self.city;
    supplierRepresentative[@"State"] = self.state;
    supplierRepresentative[@"ZipCode"] = self.zipCode;
    supplierRepresentative[@"ContactNo"] = self.contactNo;
    supplierRepresentative[@"CreatedBy"] = self.createdBy;
    
    supplierRepresentative[@"CreatedDate"] = self.createdDate;
    supplierRepresentative[@"IsDelete"] = self.isDelete;
    supplierRepresentative[@"SelectedPhoneNo"] = self.selectedPhoneNo;
    
    supplierRepresentative[@"CompanyId"] = self.companyId;
    
    return  supplierRepresentative;
}

@end
