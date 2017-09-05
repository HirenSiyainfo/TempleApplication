//
//  Variation_Master+Dictionary.m
//  RapidRMS
//
//  Created by Siya on 03/12/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "Variation_Master+Dictionary.h"

@implementation Variation_Master (Dictionary)

-(NSDictionary *)itemVariationMasteDictionary
{
    NSMutableDictionary *veriationMasterDict=[[NSMutableDictionary alloc]init];
    veriationMasterDict[@"vid"] = self.vid;
    veriationMasterDict[@"Name"] = self.name;
    return veriationMasterDict;
}

-(void)updateMasterVariationMDictionary :(NSDictionary *)itemVariationMDictionary
{
    self.vid =  @([[itemVariationMDictionary valueForKey:@"vid"] integerValue]);
    self.name = [itemVariationMDictionary valueForKey:@"name"] ;
}

@end
