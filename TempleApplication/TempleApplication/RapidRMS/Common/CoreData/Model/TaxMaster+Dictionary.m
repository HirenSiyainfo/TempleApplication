
//  TaxMaster+Dictionary.m
//  POSRetail
//
//  Created by Siya Infotech on 15/03/14.
//  Copyright (c) 2014 Nirav Patel. All rights reserved.
//

#import "TaxMaster+Dictionary.h"

@implementation TaxMaster (Dictionary)

-(NSDictionary *)taxMasterDictionary
{
    NSMutableDictionary *dictTaxMaster = [[NSMutableDictionary alloc]init];
    dictTaxMaster[@"TaxId"] = [NSString stringWithFormat:@"%@",self.taxId];
    dictTaxMaster[@"TAXNAME"] = self.taxNAME;
    dictTaxMaster[@"PERCENTAGE"] = [NSString stringWithFormat:@"%@",self.percentage];
    dictTaxMaster[@"Type"] = self.type;
    dictTaxMaster[@"Amount"] = [NSString stringWithFormat:@"%@",self.amount];
    return dictTaxMaster;
}
-(void)updateTaxMasterFromDictionary :(NSDictionary *)taxMasterDictionary
{
    self.taxId =  @([[taxMasterDictionary valueForKey:@"TaxId"] integerValue]);
    self.taxNAME =[taxMasterDictionary valueForKey:@"TAXNAME"] ;
    self.percentage =[taxMasterDictionary valueForKey:@"PERCENTAGE"];
    self.type = [taxMasterDictionary valueForKey:@"Type"];
   self.amount = [taxMasterDictionary valueForKey:@"Amount"];

}
@end
