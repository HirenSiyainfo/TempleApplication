//
//  ForceBatchCloseResponse.m
//  PaxControllerApp
//
//  Created by siya info on 30/07/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "ForceBatchCloseResponse.h"
#import "PaxResponse+Internal.h"

@implementation ForceBatchCloseResponse
- (void)setupMessageFormat {

    responseMessageFields = @[
                              @(FieldIndexMultiPacket),
                              @(FieldIndexCommandType),
                              @(FieldIndexVersion),
                              @(FieldIndexResponseCode),
                              @(FieldIndexResponseMessage),
                              @(FieldIndexBCHostInformation),
                              @(FieldIndexLineNumber),
                              @(FieldIndexLineMessage),
                              @(FieldIndexTimeStamp),
                              ];
}

- (void)parseFieldData:(NSData *)fieldData forFieldId:(FieldIndex)fieldId {
    switch (fieldId) {
        case FieldIndexLineMessage:
            [self parseLineMessage:fieldData];
            break;
        case FieldIndexLineNumber:
            [self parseLineNumber:fieldData];
            break;
        default:
            [super parseFieldData:fieldData forFieldId:fieldId];
            break;
    }
}

- (void)parseLineNumber:(NSData*)data {
    NSString *lineNumberString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    _lineCount = lineNumberString.integerValue;
}

- (void)parseLineMessage:(NSData*)data {
    NSArray *linesData = [PaxResponse fieldUnitsFromData:data];
    NSMutableArray *lines = [NSMutableArray array];
    for (NSData *lineData in linesData) {
        NSString *line = [[NSString alloc] initWithData:lineData encoding:NSASCIIStringEncoding];
        [lines addObject:line];
    }
    _lineMessages = [lines copy];
}

@end
