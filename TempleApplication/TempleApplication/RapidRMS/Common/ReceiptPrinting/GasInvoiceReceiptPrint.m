//
//  GasInvoiceReceiptPrint.m
//  RapidRMS
//
//  Created by Siya10 on 29/06/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "GasInvoiceReceiptPrint.h"

@implementation GasInvoiceReceiptPrint
@synthesize arrPumpCartArray;

-(NSString *)htmlForItemDictionary:(NSDictionary *)billEntry{
    
    NSString *itemHtml = @"";
    if([billEntry[@"Barcode"] isEqualToString:@"GAS"]){
        itemHtml = [itemHtml stringByAppendingString:[self htmlForGasItemDictionary:billEntry]];
         if(gasDetail.length > 0){
             [super htmlForItemDictionary:billEntry];
             gasDetail = @"";
         }
    }
    else{
        itemHtml = [itemHtml stringByAppendingString:[super htmlForItemDictionary:billEntry]];
 
    }
    return itemHtml;
}

- (NSString *)htmlForGasItemDictionary:(NSDictionary *)billEntry
{
    NSString *itemHtml = @"";
    // set Item Detail with only 1 qty....
    
    if([billEntry[@"Barcode"]isEqualToString:@"GAS"]){
        gasDetail = [self htmlGasInfo:billEntry];
        if(gasDetail.length > 0){
            itemHtml = [itemHtml stringByAppendingString:gasDetail];
        }
        else{
            itemHtml = [itemHtml stringByAppendingString:[super htmlForItemDictionary:billEntry]];
        }
    }
    
    return itemHtml;
}
#pragma mark Html Method
-(NSString *)htmlGasInfo:(NSDictionary *)itemDictionary
{
    NSString *htmldata = @"";
    
    NSPredicate *predicateBlankTrn = [NSPredicate predicateWithFormat:@"TransactionType.length > 0"];
    self.arrPumpCartArray = [[self.arrPumpCartArray filteredArrayUsingPredicate:predicateBlankTrn]mutableCopy];
    
    float itemCost = [itemDictionary[@"ItemAmount"] floatValue];
    NSPredicate *amountPredicate = [rmsDbController predicateForKey:@"Amount" floatValue:itemCost];
    
    NSPredicate *amountLimitPredicate = [rmsDbController predicateForKey:@"AmountLimit" floatValue:itemCost];
    
    NSPredicate *predicate = [NSCompoundPredicate orPredicateWithSubpredicates:@[amountPredicate,amountLimitPredicate]];
    
    NSMutableArray *arrPumpCart = [[self.arrPumpCartArray filteredArrayUsingPredicate:predicate] mutableCopy];
    if(arrPumpCart.count == 0){
        arrPumpCart = self.arrPumpCartArray;
    }
    if(arrPumpCart.count>0){
        
        NSMutableDictionary *rowPositionPumpCart = [arrPumpCart firstObject];
        [arrPumpCart removeAllObjects];
        [arrPumpCart addObject:rowPositionPumpCart];

        
        htmldata = [self generateHtmlForPumpCart:arrPumpCart withInitialPump:self.arrPumpCartArray withItemDictionary:itemDictionary];
    }
    return htmldata;
}

