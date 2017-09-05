//
//  SetVariableRequest.h
//  PaxControllerApp
//
//  Created by siya-IOS5 on 8/6/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PaxRequest.h"

@interface SetVariableRequest : PaxRequest
@property (nonatomic, strong, readonly) NSString* variableName;
@property (nonatomic, strong, readonly) NSString* variableValue;

- (instancetype)initWithVariableName:(NSString*)variableName andVariableValue:(NSString *)variableValue NS_DESIGNATED_INITIALIZER;

@end
