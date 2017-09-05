//
//  GetVariableRequest.h
//  PaxControllerApp
//
//  Created by siya info on 22/07/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "PaxRequest.h"

@interface GetVariableRequest : PaxRequest
@property (nonatomic, strong, readonly) NSString* variableName;

- (instancetype)initWithVariableName:(NSString*)variableName NS_DESIGNATED_INITIALIZER;
@end