-(NSString *)generateHtmlForPumpCart:(NSMutableArray *)arrPumpCart withInitialPump:(NSMutableArray *)initialPumpCartArray withItemDictionary:(NSDictionary *)itemDictionary{
    
    NSString *htmldata = @"";
    
    for (NSDictionary *pumpCart in arrPumpCart) {
        
        htmldata = [htmldata stringByAppendingString:[self htmlForTransactionType:pumpCart]];
        
        htmldata = [htmldata stringByAppendingString:[self htmlForPumpIndex:pumpCart]];
       
        //htmldata = [htmldata stringByAppendingString:[self htmlForServiceType:pumpCart]];
        
        if(pumpCart.allKeys.count > 3 && ([pumpCart[@"Amount"] floatValue] > 0 || [pumpCart[@"isPaid"] integerValue] == 1)){
            
            
            htmldata = [htmldata stringByAppendingString:[self htmlForFuelType:pumpCart]];

            htmldata = [htmldata stringByAppendingString:[self htmlForFuelPrice:[pumpCart mutableCopy]]];
            
            htmldata = [htmldata stringByAppendingString:[self htmlForFinalVolume:pumpCart]];
            
            if([pumpCart[@"IsPaid"] integerValue] == 1 || [pumpCart[@"isPaid"] integerValue] == 1){
                
                htmldata = [htmldata stringByAppendingString:[self htmlForRefund:pumpCart]];
            }
           
            htmldata = [htmldata stringByAppendingString:[self htmlForFinalAmount:pumpCart]];

        }
        [initialPumpCartArray removeObject:arrPumpCart.firstObject];
        
    }
    return htmldata;
}
#pragma mark Html Pump Cart Details
-(NSString *)htmlForTransactionType:(NSDictionary *)pumpCart{
    NSString *htmldata = @"";
    // TransactionType
    NSString *amountLimit = @"";
    if([pumpCart[@"TransactionType"] isEqualToString:@"PRE-PAY"]){
        amountLimit = pumpCart[@"AmountLimit"];
        htmldata = [htmldata stringByAppendingFormat:@"<tr><td valign=\"top\" style=\"word-break:break-all; padding-right:10px;\"><font size=\"2\">GAS</font></td><td align=\"left\" valign=\"top\" style=\"width:40%%; word-break:break-all;  padding-right:10px;\" ><font size=\"2\">%@</font> </td> <td align=\"right\" valign=\"top\"><font size=\"2\">%@</font></td></tr>",pumpCart[@"TransactionType"], [rmsDbController.currencyFormatter stringFromNumber:[NSNumber numberWithFloat:[amountLimit floatValue]]]];
    }
    else{
        
        NSString *transType = pumpCart[@"TransactionType"];
        if([transType isEqualToString:@"OUTSIDE-PAY"]){
            transType = @"PAY-AT-PUMP";
        }
        
        htmldata = [htmldata stringByAppendingFormat:@"<tr><td valign=\"top\" style=\"word-break:break-all; padding-right:10px;\"><font size=\"2\">GAS</font> </td><td align=\"left\" valign=\"top\" style=\"width:40%%; word-break:break-all;  padding-right:10px;\" ><font size=\"2\">%@</font> </td> <td align=\"right\" valign=\"top\"><font size=\"2\">%@</font></td></tr>",transType, @""];
    }
    return htmldata;
}
-(NSString *)htmlForPumpIndex:(NSDictionary *)pumpCart{
    
    NSString *htmldata = @"";
    // PumpIndex
    htmldata = [htmldata stringByAppendingFormat:@"<tr><td valign=\"top\" style=\"word-break:break-all; padding-right:10px;\"><font size=\"2\"></font> </td><td align=\"left\" valign=\"top\" style=\"width:40%%; word-break:break-all;  padding-right:10px;\" ><font size=\"2\">Pump</font> </td> <td align=\"right\" valign=\"top\"><font size=\"2\">%@</font></td></tr>", pumpCart[@"PumpId"]];
    return htmldata;
}
-(NSString *)htmlForServiceType:(NSDictionary *)pumpCart{
    
    NSString *htmldata = @"";
    // Service Type
    NSString *serviceType = @"Full";
    if(([pumpCart[@"TransactionType"] isEqualToString:@"OUTSIDE-PAY"])){
        serviceType = @"Self";
    }
    htmldata = [htmldata stringByAppendingFormat:@"<tr><td valign=\"top\" style=\"word-break:break-all; padding-right:10px;\"><font size=\"2\"></font> </td><td align=\"left\" valign=\"top\" style=\"width:40%%; word-break:break-all;  padding-right:10px;\" ><font size=\"2\">Service Type</font> </td> <td align=\"right\" valign=\"top\"><font size=\"2\">%@</font></td></tr>", serviceType];
    
    return htmldata;
}

-(NSString *)htmlForFuelType:(NSDictionary *)pumpCart{
    
    NSString *htmldata = @"";
    return htmldata;

}
-(NSString *)htmlForFuelPrice:(NSMutableDictionary *)pumpCart{
    
    NSString *htmldata = @"";
    NSNumberFormatter *fuelPriceFormatter = [[NSNumberFormatter alloc] init];
    fuelPriceFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
    fuelPriceFormatter.minimumFractionDigits = 3;
    
    if(pumpCart[@"pricePerGallon"]){
        pumpCart[@"PricePerGallon"] =  pumpCart[@"pricePerGallon"];
    }
    
    float fuelPrice = [pumpCart[@"PricePerGallon"]floatValue];
    if(fuelPrice == 0){
        
        fuelPrice = [pumpCart[@"Amount"] floatValue] / [pumpCart[@"Volume"] floatValue];
        if(isnan(fuelPrice) || (fuelPrice == INFINITY))
        {
            fuelPrice = 0;
        }
    }
    htmldata = [htmldata stringByAppendingFormat:@"<tr><td valign=\"top\" style=\"word-break:break-all; padding-right:10px;\"><font size=\"2\"></font> </td><td align=\"left\" valign=\"top\" style=\"width:40%%; word-break:break-all;  padding-right:10px;\" ><font size=\"2\">FuelPrice</font> </td> <td align=\"right\" valign=\"top\"><font size=\"2\">%@</font></td></tr>", [fuelPriceFormatter stringFromNumber:[NSNumber numberWithFloat:fuelPrice]]];
    
    return htmldata;
}
-(NSString *)htmlForFinalVolume:(NSDictionary *)pumpCart{
    
    NSString *htmldata = @"";
    htmldata = [htmldata stringByAppendingFormat:@"<tr><td valign=\"top\" style=\"word-break:break-all; padding-right:10px;\"><font size=\"2\"></font> </td><td align=\"left\" valign=\"top\" style=\"width:40%%; word-break:break-all;  padding-right:10px;\" ><font size=\"2\">FinalVolume</font> </td> <td align=\"right\" valign=\"top\"><font size=\"2\">%@</font></td></tr>", pumpCart[@"Volume"]];

    return htmldata;
}

