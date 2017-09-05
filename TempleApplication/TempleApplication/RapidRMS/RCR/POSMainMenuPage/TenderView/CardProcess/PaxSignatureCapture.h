//
//  PaxSignatureCapture.h
//  RapidRMS
//
//  Created by siya-IOS5 on 8/6/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DeviceSignatureCaptureDelegate.h"
#import "PaxDevice.h"
typedef NS_ENUM(NSInteger, CreditCardSignatureProcess)
{
    DOSignature_Request = 2000,
    DOSignature_Response,
    GetSignature_Request,
    GetSignature_Response,
} ;

@interface PaxSignatureCapture : NSObject
-(instancetype)initWithDelegate:(id<DeviceSignatureCaptureDelegate>)delegate WithPaxDevice:(PaxDevice *)paxdevice NS_DESIGNATED_INITIALIZER;

@end
