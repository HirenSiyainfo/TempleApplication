//
//  DoSignatureRequest.h
//  PaxControllerApp
//
//  Created by siya info on 28/07/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "PaxRequest.h"

@interface DoSignatureRequest : PaxRequest
- (instancetype)initWithEdcType:(EdcType)edcType NS_DESIGNATED_INITIALIZER;
@end
