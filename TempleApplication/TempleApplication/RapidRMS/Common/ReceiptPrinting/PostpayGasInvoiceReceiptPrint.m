//
//  PostpayGasInvoiceReceiptPrint.m
//  RapidRMS
//
//  Created by Siya10 on 29/06/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "PostpayGasInvoiceReceiptPrint.h"


@implementation PostpayGasInvoiceReceiptPrint

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
    
//    FuelType  *fuelType = [[super fetchFuelDetails:@"FuelType" withPumpIndex:[pumpCart[@"FuelId"] intValue] withMoc:rmsDbController.rapidPetroPos.petroMOC]firstObject];
//    NSString *fuelName = @"-";
//    if(fuelType){
//        fuelName = [fuelType getFuelTypeDictionary][@"FuelTypeDescription"];
//    }
//    
//    [printJob printText1:@"" text2:@"FuelType" text3:fuelName];
}
-(void)printFuelPrice:(NSDictionary *)pumpCart{
    
    
    NSNumberFormatter *fuelPriceFormatter = [[NSNumberFormatter alloc] init];
    fuelPriceFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
    fuelPriceFormatter.minimumFractionDigits = 3;
    
    // FulePrice
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
    
    [printJob printText1:@"" text2:@"FinalVolume" text3:[NSString stringWithFormat:@"%@", pumpCart[@"Volume"]]];
}
-(void)printRefund:(NSDictionary *)pumpCart{
    
    // Refund
    if([pumpCart[@"TransactionType"] isEqualToString:@"PRE-PAY"]){
        
        float refund = [pumpCart[@"AmountLimit"]floatValue] - [pumpCart[@"Amount"]floatValue];
        
        if(refund > 0.00){
            [printJob printText1:@"" text2:@"Refund" text3:[super currencyFormattedStringForAmount:refund]];
        }
    }
    
}
-(void)printFinalAmount:(NSDictionary *)pumpCart{
    
    // Final Amount
    
    [printJob printText1:@"" text2:@"Final Amount" text3:[super currencyFormattedStringForAmount:[pumpCart[@"Amount"] floatValue]]];
    
    
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

@end
