//
//  VPurchaseOrderItem+Dictionary.m
//  RapidRMS
//
//  Created by Siya on 09/02/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "VPurchaseOrderItem+Dictionary.h"

@implementation VPurchaseOrderItem (Dictionary)


-(void)updateVendorPoItemDictionary :(NSDictionary *)poItemDictionary;
{
    self.poId =  @([[poItemDictionary valueForKey:@"POId"] integerValue]);
    self.poItemId =  @([[poItemDictionary valueForKey:@"POItemId"]integerValue]);;
    self.branchId = @([[poItemDictionary valueForKey:@"BranchId"]integerValue]);
    self.itemCode = @([[poItemDictionary valueForKey:@"ItemCode"]integerValue]);
    self.singlePOQty = @([[poItemDictionary valueForKey:@"SinglePOQty"]integerValue]);
    self.casePOQty = @([[poItemDictionary valueForKey:@"CasePOQty"]integerValue]);
    self.packPOQty = @([[poItemDictionary valueForKey:@"PackPOQty"]integerValue]);
    self.singleReceivedQty = @([[poItemDictionary valueForKey:@"SingleReceivedQty"]integerValue]);
    self.caseReceivedQty = @([[poItemDictionary valueForKey:@"CaseReceivedQty"]integerValue]);
    self.packReceivedQty = @([[poItemDictionary valueForKey:@"PackReceivedQty"]integerValue]);
    self.isReturn = @([[poItemDictionary valueForKey:@"IsReturn"]integerValue]);
    self.oldQty = @([[poItemDictionary valueForKey:@"OldQty"]integerValue]);
    self.remarks = [poItemDictionary valueForKey:@"Remarks"];
    if([[poItemDictionary valueForKey:@"CreatedDate"] isKindOfClass:[NSString class]])
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"MM/dd/yyyy hh:mm a";
        NSDate *currentDate = [dateFormatter dateFromString:[poItemDictionary valueForKey:@"CreatedDate"]];
        self.createdDate = currentDate;
    }
    else  if([[poItemDictionary valueForKey:@"CreatedDate"] isKindOfClass:[NSDate class]])
    {
        self.createdDate = [poItemDictionary valueForKey:@"CreatedDate"];
    }

}

-(NSDictionary *)getVendorPoItemDictionary;
{
    NSMutableDictionary *vendorPOItemDictionary=[[NSMutableDictionary alloc]init];
    vendorPOItemDictionary[@"POId"] = self.poId;
    vendorPOItemDictionary[@"POItemId"] = self.poItemId;
    vendorPOItemDictionary[@"BranchId"] = self.branchId;
    vendorPOItemDictionary[@"ItemCode"] = self.itemCode;
    vendorPOItemDictionary[@"SinglePOQty"] = self.singlePOQty;
    vendorPOItemDictionary[@"CasePOQty"] = self.casePOQty;
    vendorPOItemDictionary[@"PackPOQty"] = self.packPOQty;
    vendorPOItemDictionary[@"SingleReceivedQty"] = self.singleReceivedQty;
    vendorPOItemDictionary[@"CaseReceivedQty"] = self.caseReceivedQty;
    vendorPOItemDictionary[@"PackReceivedQty"] = self.packReceivedQty;
    vendorPOItemDictionary[@"IsReturn"] = self.isReturn;
    vendorPOItemDictionary[@"OldQty"] = self.oldQty;
    vendorPOItemDictionary[@"Remarks"] = self.remarks;
    if(self.createdDate==nil)
    {
        vendorPOItemDictionary[@"CreatedDate"] = @"";
    }
    else{
        vendorPOItemDictionary[@"CreatedDate"] = self.createdDate;
        
    }
    
    return  vendorPOItemDictionary;
}

@end
