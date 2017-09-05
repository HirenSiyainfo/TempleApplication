//
//  InventoryCell.m
//  I-RMS
//
//  Created by Siya Infotech on 09/08/13.
//  Copyright (c) 2013 Siya Infotech. All rights reserved.
//

#import "InventoryCell.h"
#import "RmsDbController.h"


//CoreData
#import "Item+Dictionary.h"
#import "Item_Price_MD+Dictionary.h"
#import "Item_Discount_MD2+Dictionary.h"
#import "Item_Discount_MD+Dictionary.h"

@interface InventoryCell ()


@end

@implementation InventoryCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

//- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
//    [super setSelected:selected animated:animated];
//    
////    UIView * selectedBackgroundView = [[UIView alloc] init];
////    selectedBackgroundView.backgroundColor = [UIColor colorWithRed:0.667 green:0.667 blue:1.000 alpha:1.000];
////    [self setSelectedBackgroundView:selectedBackgroundView];
//}

//- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
//    [super setSelected:selected animated:animated];
//    self.viewSeparetor.backgroundColor = [UIColor redColor];
//}

- (void)resizeLabel:(UILabel *)label
{
    CGSize constraintSize = label.frame.size;
    constraintSize.height = 200;
    CGRect textRect = [label.text boundingRectWithSize:constraintSize
                                                          options:NSStringDrawingUsesLineFragmentOrigin
                                                       attributes:@{NSFontAttributeName:label.font}
                                                          context:nil];
    CGSize size = textRect.size;
    CGRect lblNameFrame = label.frame;
    lblNameFrame.size.height = size.height;
    label.frame = lblNameFrame;
}

