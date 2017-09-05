//
//  RapidMultipleBarcodeRingUpHelper.m
//  RapidRMS
//
//  Created by siya8 on 05/11/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "RapidMultipleBarcodeRingUpHelper.h"
#import "Item_Price_MD.h"
#import "Item_Price_MD+Dictionary.h"
#import "Item+Dictionary.h"
#import "UpdateManager.h"

@implementation RapidMultipleBarcodeRingUpHelper
{
    NSMutableArray *priceMdForBarcodes;
    NSMutableArray *itemForBarcodeArray;
    NSInteger currentBarcodeItemIndex;
    NSString *itemBarcode;

}

-(NSMutableArray *)rigupProcessForItemBarcode:(NSArray *)itemsBarcode withItemBarcode:(NSString *)barcode
{
    itemBarcode = barcode;
    [self performNextForItembarcodeProcess:itemsBarcode];

    return priceMdForBarcodes;

}
- (void)performNextForItembarcodeProcess:(NSArray *)itemsForBarcode
{
    currentBarcodeItemIndex = 0;
    priceMdForBarcodes = [[NSMutableArray alloc]init];
    [itemForBarcodeArray removeAllObjects];
    itemForBarcodeArray = [itemsForBarcode mutableCopy];
    [self nextProcessForBarcode];
}

- (void)nextProcessForBarcode
{
    if (currentBarcodeItemIndex >= itemForBarcodeArray.count ) {
        return;
    }
    BOOL isCasePackAllow = FALSE;
    
    Item *currentItem = itemForBarcodeArray[currentBarcodeItemIndex];
    
    NSArray *itemToPriceSortedArray = [self sortArrayForBarcodeRingUpProcess:currentItem];
    
    for (Item_Price_MD *price_md in itemToPriceSortedArray)
    {
        if ([price_md.priceqtytype isEqualToString:@"Case"])
        {
            if([currentItem.pricescale isEqualToString:@"WSCALE"] && currentItem.isPriceAtPOS.boolValue == TRUE)
            {
                continue;
            }
            
            if (price_md.isPackCaseAllow.boolValue == TRUE || [self numberOfBarcode_MD_ForBarcode:currentItem withItemBarcode:itemBarcode WithItemPriceType:price_md.priceqtytype].count > 0)
            {
                if (isCasePackAllow == FALSE)
                {
                    isCasePackAllow = price_md.isPackCaseAllow.boolValue;
                }
                [priceMdForBarcodes addObject:price_md];
            }
        }
        else  if ([price_md.priceqtytype isEqualToString:@"Single item"] || [price_md.priceqtytype isEqualToString:@"Single Item"])
        {
            if([self numberOfBarcode_MD_ForSingleItemBarcode:currentItem withItemBarcode:itemBarcode WithItemPriceType:price_md.priceqtytype].count > 0 || isCasePackAllow == TRUE )
            {
                [priceMdForBarcodes addObject:price_md];
            }
        }
        else if ([price_md.priceqtytype isEqualToString:@"Pack"] )
        {
            if([currentItem.pricescale isEqualToString:@"WSCALE"] && currentItem.isPriceAtPOS.boolValue == TRUE)
            {
                continue;
            }
            
            
            if (price_md.isPackCaseAllow.boolValue == TRUE ||  [self numberOfBarcode_MD_ForBarcode:currentItem withItemBarcode:itemBarcode WithItemPriceType:price_md.priceqtytype].count > 0)
            {
                if (isCasePackAllow == FALSE)
                {
                    isCasePackAllow = price_md.isPackCaseAllow.boolValue;
                }
                [priceMdForBarcodes addObject:price_md];
            }
        }
    }
    
    currentBarcodeItemIndex ++;
    [self nextProcessForBarcode];
}
-(NSArray *)numberOfBarcode_MD_ForBarcode :(Item *)item withItemBarcode:(NSString *)barcode WithItemPriceType:(NSString *)priceType
{
    NSArray * array = item.itemBarcodes.allObjects;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"barCode like[cd] %@ AND packageType == %@",barcode,priceType];
    return  [array filteredArrayUsingPredicate:predicate];
}
-(NSArray *)numberOfBarcode_MD_ForSingleItemBarcode :(Item *)item withItemBarcode:(NSString *)barcode WithItemPriceType:(NSString *)priceType
{
    NSArray * array = item.itemBarcodes.allObjects;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"barCode like[cd] %@ AND (packageType == %@ OR packageType == %@)",barcode,@"Single item",@"Single Item"];
    return  [array filteredArrayUsingPredicate:predicate];
}


- (NSArray *)sortArrayForBarcodeRingUpProcess:(Item *)currentItem
{
    NSArray * itemToPriceArray = currentItem.itemToPriceMd.allObjects;
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"priceqtytype"
                                                                   ascending:YES ];
    NSArray *sortDescriptors = [@[sortDescriptor]mutableCopy];
    NSArray *itemToPriceSortedArray = [itemToPriceArray sortedArrayUsingDescriptors:sortDescriptors];
    return itemToPriceSortedArray;
}


@end
