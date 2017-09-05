//
//  POOrderDetailCell.m
//  RapidRMS
//
//  Created by Siya10 on 13/10/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "POOrderDetailCell.h"
#import "RmsDbController.h"
#import "Item+Dictionary.h"
#import "Item_Price_MD+Dictionary.h"
#import "Item_Discount_MD2+Dictionary.h"
#import "Item_Discount_MD+Dictionary.h"

@implementation POOrderDetailCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
-(void)configureItemDetail:(NSDictionary *)dictItem withItem:(Item *)anItem{
    
    NSDictionary *itemDict = anItem.itemDictionary;
    
    self.itemName.text = dictItem[@"ItemName"];
    self.itemBarcode.text = dictItem[@"Barcode"];
    
    [self setSingleCasePackQTYWithItem:anItem withItemData:itemDict];
    
}
- (Item*)fetchAllItems :(NSString *)itemId
{
    RmsDbController * rmsDbController = [RmsDbController sharedRmsDbController];
    Item *item=nil;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Item" inManagedObjectContext:rmsDbController.managedObjectContext];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"itemCode==%d", itemId.integerValue];
    fetchRequest.predicate = predicate;
    
    // NSError *error;
    NSArray *resultSet = [UpdateManager executeForContext:rmsDbController.managedObjectContext FetchRequest:fetchRequest];
    if (resultSet.count>0)
    {
        item=resultSet.firstObject;
    }
    return item;
}

-(void)setSingleCasePackQTYWithItem:(Item *)item withItemData:(NSDictionary *)itemDictionary {
    
    self.QhSingle.text = [NSString stringWithFormat:@"%@",itemDictionary[@"availableQty"]];

    Item *anItem = [self fetchAllItems:item.itemCode.stringValue];
    NSMutableArray *itemPricingArray = [[NSMutableArray alloc]init];
    for (Item_Price_MD *pricing in anItem.itemToPriceMd)
    {
        NSMutableDictionary *pricingDict = [[NSMutableDictionary alloc]init];
        pricingDict[@"PriceQtyType"] = pricing.priceqtytype;
        pricingDict[@"Qty"] = pricing.qty;
        [itemPricingArray addObject:pricingDict];
    }
    
    NSPredicate *casePredicate = [NSPredicate predicateWithFormat:@"PriceQtyType = %@ AND Qty != 0" , @"Case"];
    NSArray *isCaseResult = [itemPricingArray filteredArrayUsingPredicate:casePredicate];
    NSString *caseValue;
    if(isCaseResult.count > 0)
    {
        NSString *caseQty  = [NSString stringWithFormat:@"%ld",(long)[[isCaseResult[0] valueForKey:@"Qty"] integerValue ]];
        float result = self.QhSingle.text.floatValue/caseQty.floatValue;
        NSString *cq = [self getValueBeforeDecimal:result];
        NSInteger y = self.QhSingle.text.integerValue % caseQty.integerValue;
        y = labs(y);
        caseValue = [NSString stringWithFormat:@"%@.%ld",cq,(long)y];
    }
    else
    {
        caseValue = @"-";
    }
    
    NSPredicate *packPredicate = [NSPredicate predicateWithFormat:@"PriceQtyType = %@ AND Qty != 0" , @"Pack"];
    NSArray *ispackResult = [itemPricingArray filteredArrayUsingPredicate:packPredicate];
    NSString *packValue;
    if(ispackResult.count > 0)
    {
        NSString *caseQty  = [NSString stringWithFormat:@"%ld",(long)[[ispackResult[0] valueForKey:@"Qty"] integerValue ]];
        float result = self.QhSingle.text.floatValue/caseQty.floatValue;
        NSString *pq = [self getValueBeforeDecimal:result];
        NSInteger x = self.QhSingle.text.integerValue % caseQty.integerValue;
        x = labs(x);
        packValue = [NSString stringWithFormat:@"%@.%ld",pq,(long)x];
    }
    else
    {
        packValue = @"-";
    }
    
    if(([caseValue isEqualToString:@"-"]) && ([packValue isEqualToString:@"-"]))
    {
        self.QhCashPack.text = @"";
    }
    else if ([packValue isEqualToString:@"-"]) // Pack value not available
    {
        self.QhCashPack.text = [NSString stringWithFormat:@"%@ / -",caseValue];
    }
    else if ([caseValue isEqualToString:@"-"]) // Case value not available
    {
        self.QhCashPack.text = [NSString stringWithFormat:@"- / %@",packValue];
    }
    else
    {
        self.QhCashPack.text = [NSString stringWithFormat:@"%@ / %@",caseValue , packValue];
    }
    
}

- (NSString *)getValueBeforeDecimal:(float)result
{
    NSNumber *numberValue = @(result);
    NSString *floatString = numberValue.stringValue;
    NSArray *floatStringComps = [floatString componentsSeparatedByString:@"."];
    NSString *cq = [NSString stringWithFormat:@"%@",floatStringComps.firstObject];
    return cq;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
