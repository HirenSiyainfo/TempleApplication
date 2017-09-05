//
//  PaxMagneticCardReceipt.m
//  RapidRMS
//
//  Created by siya-IOS5 on 10/23/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "PaxMagneticCardReceipt.h"
#import "PaxConstants.h"

@implementation PaxMagneticCardReceipt

-(void)addPrintLineForKey:(NSString *)key forDictionary:(NSDictionary *)creditcardInformationDictionary
{
    if (creditcardInformationDictionary[key] && [creditcardInformationDictionary[key] length] > 0) {
        [printJob printLine:[NSString stringWithFormat:@"%@: %@",key,creditcardInformationDictionary[key]]];
    }
}
-(void)addPrintLineForEntryMode:(NSString *)key forDictionary:(NSDictionary *)creditcardInformationDictionary
{
    if (creditcardInformationDictionary[key] && [creditcardInformationDictionary[key] length] > 0) {
        int enterMode = [creditcardInformationDictionary[key] intValue];
        [printJob printLine:[NSString stringWithFormat:@"%@: %@",key,[self getStringFromEnterMode:enterMode]]];
    }
}
-(NSString *)getStringFromEnterMode:(EntryMode) enterMode{
    switch (enterMode) {
        case Manual:
            return @"Manual";
            break;
        case Swipe:
            return @"Swipe";
            break;
        case Contactless:
            return @"Contactless";
            break;
        case Scanner:
            return @"Scanner";
            break;
        case Chip:
            return @"Chip";
            break;
        case ChipFallBackSwipe:
            return @"ChipFallBackSwipe";
            break;
            
        default:
            return @"";
            break;
    }
    
}

-(void)printCardDetails
{
    for(int i = 0;i<paymentDatailsArray.count;i++)
    {
        NSMutableDictionary *paymentDict = paymentDatailsArray[i];
        
        if([[paymentDict valueForKey:@"AuthCode"]length]>0 && [[paymentDict valueForKey:@"CardType"]length]>0 && [[paymentDict valueForKey:@"TransactionNo"]length]>0 && [[paymentDict valueForKey:@"AccNo"]length]>0)
        {
            [printJob setTextAlignment:TA_LEFT];
            NSString *strAccountNo = [NSString stringWithFormat:@"%@",[paymentDict valueForKey:@"AccNo"]];
            NSString *strBillAmount=[NSString stringWithFormat:@"%@",[paymentDict valueForKey:@"BillAmount"]];
            NSNumber *numAmount=@(strBillAmount.floatValue);
            NSString *tenderAmount =[self.crmController.currencyFormatter stringFromNumber:numAmount];
            [printJob printLine:@""];
            
            [printJob printLine:[NSString stringWithFormat:@"Card Holder Name: %@",[paymentDict valueForKey:@"CardHolderName"]]];
            [printJob printLine:[NSString stringWithFormat:@"Card Number: %@",strAccountNo]];
            
            if (![[paymentDict valueForKey:@"AuthCode"] isEqualToString:@"-"])
            {
                [printJob printLine:[NSString stringWithFormat:@"Auth Code: %@",[paymentDict valueForKey:@"AuthCode"]]];
            }

            [printJob printLine:[NSString stringWithFormat:@"Amount: %@",tenderAmount]];
            [printJob printLine:[NSString stringWithFormat:@"Exp Date: %@",[paymentDict valueForKey:@"ExpireDate"]]];
            
//            NSDictionary *creditcardAdditionalFieldDictionary = [paymentDict valueForKey:@"PaxAdditionalFields"];
            NSDictionary *creditcardAdditionalFieldDictionary = [self objectFromJsonString:[paymentDict valueForKey:@"GatewayResponse"]];

            [self addPrintLineForEntryMode:@"EntryMode" forDictionary:creditcardAdditionalFieldDictionary];

            
            CGFloat tipAmount = [[paymentDict valueForKey:@"TipsAmount"] floatValue];
            if(tipAmount>0){
                
                NSNumber *numTipAmount = [NSNumber numberWithFloat:tipAmount];
                NSString *tenderTipAmount =[self.crmController.currencyFormatter stringFromNumber:numTipAmount];
                [printJob printLine:[NSString stringWithFormat:@"Tip: %@",tenderTipAmount]];
                
                float totalAmount2 = strBillAmount.floatValue + tipAmount;
                [printJob enableBold:YES];
                NSNumber *numtotalAmount2 = @(totalAmount2);
                NSString *tenderTotalAmount2 =[self.crmController.currencyFormatter stringFromNumber:numtotalAmount2];
                [printJob printLine:[NSString stringWithFormat:@"Total: %@",tenderTotalAmount2]];
                [printJob enableBold:NO];
            }
            else
            {
                if([tipSettings isEqual: @(1)])
                {
                    [printJob printLine:@""];
                    [printJob printLine:@"Tip :_________________________"];
                    [printJob enableBold:YES];
                    [printJob printLine:@"Total :_________________________"];
                    [printJob printLine:@""];
                    [printJob enableBold:NO];
                    
                    for(int i=0;i<arrTipsPercent.count;i++) {
                        [printJob setTextAlignment:TA_CENTER];
                        NSMutableDictionary *dicTips = arrTipsPercent[i];
                        NSString *strTipsPercentage = [NSString stringWithFormat:@"%@%%",[dicTips valueForKey:@"TipsPercentage"]];
                        NSNumber *tipsAmountNum = @([[dicTips valueForKey:@"TipsAmount"] floatValue]);
                        NSString *strTipsAmount =[self.crmController.currencyFormatter stringFromNumber:tipsAmountNum];
                        [self defaultFormatForTipsDetails];
                        [printJob printText1:strTipsPercentage text2:@"" text3:strTipsAmount];
                    }
                }
            }
        }
    }
    [printJob printSeparator];
}
-(id)objectFromJsonString:(NSString *)jsonString {
    NSError *error;
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    if (! jsonData) {
        return nil;
    }
    return [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves error:&error];
}

-(void)printHeaderForReceiptSectionCardDetail {
    [printJob printSeparator];
    NSMutableDictionary *paymentDict = paymentDatailsArray.firstObject;
    [printJob setTextAlignment:TA_CENTER];
    NSDictionary *creditcardAdditionalFieldDictionary = [self objectFromJsonString:[paymentDict valueForKey:@"GatewayResponse"]];

    if (self.isVoidCardReceipt == TRUE) {
        [printJob printLine:[NSString stringWithFormat:@"%@",@"Void"]];
    }
    else
    {
        [printJob printLine:[NSString stringWithFormat:@"%@",[creditcardAdditionalFieldDictionary valueForKey:@"TransactionType"]]];
    }}
- (void)defaultFormatForTipsDetails
{
    columnWidths[0] = 23;
    columnWidths[1] = 0;
    columnWidths[2] = 23;
    columnAlignments[0] = CRAlignmentRight;
    columnAlignments[1] = CRAlignmentLeft;
    columnAlignments[2] = CRAlignmentLeft;
    [printJob setColumnWidths:columnWidths columnAlignments:columnAlignments];
}


@end
