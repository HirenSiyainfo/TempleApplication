//
//  HistoryReportResponse.m
//  PaxControllerApp
//
//  Created by siya-IOS5 on 8/13/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "HistoryReportResponse.h"
#import "PaxResponse+Internal.h"

@implementation HistoryReportResponse
- (void)setupMessageFormat {
    responseMessageFields = @[
                              @(FieldIndexMultiPacket),
                              @(FieldIndexCommandType),
                              @(FieldIndexVersion),
                              @(FieldIndexResponseCode),
                              @(FieldIndexResponseMessage),
                              @(FieldIndexHistoryReportTotalCount),
                              @(FieldIndexHistoryReportTotalAmount),
                              @(FieldIndexHistoryReportTimeStamp),
                              @(FieldIndexHistoryReportBatchNumber),
                              ];
}


- (void)parseFieldData:(NSData *)fieldData forFieldId:(FieldIndex)fieldId {
    switch (fieldId) {
        case FieldIndexHistoryReportTotalCount:
            [self parseTotalCount:fieldData];
            break;
        case FieldIndexHistoryReportTotalAmount:
            [self parseTotalAmount:fieldData];
            break;
        case FieldIndexHistoryReportTimeStamp:
            [self parseTimeStamp:fieldData];
            break;
        case FieldIndexHistoryReportBatchNumber:
            [self parseBatchNumber:fieldData];
            break;
        default:
            [super parseFieldData:fieldData forFieldId:fieldId];
            break;
    }
}
-(void)parseTotalCount:(NSData *)data
{
   NSString *totalCount = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    NSArray *totalCountArray = [totalCount componentsSeparatedByString:@"="];
    NSArray *addtionalFieldArray = @[@"creditCount",
                                    @"debitCount",
                                    @"ebtCount",
                                    @"gfitCount",
                                    @"loyaltyCount",
                                    @"cashCount",
                                    @"CHECKCount"];
    
    self.totalCountDetail = [[NSMutableDictionary alloc] init];
    for (int i =0 ; i < totalCountArray.count; i++) {
        (self.totalCountDetail)[addtionalFieldArray[i]] = totalCountArray[i];
    }
}


-(void)parseTotalAmount:(NSData *)data
{
    NSString *totalAmount = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    NSArray *totalAmountArray = [totalAmount componentsSeparatedByString:@"="];
    NSArray *addtionalFieldArray = @[@"creditAmount",
                                    @"debitAmount",
                                    @"ebtAmount",
                                    @"giftAmount",
                                    @"loyaltyAmount",
                                    @"cashAmount",
                                    @"CHECKAmount"];
    
    self.totalAmountDetail = [[NSMutableDictionary alloc] init];
    for (int i =0 ; i < totalAmountArray.count; i++) {
        (self.totalAmountDetail)[addtionalFieldArray[i]] = totalAmountArray[i];
    }
}

-(void)parseTimeStamp:(NSData *)data
{
    // timeStamp = n14
    _timeStamp = [PaxResponse stringFrom:0 length:32 data:data];
}

-(void)parseBatchNumber:(NSData *)data
{
    // batchNumber = ans...32
    _batchNumber = [PaxResponse stringFrom:0 length:32 data:data];
}


@end