-(NSString *)htmlForRefund:(NSDictionary *)pumpCart{
    
    NSString *htmldata = @"";
    if([pumpCart[@"TransactionType"] isEqualToString:@"PRE-PAY"]){
        
        float refund = [pumpCart[@"AmountLimit"]floatValue] - [pumpCart[@"Amount"]floatValue];
        if(refund > 0.00){
            
            htmldata = [htmldata stringByAppendingFormat:@"<tr><td valign=\"top\" style=\"word-break:break-all; padding-right:10px;\"><font size=\"2\"></font> </td><td align=\"left\" valign=\"top\" style=\"width:40%%; word-break:break-all;  padding-right:10px;\" ><font size=\"2\">Refund</font> </td> <td align=\"right\" valign=\"top\"><font size=\"2\">%@</font></td></tr>", [rmsDbController.currencyFormatter stringFromNumber:[NSNumber numberWithFloat:refund]]];

        }
    }
    return htmldata;
}
-(NSString *)htmlForFinalAmount:(NSDictionary *)pumpCart{
    
    NSString *htmldata = @"";
    htmldata = [htmldata stringByAppendingFormat:@"<tr><td valign=\"top\" style=\"word-break:break-all; padding-right:10px;\"><font size=\"2\"></font> </td><td align=\"left\" valign=\"top\" style=\"width:40%%; word-break:break-all;  padding-right:10px;\" ><font size=\"2\">Final Amount</font> </td> <td align=\"right\" valign=\"top\"><font size=\"2\">%@</font></td></tr>",[rmsDbController.currencyFormatter stringFromNumber:[NSNumber numberWithFloat:[pumpCart[@"Amount"] floatValue]]]];
    return htmldata;
}

- (void)printItemDetailWithDictionary:(NSDictionary *)receiptDictionary {
    [self printGasDetails:receiptDictionary];
    [super printItemDetailWithDictionary:receiptDictionary];
    
}
-(BOOL)printGasDetails:(NSDictionary*)receiptDictionary
{
    gasDetailAvailable = NO;
    if([receiptDictionary[@"Barcode"]isEqualToString:@"GAS"]){
        
        NSPredicate *predicateBlankTrn = [NSPredicate predicateWithFormat:@"TransactionType.length > 0"];
        self.arrPumpCartArray = [[self.arrPumpCartArray filteredArrayUsingPredicate:predicateBlankTrn]mutableCopy];
    
        float ItemAmount = [receiptDictionary[@"ItemAmount"] floatValue];
        
        NSPredicate *amountPredicate = [rmsDbController predicateForKey:@"Amount" floatValue:ItemAmount];
        
        NSPredicate *amountLimitPredicate = [rmsDbController predicateForKey:@"AmountLimit" floatValue:ItemAmount];
        
        NSPredicate *predicate = [NSCompoundPredicate orPredicateWithSubpredicates:@[amountPredicate,amountLimitPredicate]];
       
        NSMutableArray *arrPumpCart = [[self.arrPumpCartArray filteredArrayUsingPredicate:predicate] mutableCopy];
        if(arrPumpCart.count == 0){
            arrPumpCart = self.arrPumpCartArray;
        }
        if(arrPumpCart.count > 0){
            
            NSMutableDictionary *rowPositionPumpCart = [arrPumpCart firstObject];
            [arrPumpCart removeAllObjects];
            [arrPumpCart addObject:rowPositionPumpCart];
            
            gasDetailAvailable = YES;
            for (NSDictionary *pumpCart in arrPumpCart) {
                
                [super defaultFormatForItemDetail];
                
                [self printTransactionType:pumpCart];

                [self printPumpNumber:pumpCart];
                
                //[self printServiceType:pumpCart];
                
                if(pumpCart.allKeys.count > 3 && [pumpCart[@"Amount"] floatValue] > 0){
                   
                    [self printFuelType:pumpCart];
                    
                    [self printFuelPrice:[pumpCart mutableCopy]];
                    
                    [self printFinalVolume:pumpCart];
                
                    if([pumpCart[@"IsPaid"] integerValue] == 1 || [pumpCart[@"isPaid"] integerValue] == 1){
                      
                        [self printRefund:pumpCart];

                    }
                    [self printFinalAmount:pumpCart];
                }
                [self.arrPumpCartArray removeObject:arrPumpCart.firstObject];

            }
        }
    }
    return gasDetailAvailable;
}
-(void)printTransactionType:(NSDictionary *)pumpCart{
    // TransactionType
    NSString *amountLimit = @"";
    if([pumpCart[@"TransactionType"] isEqualToString:@"PRE-PAY"]){
        amountLimit = pumpCart[@"AmountLimit"];
        [printJob printText1:@"GAS" text2:[NSString stringWithFormat:@"%@",pumpCart[@"TransactionType"]] text3:[self currencyFormattedStringForAmount:amountLimit.floatValue]];
    }
    else{
        NSString *transType = pumpCart[@"TransactionType"];
        if([transType isEqualToString:@"OUTSIDE-PAY"]){
            transType = @"PAY-AT-PUMP";
        }

        [printJob printText1:@"GAS" text2:[NSString stringWithFormat:@"%@",transType] text3:@""];
    }
    
}
-(void)printPumpNumber:(NSDictionary *)pumpCart{
     [printJob printText1:@"" text2:@"Pump" text3:[NSString stringWithFormat:@"%@", pumpCart[@"PumpId"]]];
}


