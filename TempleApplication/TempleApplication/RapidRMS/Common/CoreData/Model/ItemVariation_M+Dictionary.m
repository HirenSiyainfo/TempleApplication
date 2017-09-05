//
//  ItemVariation_M+Dictionary.m
//  RapidRMS
//
//  Created by Siya on 28/11/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "ItemVariation_M+Dictionary.h"

@implementation ItemVariation_M (Dictionary)

-(NSDictionary *)itemVariationMDictionary
{
    NSMutableDictionary *veriationDict=[[NSMutableDictionary alloc]init];
    
    veriationDict[@"VarianceId"] = self.varianceId;
    veriationDict[@"ItemCode"] = self.itemCode;
    veriationDict[@"BranchId"] = self.branchId;
    veriationDict[@"VariationName"] = self.variationName;
    //[veriationDict setObject:self.createdDate forKey:@"CreatedDate"];
    veriationDict[@"IsDeleted"] = self.isDelete;
    veriationDict[@"ColPosNo"] = self.colPosNo;
    
    return veriationDict;
}

-(void)updateitemVariationMDictionary :(NSDictionary *)itemVariationMDictionary
{
    self.itemCode =  @([[itemVariationMDictionary valueForKey:@"ItemCode"] integerValue]);
    self.branchId =  @([[itemVariationMDictionary valueForKey:@"BranchId"] integerValue]);
    self.variationMasterId = @([[itemVariationMDictionary valueForKey:@"VariationId"] integerValue]);
    self.varianceId = [itemVariationMDictionary valueForKey:@"Id"];
    self.colPosNo = @([[itemVariationMDictionary valueForKey:@"ColPosNo"] integerValue]);
    
//    self.createdDate = [itemVariationMDictionary valueForKey:@"CreatedDate"];
//    self.variationName = [itemVariationMDictionary valueForKey:@"VariationName"] ;
//    self.isDelete = @([[itemVariationMDictionary valueForKey:@"IsDeleted"] integerValue]);
}

@end