//
//  SetVariableResponse.m
//  PaxControllerApp
//
//  Created by siya-IOS5 on 8/6/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "SetVariableResponse.h"

@implementation SetVariableResponse
- (void)setupMessageFormat {
    responseMessageFields = @[
                              @(FieldIndexMultiPacket),
                              @(FieldIndexCommandType),
                              @(FieldIndexVersion),
                              @(FieldIndexResponseCode),
                              @(FieldIndexResponseMessage),
                              ];
}
@end