-(void)printFuelType:(NSDictionary *)pumpCart{
    
    // FuelType
    
    NSString *fuelName = @"-";
    
    [printJob printText1:@"" text2:@"FuelType" text3:fuelName];
}
-(void)printFuelPrice:(NSMutableDictionary *)pumpCart{
    
    // FulePrice
    NSNumberFormatter *fuelPriceFormatter = [[NSNumberFormatter alloc] init];
    fuelPriceFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
    fuelPriceFormatter.minimumFractionDigits = 3;
    
    if(pumpCart[@"pricePerGallon"])
    {
        pumpCart[@"PricePerGallon"] = pumpCart[@"pricePerGallon"];
    }
    
    float fuelPrice = [pumpCart[@"PricePerGallon"]floatValue];
    if(fuelPrice == 0){
        
        fuelPrice = [pumpCart[@"Amount"] floatValue] / [pumpCart[@"Volume"] floatValue];
        if(isnan(fuelPrice))
        {
            fuelPrice = 0;
        }
    }
    [printJob printText1:@"" text2:@"FuelPrice" text3:[fuelPriceFormatter stringFromNumber:@(fuelPrice)]];
}
-(void)printFinalVolume:(NSDictionary *)pumpCart{
    
    // Final Volume
    if(pumpCart[@"CartId"]){
        [printJob printText1:@"" text2:@"FinalVolume" text3:[NSString stringWithFormat:@"%@", pumpCart[@"Volume"]]];
    }
    
}
-(void)printRefund:(NSDictionary *)pumpCart{
   
    // Refund
    
    if(pumpCart[@"CartId"]){
        if([pumpCart[@"TransactionType"] isEqualToString:@"PRE-PAY"]){
            
            float refund = [pumpCart[@"AmountLimit"]floatValue] - [pumpCart[@"Amount"]floatValue];
            
            if(refund > 0.00){
                 [printJob printText1:@"" text2:@"Refund" text3:[super currencyFormattedStringForAmount:refund]];
            }
        }
    }
}
-(void)printFinalAmount:(NSDictionary *)pumpCart{
    
    // Final Amount
    if(pumpCart[@"CartId"]){

        [printJob printText1:@"" text2:@"Final Amount" text3:[super currencyFormattedStringForAmount:[pumpCart[@"Amount"] floatValue]]];
    }

}
-(void)printServiceType:(NSDictionary *)pumpCart{
    
    // ServiceType
    if([pumpCart[@"TransactionType"] isEqualToString:@"OUTSIDE-PAY"]){
        
        [printJob printText1:@"" text2:@"Service Type" text3:@"Self"];
    }
    else{
        [printJob printText1:@"" text2:@"Service Type" text3:@"Full"];
    }
    
}


- (NSArray*)fetchFuelDetails:(NSString *)entityName withPumpIndex:(int)fuelIndex withMoc:(NsmoContext *)moc
{
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:moc];
    fetchRequest.entity = entity;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"fuelTypeIndex = %d",fuelIndex];
    fetchRequest.predicate = predicate;
    
    NSArray *arryTemp = [UpdateManager executeForContext:moc FetchRequest:fetchRequest];
    
    return arryTemp;
}

@end
