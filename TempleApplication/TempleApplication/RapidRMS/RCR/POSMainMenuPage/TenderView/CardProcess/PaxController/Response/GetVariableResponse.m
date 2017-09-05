//
//  GetVariableResponse.m
//  PaxControllerApp
//
//  Created by siya info on 22/07/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "GetVariableResponse.h"
#import "PaxResponse+Internal.h"

@implementation GetVariableResponse
- (void)setupMessageFormat {
    responseMessageFields = @[
                              @(FieldIndexMultiPacket),
                              @(FieldIndexCommandType),
                              @(FieldIndexVersion),
                              @(FieldIndexResponseCode),
                              @(FieldIndexResponseMessage),
                              @(FieldIndexVariableValue),
                              ];
}

- (void)parseFieldData:(NSData *)fieldData forFieldId:(FieldIndex)fieldId {
    switch (fieldId) {
        case FieldIndexVariableValue:
            [self parseVariableValue:fieldData];
            
            break;
        default:
            [super parseFieldData:fieldData forFieldId:fieldId];
            break;
    }
}

- (void)parseVariableValue:(NSData *)data {
    //////////
    // Variable Value
    // Variable Value : C : ans...60
    NSUInteger length = 60;
    _variableValue = [PaxResponse ansStringFrom:0 maxLength:length data:data];
}

@end
