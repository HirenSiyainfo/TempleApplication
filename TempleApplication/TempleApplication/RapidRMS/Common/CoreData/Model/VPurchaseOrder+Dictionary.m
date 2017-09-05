//
//  VPurchaseOrder+Dictionary.m
//  RapidRMS
//
//  Created by Siya on 09/02/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "VPurchaseOrder+Dictionary.h"

@implementation VPurchaseOrder (Dictionary)


-(void)updateVendorPoDictionary :(NSDictionary *)poDictionary;
{
    self.poId =  @([[poDictionary valueForKey:@"POId"] integerValue]);
    self.branchId =  @([[poDictionary valueForKey:@"BranchId"]integerValue]);;
    self.userID = @([[poDictionary valueForKey:@"UserID"]integerValue]);
    self.orderNo = [poDictionary valueForKey:@"OrderNo"];
    self.orderName = [poDictionary valueForKey:@"OrderName"];
    
    self.keyowrd = [poDictionary valueForKey:@"Keyowrd"];
    
    NSString *strDept = [NSString stringWithFormat:@"%@",[poDictionary valueForKey:@"Department"]];
    
    self.department = strDept;

    if([[poDictionary valueForKey:@"StartDate"] isKindOfClass:[NSString class]])
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"MM/dd/yyyy hh:mm a";
        NSDate *currentDate = [dateFormatter dateFromString:[poDictionary valueForKey:@"StartDate"]];
        self.startDate = currentDate;
    }
    else  if([[poDictionary valueForKey:@"StartDate"] isKindOfClass:[NSDate class]])
    {
        self.startDate = [poDictionary valueForKey:@"StartDate"];
    }
    
    if([[poDictionary valueForKey:@"EndDate"] isKindOfClass:[NSString class]])
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"MM/dd/yyyy hh:mm a";
        NSDate *currentDate = [dateFormatter dateFromString:[poDictionary valueForKey:@"EndDate"]];
        self.endDate = currentDate;
    }
    else  if([[poDictionary valueForKey:@"EndDate"] isKindOfClass:[NSDate class]])
    {
        self.endDate = [poDictionary valueForKey:@"EndDate"];
    }


    self.registerId = @([[poDictionary valueForKey:@"RegisterId"]integerValue]);

    self.status = @([[poDictionary valueForKey:@"Status"]integerValue]);

    if([[poDictionary valueForKey:@"CreatedDate"] isKindOfClass:[NSString class]])
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"MM/dd/yyyy hh:mm a";
        NSDate *currentDate = [dateFormatter dateFromString:[poDictionary valueForKey:@"CreatedDate"]];
        self.createdDate = currentDate;
    }
    else  if([[poDictionary valueForKey:@"CreatedDate"] isKindOfClass:[NSDate class]])
    {
        self.createdDate = [poDictionary valueForKey:@"CreatedDate"];
    }
    
    if([[poDictionary valueForKey:@"UpdateDate"] isKindOfClass:[NSString class]])
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"MM/dd/yyyy hh:mm a";
        NSDate *currentDate = [dateFormatter dateFromString:[poDictionary valueForKey:@"UpdateDate"]];
        self.updateDate = currentDate;
    }
    else  if([[poDictionary valueForKey:@"UpdateDate"] isKindOfClass:[NSDate class]])
    {
        self.updateDate = [poDictionary valueForKey:@"UpdateDate"];
    }


    self.isDelete =  @([[poDictionary valueForKey:@"IsDeleted"] integerValue]);

}

-(NSDictionary *)getVendorPoDictionary;
{
    NSMutableDictionary *vendorPODictionary=[[NSMutableDictionary alloc]init];
    vendorPODictionary[@"POId"] = self.poId;
    vendorPODictionary[@"BranchId"] = self.branchId;
    vendorPODictionary[@"UserID"] = self.userID;
    vendorPODictionary[@"OrderNo"] = self.orderNo;
    vendorPODictionary[@"OrderName"] = self.orderName;
    vendorPODictionary[@"Keyowrd"] = self.keyowrd;
    vendorPODictionary[@"Department"] = self.department;
    if(self.startDate==nil)
    {
        vendorPODictionary[@"StartDate"] = @"";
    }
    else{
        vendorPODictionary[@"StartDate"] = self.startDate;
    }
    if(self.endDate==nil)
    {
        vendorPODictionary[@"EndDate"] = @"";
    }
    else{
         vendorPODictionary[@"EndDate"] = self.endDate;
    }
    vendorPODictionary[@"RegisterId"] = self.registerId;
    vendorPODictionary[@"Status"] = self.status;
    if(self.createdDate==nil)
    {
        vendorPODictionary[@"CreatedDate"] = @"";
    }
    else{
        vendorPODictionary[@"CreatedDate"] = self.createdDate;

    }
    if(self.updateDate==nil)
    {
        vendorPODictionary[@"UpdateDate"] = @"";
    }
    else{
        vendorPODictionary[@"UpdateDate"] = self.updateDate;
        
    }
    vendorPODictionary[@"IsDeleted"] = self.isDelete;
    return  vendorPODictionary;
}

@end
