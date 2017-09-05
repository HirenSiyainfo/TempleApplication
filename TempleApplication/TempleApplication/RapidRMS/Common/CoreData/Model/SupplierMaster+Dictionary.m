//
//  SupplierMaster+Dictionary.m
//  POSRetail
//
//  Created by Siya Infotech on 15/03/14.
//  Copyright (c) 2014 Nirav Patel. All rights reserved.
//

#import "SupplierMaster+Dictionary.h"

@implementation SupplierMaster (Dictionary)
-(NSDictionary *)supplierMasterDictionary
{
    return nil;
}

-(NSDictionary *)supplierLoadDictionary
{
    NSMutableDictionary *supplierDetailDictionary=[[NSMutableDictionary alloc]init];
    supplierDetailDictionary[@"BrnSupplierId"] = self.brnSupplierId;
    supplierDetailDictionary[@"FirstName"] = self.firstName;
    supplierDetailDictionary[@"LastName"] = self.lastName;
    supplierDetailDictionary[@"ContactNo"] = self.contactNo;
    supplierDetailDictionary[@"Email"] = self.email;
    supplierDetailDictionary[@"CompanyName"] = self.companyName;

    return  supplierDetailDictionary;
}

-(void)updateSupplierMasterFromDictionary :(NSDictionary *)supplierMasterDictionary
{
    self.brnSupplierId =  @([[supplierMasterDictionary valueForKey:@"BrnSupplierId"] integerValue]);;
    self.firstName =[supplierMasterDictionary valueForKey:@"FirstName"] ;
    self.lastName =[supplierMasterDictionary valueForKey:@"LastName"];
    self.contactNo = [supplierMasterDictionary valueForKey:@"ContactNo"];
    self.email = [supplierMasterDictionary valueForKey:@"Email"];
    self.companyName = [supplierMasterDictionary valueForKey:@"CompanyName"] ;
}
@end