-(void)configureCellWithItem:(Item *) anItem withBarCode:(NSString *) itemBarCode withCurrentIndexPath:(NSIndexPath *) indexPath withIsBarcodeExist:(BOOL)isBarcodeExist isLablePrintSelectOr:(BOOL) isLablePrintSelect isSelectedIndex:(BOOL) isSelectedIndex {
    RmsDbController * rmsDbController = [RmsDbController sharedRmsDbController];
    NSDictionary * itemDictionary = anItem.itemRMSDictionary;
    
    self.indexPath=indexPath;

    self.txtPrice.textColor = [UIColor blackColor];
    self.selectionStyle = UITableViewCellSelectionStyleDefault;
    
    NSString *itemImageURL = itemDictionary[@"ItemImage"];

    NSString *imgString = @"noimage.png";
    [self.itemImage cancelDownloadTask];
    self.itemImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@", imgString]];
    
    if ([[itemImageURL stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""])
    {
        NSString *imgString = @"noimage.png";
        self.itemImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@", imgString]];
    }
    else if ([[itemImageURL stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@"<null>"])
    {
        NSString *imgString = @"noimage.png";
        self.itemImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@", imgString]];
    }
    else
    {
        [self.itemImage loadImageFromURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",itemImageURL]]];
    }
   
    self.lblInventoryName.text = itemDictionary[@"ItemName"];

    self.lblBarcode.text = itemDictionary[@"Barcode"];
    self.lblItemNumber.text = itemDictionary[@"ItemNo"];

    self.txtCost.text = [NSString stringWithFormat:@"%@",[rmsDbController getStringPriceFromFloat:[itemDictionary[@"CostPrice"] floatValue]]];
    
    self.txtPrice.text = [NSString stringWithFormat:@"%@",[rmsDbController getStringPriceFromFloat:[itemDictionary[@"SalesPrice"] floatValue]]];
    self.imgIsDiscount.image = nil;
    
    self.qtyBackgroundImage.image=[UIImage imageNamed:@"globalblue.png"];
    self.txtQty.text = [NSString stringWithFormat:@"%@",itemDictionary[@"avaibleQty"]];
    
    [self setDiscountedPriceWithItem:anItem withItemData:itemDictionary];
    [self setSingleCasePackQTYWithItem:anItem withItemData:itemDictionary];

    UIView * bg = [[UIView alloc] init];
    bg.backgroundColor = [UIColor whiteColor];
    self.backgroundView = bg;
    
    UIView * selectedBackgroundView = [[UIView alloc] init];
    selectedBackgroundView.backgroundColor = [UIColor colorWithWhite:0.933 alpha:1.000];
    self.selectedBackgroundView = selectedBackgroundView;
}
-(void)setDiscountedPriceWithItem:(Item *) anItem withItemData:(NSDictionary *)itemDictionary {
    
    RmsDbController * rmsDbController = [RmsDbController sharedRmsDbController];
    if (anItem.primaryItemDetail.count > 0 && anItem.primaryItemDetail != nil) {
        self.imgIsDiscount.image = [UIImage imageNamed:@"RIM_Item_Discount_cell"];

    }
    NSMutableArray * itemDiscArray = [[NSMutableArray alloc]init];
    for (Item_Discount_MD *idiscMd in anItem.itemToDisMd )
    {
        [itemDiscArray addObjectsFromArray:idiscMd.mdTomd2.allObjects];
    }
    Item_Discount_MD2 *idiscMd2=nil;
    
    if(itemDiscArray.count > 0)
    {
        for (int idisc=0; idisc < itemDiscArray.count; idisc++)
        {
            idiscMd2 = itemDiscArray[idisc];
            NSInteger iDiscqty = idiscMd2.md2Tomd.dis_Qty.integerValue;
            if(idiscMd2.dayId.integerValue == -1 && iDiscqty == 1)
            {
                NSNumber *sPrice = @(idiscMd2.md2Tomd.dis_UnitPrice.floatValue);
                self.txtPrice.text = [NSString stringWithFormat:@"%@",[rmsDbController getStringPriceFromFloat:idiscMd2.md2Tomd.dis_UnitPrice.floatValue]];
                
                NSString *iCostPrice = [NSString stringWithFormat:@"%.2f",[itemDictionary[@"CostPrice"] floatValue]];
                float CostPrice = iCostPrice.floatValue;
                float SPrice = sPrice.floatValue;
                
                if(CostPrice > SPrice)
                {
                    self.txtPrice.textColor = [UIColor redColor];
                }
                self.imgIsDiscount.image = [UIImage imageNamed:@"RIM_Item_Discount_cell"];
            }
            else if(idiscMd2.dayId.integerValue >= -1 && idiscMd2.dayId.integerValue <= 7)
            {
                self.txtPrice.text = [NSString stringWithFormat:@"%@",[rmsDbController getStringPriceFromFloat:[itemDictionary[@"SalesPrice"] floatValue]]];
                
                NSString *iCostPrice = [NSString stringWithFormat:@"%.2f",[itemDictionary[@"CostPrice"] floatValue]];
                NSNumber *sPrice = @(idiscMd2.md2Tomd.dis_UnitPrice.floatValue);
                float CostPrice = iCostPrice.floatValue;
                float SPrice = sPrice.floatValue;
                
                if(CostPrice > SPrice)
                {
                    self.txtPrice.textColor = [UIColor redColor];
                }
                self.imgIsDiscount.image = [UIImage imageNamed:@"RIM_Item_Discount_cell"];
            }
        }
    }
    else
    {
        NSString *iCostPrice = [NSString stringWithFormat:@"%.2f",[itemDictionary[@"CostPrice"] floatValue]];
        NSString *isalesPrice = [NSString stringWithFormat:@"%.2f",[itemDictionary[@"SalesPrice"] floatValue]];
        float CostPrice = iCostPrice.floatValue;
        float SPrice = isalesPrice.floatValue;
        if (CostPrice > SPrice)
        {
            self.txtPrice.textColor = [UIColor redColor];
        }
    }
}
-(void)setSingleCasePackQTYWithItem:(Item *) anItem withItemData:(NSDictionary *)itemDictionary {
    NSInteger minLevel = [itemDictionary[@"MinStockLevel"] integerValue];
    NSInteger availableQty = [itemDictionary[@"avaibleQty"] integerValue];
    NSString *itemCode = itemDictionary[@"ItemId"];
    
    if (minLevel >= 0)
    {
        if (availableQty <= minLevel)
        {
            self.qtyBackgroundImage.image=[UIImage imageNamed:@"globalred.png"];
        }
    }
    
    if(availableQty != 0)
    {
        Item *anItem = [self fetchAllItems:itemCode];
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
            float result = self.txtQty.text.floatValue/caseQty.floatValue;
            NSString *cq = [self getValueBeforeDecimal:result];
            NSInteger y = self.txtQty.text.integerValue % caseQty.integerValue;
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
            float result = self.txtQty.text.floatValue/caseQty.floatValue;
            NSString *pq = [self getValueBeforeDecimal:result];
            NSInteger x = self.txtQty.text.integerValue % caseQty.integerValue;
            x = labs(x);
            packValue = [NSString stringWithFormat:@"%@.%ld",pq,(long)x];
        }
        else
        {
            packValue = @"-";
        }
        
        if(([caseValue isEqualToString:@"-"]) && ([packValue isEqualToString:@"-"]))
        {
            self.txtCasePackValue.text = @"";
        }
        else if ([packValue isEqualToString:@"-"]) // Pack value not available
        {
            self.txtCasePackValue.text = [NSString stringWithFormat:@"%@ / -",caseValue];
        }
        else if ([caseValue isEqualToString:@"-"]) // Case value not available
        {
            self.txtCasePackValue.text = [NSString stringWithFormat:@"- / %@",packValue];
        }
        else
        {
            self.txtCasePackValue.text = [NSString stringWithFormat:@"%@ / %@",caseValue , packValue];
        }
    }
    else
    {
        self.txtCasePackValue.text = @"";
    }
    
    if ([[itemDictionary valueForKey:@"quantityManagementEnabled"] boolValue] == TRUE)
    {
        self.txtQty.text = @"";
        self.txtCasePackValue.text = @"";
        self.qtyBackgroundImage.image = nil;
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

- (Item*)fetchAllItems :(NSString *)itemId{
    RmsDbController * rmsDbController = [RmsDbController sharedRmsDbController];
    Item *item=nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Item" inManagedObjectContext:rmsDbController.managedObjectContext];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"itemCode==%d", itemId.integerValue];
    fetchRequest.predicate = predicate;
    
    NSArray *resultSet = [UpdateManager executeForContext:rmsDbController.managedObjectContext FetchRequest:fetchRequest];
    if (resultSet.count>0)
    {
        item=resultSet.firstObject;
    }
    return item;
}
#pragma mark - IBAction -
-(IBAction)ActiveInactiveOfItem:(UIButton *)sender{
    [self.inventoryCellDelegate ActiveInactiveItemAtIndexPath:self.indexPath sender:sender];
}
-(IBAction)HistoryOfItem:(UIButton *)sender{
    [self.inventoryCellDelegate historyItemAtIndexPath:self.indexPath sender:sender];
}
-(IBAction)copyItem:(UIButton *)sender{
    [self.inventoryCellDelegate copyItemAtIndexPath:self.indexPath sender:sender];
}

-(IBAction)deleteItem:(UIButton *)sender{
    [self.inventoryCellDelegate deleteItemAtIndexPath:self.indexPath sender:sender];
}

-(IBAction)singleItemClicked:(UIButton *)sender{
    [self.inventoryCellDelegate singleItemClickedAtIndexPath:self.indexPath sender:sender];
}

-(IBAction)caseClicked:(UIButton *)sender{
    [self.inventoryCellDelegate caseClickedAtIndexPath:self.indexPath sender:sender];
}

-(IBAction)packClicked:(UIButton *)sender{
    [self.inventoryCellDelegate packClickedAtIndexPath:self.indexPath sender:sender];
}
@end
