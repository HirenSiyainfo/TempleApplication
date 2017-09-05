//
//  ManualReceivedItem+Dictionary.m
//  RapidRMS
//
//  Created by Siya on 16/01/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "ManualReceivedItem+Dictionary.h"

@implementation ManualReceivedItem (Dictionary)


-(NSDictionary *)manualPoitemSessionDictionary
{
    return nil;
}

-(void)updateManualPoitemDictionary :(NSDictionary *)manualPOitemDictionary;
{
    self.caseCost =  @([[manualPOitemDictionary valueForKey:@"caseCost"] floatValue]);
    self.caseMarkup = @([[manualPOitemDictionary valueForKey:@"caseMarkup"] floatValue]);
    self.casePrice =  @([[manualPOitemDictionary valueForKey:@"casePrice"] floatValue]);
    self.caseQuantityReceived =  @(fabsf([[manualPOitemDictionary valueForKey:@"caseQuantityReceived"] floatValue]));
    self.cashQtyonHand =  @([[manualPOitemDictionary valueForKey:@"cashQtyonHand"] floatValue]);
    
    self.packCost =  @([[manualPOitemDictionary valueForKey:@"packCost"] floatValue]);
    self.packMarkup = @([[manualPOitemDictionary valueForKey:@"packMarkup"] floatValue]);
    self.packPrice =  @([[manualPOitemDictionary valueForKey:@"packPrice"] floatValue]);
    self.packQuantityReceived =  @(fabsf([[manualPOitemDictionary valueForKey:@"packQuantityReceived"] floatValue]));
     self.packQtyonHand =  @([[manualPOitemDictionary valueForKey:@"packQtyonHand"] floatValue]);
    
    
    self.unitCost =  @([[manualPOitemDictionary valueForKey:@"unitCost"] floatValue]);
    self.unitMarkup = @([[manualPOitemDictionary valueForKey:@"unitMarkup"] floatValue]);
    self.unitPrice =  @([[manualPOitemDictionary valueForKey:@"unitPrice"] floatValue]);
    self.unitQuantityReceived =  @(fabsf([[manualPOitemDictionary valueForKey:@"unitQuantityReceived"] floatValue]));
    self.unitQtyonHand =  @([[manualPOitemDictionary valueForKey:@"unitQtyonHand"] floatValue]);
    
    if ([manualPOitemDictionary objectForKey:@"LocalDate"]) {
        self.createDate =  [manualPOitemDictionary valueForKey:@"LocalDate"];
    }
    else if([manualPOitemDictionary objectForKey:@"createDate"]){
        self.createDate =  [manualPOitemDictionary valueForKey:@"createDate"];
    }
    if([manualPOitemDictionary valueForKey:@"receivedItemId"])
    {
         self.receivedItemId =  @([[manualPOitemDictionary valueForKey:@"receivedItemId"] integerValue]);
    }

     self.singleReceivedFreeGoodQty =  @(fabsf([[manualPOitemDictionary valueForKey:@"singleReceivedFreeGoodQty"] floatValue]));
     self.caseReceivedFreeGoodQty =  @(fabsf([[manualPOitemDictionary valueForKey:@"caseReceivedFreeGoodQty"] floatValue]));
     self.packReceivedFreeGoodQty =  @(fabsf([[manualPOitemDictionary valueForKey:@"packReceivedFreeGoodQty"] floatValue]));
     self.freeGoodCost =  @([[manualPOitemDictionary valueForKey:@"freeGoodCost"] floatValue]);
     self.freeGoodCaseCost =  @([[manualPOitemDictionary valueForKey:@"freeGoodCaseCost"] floatValue]);
     self.freeGoodPackCost =  @([[manualPOitemDictionary valueForKey:@"freeGoodPackCost"] floatValue]);
    
     self.isReturn =  @([[manualPOitemDictionary valueForKey:@"isReturn"] integerValue]);
}

-(NSDictionary *)getmanualPoItemSessionDictionary;
{
    NSMutableDictionary *subpricintDict=[[NSMutableDictionary alloc]init];
    subpricintDict[@"caseCost"] = self.caseCost;
    subpricintDict[@"caseMarkup"] = self.caseMarkup;
    subpricintDict[@"casePrice"] = self.casePrice;
    subpricintDict[@"caseQuantityReceived"] = self.caseQuantityReceived;
    subpricintDict[@"cashQtyonHand"] = self.cashQtyonHand;
    
    subpricintDict[@"packCost"] = self.packCost;
    subpricintDict[@"packMarkup"] = self.packMarkup;
    subpricintDict[@"packPrice"] = self.packPrice;
    subpricintDict[@"packQuantityReceived"] = self.packQuantityReceived;
    subpricintDict[@"packQtyonHand"] = self.packQtyonHand;
    
    subpricintDict[@"unitCost"] = self.unitCost;
    subpricintDict[@"unitMarkup"] = self.unitMarkup;
    subpricintDict[@"unitPrice"] = self.unitPrice;
    subpricintDict[@"unitQuantityReceived"] = self.unitQuantityReceived;
    subpricintDict[@"unitQtyonHand"] = self.unitQtyonHand;
    
    
    subpricintDict[@"singleReceivedFreeGoodQty"] = self.singleReceivedFreeGoodQty;
    subpricintDict[@"caseReceivedFreeGoodQty"] = self.caseReceivedFreeGoodQty;
    subpricintDict[@"packReceivedFreeGoodQty"] = self.packReceivedFreeGoodQty;
    subpricintDict[@"freeGoodCost"] = self.freeGoodCost;
    subpricintDict[@"freeGoodCaseCost"] = self.freeGoodCaseCost;
    subpricintDict[@"freeGoodPackCost"] = self.freeGoodPackCost;
    
     subpricintDict[@"isReturn"] = self.isReturn;
    subpricintDict[@"receivedItemId"] = self.receivedItemId;
    
    
    return  subpricintDict;
}

-(void)interChangeValuefrom:(ManualReceivedItem *)mItem{
    
    self.caseCost =  mItem.caseCost;
    self.caseMarkup = mItem.caseMarkup;
    self.casePrice =  mItem.casePrice;
    self.cashQtyonHand =  mItem.cashQtyonHand;
    
    self.packCost =  mItem.packCost;
    self.packMarkup = mItem.packMarkup;
    self.packPrice =  mItem.packPrice;
    self.packQtyonHand =  mItem.packQtyonHand;
    
    
    self.unitCost =  mItem.unitCost;
    self.unitMarkup = mItem.unitMarkup;
    self.unitPrice =  mItem.unitPrice;
}
@end
