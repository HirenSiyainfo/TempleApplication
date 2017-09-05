//
//  HostReportResponse.m
//  PaxControllerApp
//
//  Created by siya-IOS5 on 8/13/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "HostReportResponse.h"
#import "PaxResponse+Internal.h"

@implementation HostReportResponse

- (void)setupMessageFormat {
    responseMessageFields = @[
                              @(FieldIndexMultiPacket),
                              @(FieldIndexCommandType),
                              @(FieldIndexVersion),
                              @(FieldIndexResponseCode),
                              @(FieldIndexResponseMessage),
                              @(FieldIndexHostReportLineNumber),
                              @(FieldIndexHostReportLineMessage),
                              @(FieldIndexHostReportType),
                              @(FieldIndexHostTimeStamp)
                              ];
}


- (void)parseFieldData:(NSData *)fieldData forFieldId:(FieldIndex)fieldId {
    switch (fieldId) {
        case FieldIndexHostReportLineNumber:
            [self parseNumberOfLines:fieldData];
            break;
        case FieldIndexHostReportLineMessage:
            [self parseNumberOfLinesMessage:fieldData];
            break;
        case FieldIndexHostReportType:
            [self parseReportType:fieldData];
            break;
        case FieldIndexHostTimeStamp:
            break;
        default:
            [super parseFieldData:fieldData forFieldId:fieldId];
            break;
    }
}
-(void)parseNumberOfLines:(NSData *)data
{
    // number of lines = n...2
    _numberOfLines = [PaxResponse stringFrom:0 length:2 data:data];
}

-(void)parseReportType:(NSData *)data
{
    // reportType = ans...32
    _reportType = [PaxResponse stringFrom:0 length:32 data:data];
}

-(void)parseHostTimeStamp:(NSData *)data
{
    // timeStamp = n14
    _reportType = [PaxResponse stringFrom:0 length:14 data:data];
}


-(void)parseNumberOfLinesMessage:(NSData *)data
{
    NSArray *fieldUnits = [self fieldUnitsFromData:data];
    self.hostReportDetail = [[NSMutableDictionary alloc] init];
    for (NSData *data in fieldUnits) {
        _numberOfLines = [PaxResponse stringFrom:0 length:data.length data:data];
        NSArray *fieldValue = [_numberOfLines componentsSeparatedByString:@"="];
        if (fieldValue.count < 1) {
            continue;
        }
        (self.hostReportDetail)[fieldValue.firstObject] = fieldValue[1];
    }
    
}

@end
