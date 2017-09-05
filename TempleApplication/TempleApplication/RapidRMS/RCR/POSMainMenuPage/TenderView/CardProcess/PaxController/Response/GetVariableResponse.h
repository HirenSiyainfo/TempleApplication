//
//  GetVariableResponse.h
//  PaxControllerApp
//
//  Created by siya info on 22/07/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "PaxResponse.h"

@interface GetVariableResponse : PaxResponse
@property (nonatomic, strong, readonly) NSString *variableValue;
@end
