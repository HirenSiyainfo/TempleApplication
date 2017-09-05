//
//  ItemVariation_Md+Dictionary.m
//  RapidRMS
//
//  Created by Siya on 28/11/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "ItemVariation_Md+Dictionary.h"

@implementation ItemVariation_Md (Dictionary)



-(NSDictionary *)itemVariationMdDictionary
{
    NSMutableDictionary *veriationMDDict=[[NSMutableDictionary alloc]init];
    
    veriationMDDict[@"VarianceId"] = self.varianceId;
    veriationMDDict[@"ItemCode"] = self.itemCode;
    veriationMDDict[@"BranchId"] = self.branchId;
    veriationMDDict[@"Name"] = self.name;
    //[veriationMDDict setObject:self.createdDate forKey:@"CreatedDate"];
    veriationMDDict[@"IsDeleted"] = self.isDelete;
    veriationMDDict[@"Cost"] = self.cost;
    veriationMDDict[@"Profit"] = self.profit;
    veriationMDDict[@"UnitPrice"] = self.unitPrice;
    veriationMDDict[@"PriceA"] = self.priceA;
    veriationMDDict[@"PriceB"] = self.priceB;
    veriationMDDict[@"PriceC"] = self.priceC;
    veriationMDDict[@"ApplyPrice"] = self.applyPrice;
    veriationMDDict[@"RowPosNo"] = self.rowPosNo;
    
    return veriationMDDict;
}

-(void)updateitemVariationMdDictionary :(NSDictionary *)itemVariationMdDictionary
{
    self.varianceId =  @([[itemVariationMdDictionary valueForKey:@"VarianceId"] integerValue]);
    self.itemCode =  @([[itemVariationMdDictionary valueForKey:@"ItemCode"] integerValue]);
    self.branchId =  @([[itemVariationMdDictionary valueForKey:@"BranchId"] integerValue]);
    self.name = [itemVariationMdDictionary valueForKey:@"Name"] ;
    //self.createdDate = [itemVariationMdDictionary valueForKey:@"CreatedDate"];
    self.isDelete = @([[itemVariationMdDictionary valueForKey:@"IsDeleted"] integerValue]);
    self.cost = @([[itemVariationMdDictionary valueForKey:@"Cost"] floatValue]);
    self.profit = @([[itemVariationMdDictionary valueForKey:@"Profit"] floatValue]);
    self.unitPrice = @([[itemVariationMdDictionary valueForKey:@"UnitPrice"] floatValue]);
    self.priceA = @([[itemVariationMdDictionary valueForKey:@"PriceA"] floatValue]);
    self.priceB = @([[itemVariationMdDictionary valueForKey:@"PriceB"] floatValue]);
    self.priceC = @([[itemVariationMdDictionary valueForKey:@"PriceC"] floatValue]);
    self.applyPrice = [itemVariationMdDictionary valueForKey:@"ApplyPrice"];
    self.rowPosNo = @([[itemVariationMdDictionary valueForKey:@"RowPosNo"] integerValue]);
}
@end
