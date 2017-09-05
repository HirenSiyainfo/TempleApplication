//
//  LocalTotalReportResponse.m
//  PaxControllerApp
//
//  Created by siya-IOS5 on 9/18/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "LocalTotalReportResponse.h"
#import "PaxResponse+Internal.h"

typedef NS_ENUM(NSInteger, LocalTotalReportDetailParsingIndexs) {
    LocalTotalReportCredit,
    LocalTotalReportDebit,
    LocalTotalReportEBT,
    LocalTotalReportGift,
    LocalTotalReportLOYALTY,
    LocalTotalReportCASH,
    LocalTotalReportCHECK,
};

@implementation LocalTotalReportResponse
- (void)setupMessageFormat {
    responseMessageFields = @[
                              @(FieldIndexMultiPacket),
                              @(FieldIndexCommandType),
                              @(FieldIndexVersion),
                              @(FieldIndexResponseCode),
                              @(FieldIndexResponseMessage),
                              @(FieldIndexLocalTotalReportEDCType),
                              @(FieldIndexLocalTotalReportTotalData),
                              ];
}

- (void)parseFieldData:(NSData *)fieldData forFieldId:(FieldIndex)fieldId {
    switch (fieldId) {
        case FieldIndexLocalTotalReportEDCType:
            [self parseEDCType:fieldData];
            break;
        case FieldIndexLocalTotalReportTotalData:
            [self parseLocalTotalReportTotalData:fieldData];
            break;
              default:
            [super parseFieldData:fieldData forFieldId:fieldId];
            break;
    }
}
-(void)parseEDCType:(NSData *)data
{
    NSInteger length = 2;
     self.edcType = [PaxResponse ansStringFrom:0 maxLength:length data:data];
}
- (NSArray *)fieldDetailAtIndex:(LocalTotalReportDetailParsingIndexs)localTotalReportDetailParsingIndex
{
    NSArray *fieldsArray;
    
    switch (localTotalReportDetailParsingIndex) {
        case LocalTotalReportCredit:
            fieldsArray = [self creditFieldArray];
            break;
        case LocalTotalReportDebit:
            fieldsArray = [self debitFieldArray];
            break;
        case LocalTotalReportEBT:
             fieldsArray = [self ebtFieldArray];
            break;
        case LocalTotalReportGift:
             fieldsArray = [self giftFieldArray];
            break;
        case LocalTotalReportLOYALTY:
             fieldsArray = [self loyaltyFieldArray];
            break;
        case LocalTotalReportCASH:
              fieldsArray = [self cashFieldArray];
            break;
        case LocalTotalReportCHECK:
              fieldsArray = [self checkFieldArray];
            break;
            
        default:
            break;
    }
    return fieldsArray;
}

-(void)parseLocalTotalReportTotalData:(NSData *)data
{
    NSString *totalLocalReportDetail = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    
    NSArray *totalLocalReportDetails = [totalLocalReportDetail componentsSeparatedByString:@"&"];
    
    LocalTotalReportDetailParsingIndexs localTotalReportDetailParsingIndexs = LocalTotalReportCredit;
    
    self.totalLocalReportDetailArray = [[NSMutableArray alloc] init];
    
    NSMutableArray *arrAmount = [NSMutableArray arrayWithObjects:@"SaleAmount" , @"forcedAmount" , @"returnAmount" , @"authAmount" , @"postauthAmount",nil];
    
    
    for (NSString *totalLocalReportDetailString in totalLocalReportDetails) {
        NSArray *fieldsArray = [self fieldDetailAtIndex:localTotalReportDetailParsingIndexs];
        NSArray *totalLocalReportDetailArray = [totalLocalReportDetailString componentsSeparatedByString:@"="];
        NSMutableDictionary *localReportDictionary = [[NSMutableDictionary alloc] init];
        for (int i =0 ; i < totalLocalReportDetailArray.count; i++) {
            NSNumber *number  = [NSNumber numberWithInt: [totalLocalReportDetailArray[i] floatValue]];
            if ([arrAmount containsObject:fieldsArray[i]]) {
                number = @(number.floatValue / 100);
            }
            localReportDictionary[fieldsArray[i]] = number;
        }
        [self.totalLocalReportDetailArray addObject:localReportDictionary];
        localTotalReportDetailParsingIndexs++;
    }
}
-(NSArray *)creditFieldArray
{
    return  @[@"saleCount",
             @"SaleAmount",
             @"forcedCount",
             @"forcedAmount",
             @"returnCount",
             @"returnAmount",
             @"authCount",
             @"authAmount",
             @"postauthCount",
             @"postauthAmount"];
}
-(NSArray *)debitFieldArray
{
    return  @[@"saleCount",
             @"SaleAmount",
             @"returnCount",
             @"returnAmount"];
}
-(NSArray *)ebtFieldArray
{
    return  @[@"saleCount",
             @"SaleAmount",
             @"returnCount",
             @"returnAmount",
             @"withdrawalCount",
             @"withdrawalAmount"];
}
-(NSArray *)cashFieldArray
{
    return  @[@"saleCount",
             @"SaleAmount",
             @"returnCount",
             @"returnAmount"];
}
-(NSArray *)checkFieldArray
{
    return  @[@"saleCount",
             @"SaleAmount",
             @"AdjustCount",
             @"AdjustAmount"];
}
-(NSArray *)giftFieldArray
{
    return  @[@"saleCount",
             @"SaleAmount",
             @"authCount",
             @"authAmount",
             @"postauthCount",
             @"postauthAmount",
             @"activateCount",
             @"activateAmount",
             @"issueCount",
             @"issueAmount",
             @"addCount",
             @"addAmount",
             @"returnCount",
             @"returnAmount",
             @"forcedCount",
             @"forcedAmount",
             @"cashoutCount",
             @"cashoutAmount",
             @"deactivateCount",
             @"deactivateAmount",
             @"adjustCount",
             @"adjustAmount"];

}
-(NSArray *)loyaltyFieldArray
{
    return  @[@"redeemCount",
             @"redeemAmount",
             @"issueCount",
             @"issueAmount",
             @"addCount",
             @"addAmount",
             @"returnCount",
             @"returnAmount",
             @"forcedCount",
             @"forcedAmount",
             @"activateCount",
             @"activateAmount",
             @"deactivateCount",
             @"deactivateAmount"];
}

@end
