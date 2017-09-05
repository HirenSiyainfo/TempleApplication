//
//  ItemInventoryReconcileCount+Dictionary.m
//  RapidRMS
//
//  Created by siya-IOS5 on 1/3/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "ItemInventoryReconcileCount+Dictionary.h"
#import "Item+Dictionary.h"
#import "Item_Price_MD+Dictionary.h"

@implementation ItemInventoryReconcileCount (Dictionary)
-(void)resetItemInventoryCountSessionWithDictionary :(NSDictionary *)sessionDictionary withItem:(Item *)item
{
    if(![sessionDictionary valueForKey:@"StartDate"])
    {
        self.createDate = [NSDate date];
    }

    if([[sessionDictionary valueForKey:@"StartDate"] isKindOfClass:[NSString class]])
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"MM/dd/yyyy HH:mm:ss";
        NSDate *currentDate = [dateFormatter dateFromString:[sessionDictionary valueForKey:@"StartDate"]];
        self.createDate = currentDate;
    }
    else if([[sessionDictionary valueForKey:@"StartDate"] isKindOfClass:[NSDate class]])
    {
        self.createDate = [sessionDictionary valueForKey:@"StartDate"];
    }
    
//    self.createDate = [sessionDictionary valueForKey:@"StartDate"];
    self.sessionId = [sessionDictionary valueForKey:@"StockSessionId"];
    self.singleCount  =  @(0);
    self.caseCount  = @(0);
    self.packCount  =  @(0);
    self.itemCode  = @(item.itemCode.integerValue);
    self.userId  = [sessionDictionary valueForKey:@"userId"];
    self.registerId = [sessionDictionary valueForKey:@"registerId"];
    self.singleQuantity  =  @([self qtyForPriceMdForpackageType:@"Single Item" withItem:item]);
    self.packQuantity  =  @([self qtyForPriceMdForpackageType:@"Pack" withItem:item]);
    self.caseQuantity  =  @([self qtyForPriceMdForpackageType:@"Case" withItem:item]);
    self.expectedQuantity = @(item.item_InStock.floatValue);
    self.isMatching = @(0);    
}


-(void)resetItemInventoryCountSessionForHistoryWithDictionary :(NSDictionary *)sessionDictionary withItem:(Item *)item
{
    if(![sessionDictionary valueForKey:@"StartDate"])
    {
        self.createDate = [NSDate date];
    }
    
    if([[sessionDictionary valueForKey:@"StartDate"] isKindOfClass:[NSString class]])
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"MM/dd/yyyy HH:mm:ss";
        NSDate *currentDate = [dateFormatter dateFromString:[sessionDictionary valueForKey:@"StartDate"]];
        self.createDate = currentDate;
    }
    else if([[sessionDictionary valueForKey:@"StartDate"] isKindOfClass:[NSDate class]])
    {
        self.createDate = [sessionDictionary valueForKey:@"StartDate"];
    }
    
    //    self.createDate = [sessionDictionary valueForKey:@"StartDate"];
    self.sessionId = [sessionDictionary valueForKey:@"StockSessionId"];
    self.singleCount  =  @(0);
    self.caseCount  = @(0);
    self.packCount  =  @(0);
    self.itemCode  = @(item.itemCode.integerValue);
    self.userId  = [sessionDictionary valueForKey:@"userId"];
    self.registerId = [sessionDictionary valueForKey:@"registerId"];
    self.singleQuantity  =  @([[sessionDictionary valueForKey:@"SingleCount"] floatValue]);
    self.packQuantity  =  @([[sessionDictionary valueForKey:@"PackCount"] floatValue]);
    self.caseQuantity  =  @([[sessionDictionary valueForKey:@"CaseCount"] floatValue]);
    self.expectedQuantity = @([[sessionDictionary valueForKey:@"QtyOnHand"] floatValue]);
    self.isMatching = @(0);
}


-(CGFloat)qtyForPriceMdForpackageType :(NSString *)packagetype withItem:(Item *)item
{
    CGFloat qty = 0.0;
    NSArray *priceToItemArray = item.itemToPriceMd.allObjects;
    
    for (Item_Price_MD *price_md in priceToItemArray)
    {
        if ([price_md.priceqtytype isEqualToString:packagetype])
        {
            qty= price_md.qty.floatValue;
        }
    }
    return qty;
}

@end
