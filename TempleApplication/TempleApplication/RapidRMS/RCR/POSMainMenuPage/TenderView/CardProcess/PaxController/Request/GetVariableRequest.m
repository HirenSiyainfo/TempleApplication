//
//  GetVariableRequest.m
//  PaxControllerApp
//
//  Created by siya info on 22/07/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "GetVariableRequest.h"
#import "PaxRequest+Internal.h"

@implementation GetVariableRequest

- (instancetype)initWithVariableName:(NSString*)variableName {
    self = [super init];
    if (self) {
        _variableName = variableName;
        _commandType = kPaxCommandGetVariable;
    }
    return self;
}

- (NSMutableData *)commandSpecificBody {
    NSMutableData *commandSpecificData = [NSMutableData data];
    
    [self appendToData:commandSpecificData byte:PaxControlCharFS];
    // EDC Type : O : n2 // Not sending this data
//    [self appendToData:commandSpecificData string:@"00"];
    [self appendToData:commandSpecificData byte:PaxControlCharFS];

    //// Variable Name
    // Variable Name : O : ans..32
    NSString *transactionString = [NSString stringWithFormat:@"%@", _variableName];
    [self appendToData:commandSpecificData string:transactionString];

    return commandSpecificData;
}
@end
