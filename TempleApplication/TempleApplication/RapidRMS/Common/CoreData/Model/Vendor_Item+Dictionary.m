//
//  Vendor_Item+Dictionary.m
//  RapidRMS
//
//  Created by Siya on 14/10/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "Vendor_Item+Dictionary.h"

@implementation Vendor_Item (Dictionary)
-(NSDictionary *)vendorItemDictionary
{
    return nil;
}
-(void)updatevendorItemDictionary :(NSDictionary *)venderItemDictionary;
{
    self.zoneId =  @([[venderItemDictionary valueForKey:@"Zone"] integerValue]);
    self.vendor_Id =  @([[venderItemDictionary valueForKey:@"VendorId"] integerValue]);
    self.vin =  @([[venderItemDictionary valueForKey:@"SupplierItemCode"] integerValue]);
    
    self.vendor_Item_Id =  @([[venderItemDictionary valueForKey:@"ID"] integerValue]);
    
    self.globalSub =  @([[venderItemDictionary valueForKey:@"SubItem"] integerValue]);
    self.srpFactor =  @([[venderItemDictionary valueForKey:@"CaseUnits"] integerValue]);
    
    self.size =  @([[venderItemDictionary valueForKey:@"Size"] floatValue]);
    self.itemDescription =  [venderItemDictionary valueForKey:@"ItemDescriptions"];
    self.itemCategory =  @([[venderItemDictionary valueForKey:@"CategoryId"] integerValue]);
    self.categoryDesc =  [venderItemDictionary valueForKey:@"Cat_Description"];
    
    NSNumberFormatter *f1 = [[NSNumberFormatter alloc] init];
    f1.numberStyle = kCFNumberFormatterNoStyle;
    NSNumber *upcCarton = [f1 numberFromString:[venderItemDictionary valueForKey:@"Carton_UPC"]];
    
    NSNumberFormatter *f2 = [[NSNumberFormatter alloc] init];
    f2.numberStyle = kCFNumberFormatterNoStyle;
    NSNumber *upcPack = [f2 numberFromString:[venderItemDictionary valueForKey:@"Pack_UPC"]];

    self.cartonUpc =  upcCarton;
    self.packUpc =  upcPack;

    self.itemPrice =  @([[venderItemDictionary valueForKey:@"Price"] floatValue]);
    self.lineFor =  @([[venderItemDictionary valueForKey:@"Line_For"] integerValue]);
    self.linePerPrice =  @([[venderItemDictionary valueForKey:@"Line_Retail"] floatValue]);
    self.unitRetail =  @([[venderItemDictionary valueForKey:@"Unit_Retail"] floatValue]);
    self.invoiceCategory =  @([[venderItemDictionary valueForKey:@"Invoice_CatId"] integerValue]);
    self.categoryDescription = [venderItemDictionary valueForKey:@"Invoice_Cat_Description"];
    
    if([[venderItemDictionary valueForKey:@"IsNew"] isEqualToString:@"N"])
    {
         self.isNew = @(0);
    }
    else{
        self.isNew = @(1);
    }
    
    if([[venderItemDictionary valueForKey:@"Effective_Date"] isKindOfClass:[NSString class]])
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss.zzz";
        NSDate *currentDate = [dateFormatter dateFromString:[venderItemDictionary valueForKey:@"Effective_Date"]];
        self.effectiveDate = currentDate;
    }
    else  if([[venderItemDictionary valueForKey:@"Effective_Date"] isKindOfClass:[NSDate class]])
    {
        self.effectiveDate = [venderItemDictionary valueForKey:@"Effective_Date"];
    }
    
    self.unitCost = [venderItemDictionary valueForKey:@"Unit_Cost"];
    self.isDelete =  @([[venderItemDictionary valueForKey:@"IsDeleted"] integerValue]);


}

-(NSDictionary *)getVendorItemDictionary
{
    NSMutableDictionary *vendorDictionary=[[NSMutableDictionary alloc]init];
    vendorDictionary[@"Zone"] = self.zoneId;
    vendorDictionary[@"VendorId"] = self.vendor_Id;
    vendorDictionary[@"SupplierItemCode"] = self.vin;
    vendorDictionary[@"ID"] = self.vendor_Item_Id;
    
    vendorDictionary[@"SubItem"] = self.globalSub;
    vendorDictionary[@"CaseUnits"] = self.srpFactor;
    
    vendorDictionary[@"Size"] = self.size;
    vendorDictionary[@"ItemDescriptions"] = self.itemDescription;
    vendorDictionary[@"CategoryId"] = self.itemCategory;
    vendorDictionary[@"Cat_Description"] = self.categoryDesc;
    vendorDictionary[@"Carton_UPC"] = self.cartonUpc;
    
    vendorDictionary[@"Pack_UPC"] = self.packUpc;
    vendorDictionary[@"Price"] = self.itemPrice;
    vendorDictionary[@"Line_For"] = self.lineFor;
    vendorDictionary[@"Line_Retail"] = self.linePerPrice;
    
    vendorDictionary[@"Unit_Retail"] = self.unitRetail;
    vendorDictionary[@"Invoice_CatId"] = self.invoiceCategory;
    vendorDictionary[@"Invoice_Cat_Description"] = self.categoryDescription;
    vendorDictionary[@"Unit_Cost"] = self.unitCost;
    
    vendorDictionary[@"Effective_Date"] = self.effectiveDate;
    vendorDictionary[@"IsDeleted"] = self.isDelete;
    vendorDictionary[@"IsNew"] = self.isNew;

    return  vendorDictionary;
}

@end
