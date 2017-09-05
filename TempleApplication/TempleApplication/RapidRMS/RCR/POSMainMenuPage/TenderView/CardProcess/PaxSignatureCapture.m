//
//  PaxSignatureCapture.m
//  RapidRMS
//
//  Created by siya-IOS5 on 8/6/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "PaxSignatureCapture.h"
#import "PaxDevice.h"
#import "DeviceSignatureCaptureDelegate.h"
#import "RmsDbController.h"
#import "DoSignatureResponse.h"
#import "GetSignatureResponse.h"
#import "PaxResponse+Internal.h"

@interface PaxSignatureCapture ()<PaxDeviceDelegate>
{
    NSInteger currentSignatureStatus;
}
@property (nonatomic, retain) RmsDbController  *rmsDbController;
@property (nonatomic,strong) PaxDevice *paxDevice;

@property(nonatomic,weak) id <DeviceSignatureCaptureDelegate>deviceSignatureCaptureDelegate;

@end
@implementation PaxSignatureCapture
-(instancetype)initWithDelegate:(id<DeviceSignatureCaptureDelegate>)delegate WithPaxDevice:(PaxDevice *)paxdevice
{
    self = [super init];
    if (self) {
        self.rmsDbController = [RmsDbController sharedRmsDbController];
        self.deviceSignatureCaptureDelegate = delegate;
        self.paxDevice = paxdevice;
        self.paxDevice.paxDeviceDelegate = self;
        currentSignatureStatus = DOSignature_Request;
        [self performSignatureProcess];
    }
    return self;
}



-(void)performSignatureProcess
{
    switch (currentSignatureStatus) {
        case DOSignature_Request:
        {
            [self creditCardSignatureRequestWithId:DOSignature_Request];
        }
            break;
        case DOSignature_Response:
            break;
        case GetSignature_Request:
        {
            [self creditCardSignatureRequestWithId:GetSignature_Request];
        }
            break;
        case GetSignature_Response:
            break;
        default:
            break;
    }
}


-(void)creditCardSignatureRequestWithId:(CreditCardSignatureProcess)creditcardSignatureProcess
{
    if (creditcardSignatureProcess == DOSignature_Request) {
        self.paxDevice.pdResonse = PDResponseDoSignature;
        [self.paxDevice doSignatureWithEdcType:EdcTypeCredit];
    }
    else if (creditcardSignatureProcess == GetSignature_Request){
        self.paxDevice.pdResonse = PDResponseGetSignature;
        [self.paxDevice getSignature];
    }
}


- (BOOL)isDoSignature:(NSString*)code {
    NSRange range = [code rangeOfString:@"A21"];
    return range.location != NSNotFound;
}
- (BOOL)isGetSignature:(NSString*)code {
    NSRange range = [code rangeOfString:@"A09"];
    return range.location != NSNotFound;
}

-(void)parseDoSignatureProcess:(PaxResponse *)response
{
    NSLog(@"parseDoSignatureProcess");
    DoSignatureResponse *doSignature = (DoSignatureResponse *)response;
    if (doSignature.responseCode.integerValue == 0) {
        currentSignatureStatus = GetSignature_Request;
        [self performSignatureProcess];
    }
    else{
        currentSignatureStatus = DOSignature_Request;
        [self displayAlert];
    }
    
}

-(void)displayAlert
{
    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
    {
        [self performSignatureProcess];
    };
    
    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
    {
        [self.deviceSignatureCaptureDelegate continueWithoutSignature];
    };
    
    NSArray *handlers = @[leftHandler,rightHandler];
    NSArray *buttonTitles = @[@"Retry",@"Continue without signature"];
    [self.deviceSignatureCaptureDelegate displayAlert:@"Info" withMessage:@"Signature process could not be completed. Do you want to retry?" withButtonTitles:buttonTitles withButtonHandlers:handlers];
}

-(void)parseGetSignatureProcess:(PaxResponse *)response
{
    NSLog(@"parseDoSignatureProcess");
    GetSignatureResponse *getSignature = (GetSignatureResponse *)response;
    if (getSignature.responseCode.integerValue == 0) {
        UIImage *signatureImage = getSignature.signatureImage;
        [self.deviceSignatureCaptureDelegate didCaptureSignature:signatureImage];
    }
    else{
        currentSignatureStatus = GetSignature_Request;
        [self displayAlert];
    }
}


#pragma mark-
#pragma PAX_DEVICE Delegate Methods
- (void)paxDevice:(PaxDevice*)paxDevice willSendRequest:(NSString*)request{
}
- (void)paxDevice:(PaxDevice*)paxDevice response:(PaxResponse*)response
{
    NSString *code = response.commandType;
      if ([self isDoSignature:code]) {
        /// Parse Intialize code here....
        [self parseDoSignatureProcess:response];
    } else  if ([self isGetSignature:code]) {
        /// Parse Intialize code here....
        [self parseGetSignatureProcess:response];
    }
}
- (void)paxDevice:(PaxDevice*)paxDevice failed:(NSError*)error response:(PaxResponse *)response
{
    NSString *errorMessage = error.localizedDescription;
    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
    {
        [self performSignatureProcess];
    };
    
    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
    {
        [self.deviceSignatureCaptureDelegate continueWithoutSignature];
    };
    
    NSArray *handlers = @[leftHandler,rightHandler];
    NSArray *buttonTitles = @[@"Retry",@"Continue without signature"];
    [self.deviceSignatureCaptureDelegate displayAlert:@"Signature process error" withMessage:errorMessage withButtonTitles:buttonTitles withButtonHandlers:handlers];
}

- (void)paxDevice:(PaxDevice*)paxDevice isConncted:(BOOL)isConncted{
}
- (void)paxDeviceDidTimeout:(PaxDevice*)paxDevice{
}

@end
