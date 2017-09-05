//
//  SetVariableRequest.m
//  PaxControllerApp
//
//  Created by siya-IOS5 on 8/6/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "SetVariableRequest.h"
#import "PaxRequest+Internal.h"
@implementation SetVariableRequest



- (instancetype)initWithVariableName:(NSString*)variableName andVariableValue:(NSString *)variableValue{
    self = [super init];
    if (self) {
        _variableName = variableName;
        _variableValue = variableValue;
        _commandType = kPaxCommandSetVariable;
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
    [self appendToData:commandSpecificData byte:PaxControlCharFS];

    
    //// Variable Value
    // Variable Value : O : ans..64
    NSString *variableValue = [NSString stringWithFormat:@"%@", _variableValue];
    [self appendToData:commandSpecificData string:variableValue];
  //  [self appendToData:commandSpecificData byte:PaxControlCharFS];
    
    return commandSpecificData;
}

@end
