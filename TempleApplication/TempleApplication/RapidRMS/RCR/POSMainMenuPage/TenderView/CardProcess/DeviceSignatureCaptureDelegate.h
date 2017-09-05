//
//  DeviceSignatureCaptureDelegate.h
//  RapidRMS
//
//  Created by siya-IOS5 on 8/6/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "DeviceSignatureCaptureDelegate.h"
#import "PaxResponse.h"
@protocol DeviceSignatureCaptureDelegate
- (void)didCaptureSignature:(UIImage*)signatureImage;
- (void)displayAlert:(NSString*)title withMessage:(NSString *)message withButtonTitles:(NSArray *)buttonTitles withButtonHandlers:(NSArray *)buttonHandlers;
- (void)didFailToCaptureSignatureImageWitherror:(NSError *)error response:(PaxResponse *)response;
- (void)continueWithoutSignature;
@end
