//
//  ManualPOSession+Dictionary.m
//  RapidRMS
//
//  Created by Siya on 16/01/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "ManualPOSession+Dictionary.h"

@implementation ManualPOSession (Dictionary)

-(NSDictionary *)manualPoSessionDictionary
{
    return nil;
}

-(void)updateManualPoDictionary :(NSDictionary *)manualPODictionary;
{
    self.manualPoId =  @([[manualPODictionary valueForKey:@"manualPoId"] integerValue]);
    self.poRemark =  [manualPODictionary valueForKey:@"poRemark"];
    self.receivedDate = [manualPODictionary valueForKey:@"receivedDate"];
    self.supplierId = [manualPODictionary valueForKey:@"supplierId"];
    self.invoiceNumber = [manualPODictionary valueForKey:@"invoiceNumber"];
}

-(NSDictionary *)getmanualPoSessionDictionary;
{
    NSMutableDictionary *subDepartmentDictionary=[[NSMutableDictionary alloc]init];
    subDepartmentDictionary[@"manualPoId"] = self.manualPoId;
    subDepartmentDictionary[@"poRemark"] = self.poRemark;
    subDepartmentDictionary[@"receivedDate"] = self.receivedDate;
    subDepartmentDictionary[@"supplierId"] = self.supplierId;
    subDepartmentDictionary[@"invoiceNumber"] = self.invoiceNumber;
    
    return  subDepartmentDictionary;
}

@end
