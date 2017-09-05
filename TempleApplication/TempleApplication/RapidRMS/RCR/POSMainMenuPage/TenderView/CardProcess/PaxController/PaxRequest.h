//
//  PaxRequest.h
//  PaxTestApp
//
//  Created by Siya Infotech on 05/06/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PaxConstants.h"

@interface PaxRequest : NSObject {
    NSString *_commandType;
    NSMutableData *_commandData;
    NSString *_version;
}
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *base64String;
@property (nonatomic, strong) NSMutableData *requestCommandData;
@end


