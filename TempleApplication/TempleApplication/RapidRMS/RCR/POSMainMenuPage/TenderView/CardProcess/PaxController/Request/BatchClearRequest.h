//
//  BatchClearRequest.h
//  PaxControllerApp
//
//  Created by siya info on 30/07/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "PaxRequest.h"

@interface BatchClearRequest : PaxRequest
- (instancetype)initWithEdcType:(EdcType)edcType NS_DESIGNATED_INITIALIZER;
@end
