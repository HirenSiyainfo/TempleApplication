//
//  PaxDevice.m
//  PaxTestApp
//
//  Created by Siya Infotech on 05/06/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "PaxDevice.h"
#import "PaxRequest.h"
#import "PaxResponse.h"
#import "PaxResponse+Internal.h"

// Administrative
#import "InitializeRequest.h"
#import "GetVariableRequest.h"
#import "SetVariableRequest.h"
#import "DoSignatureRequest.h"
#import "GetSignatureRequest.h"
// Transaction
#import "DoCreditRequest.h"
#import "DoDebitRequest.h"
#import "DoEbtRequest.h"
// Batch
#import "BatchCloseRequest.h"
#import "ForceBatchCloseRequest.h"
#import "BatchClearRequest.h"
#import "HostReportRequest.h"
#import "HistoryReportRequest.h"
#import "LocalTotalReportRequest.h"
#import "Local DetailReportRequest.h"
#import "RmsDbController.h"
// Simulate Response for develpoment
//#define SIMULATE_POSITIVE_RESPONSE

#ifndef DEBUG
    #ifdef SIMULATE_POSITIVE_RESPONSE
     #undef SIMULATE_POSITIVE_RESPONSE
    #endif
#else
    #define SIMULATE_RESPONSE_CODE PDResponseDoCredit
#endif


@interface PaxDevice () <NSURLConnectionDelegate, NSURLConnectionDataDelegate,NSURLSessionDelegate,NSURLSessionDownloadDelegate,NSURLSessionTaskDelegate,NSURLAuthenticationChallengeSender> {
    NSString *serverIp;
    NSString *serverPort;
    NSMutableData *mutableData;
    NSURLConnection *paxConnection;
    NSOperationQueue *paxDeviceQueue;

    NSLock *operationLock;
    NSURLSessionConfiguration *configuration;
}
@property (nonatomic, readwrite) BOOL busy;
@property(nonatomic , strong) NSURLSessionDownloadTask *downloadTask;
@property(nonatomic , strong) NSURLSession *session;
@property(nonatomic , strong) RmsDbController *rmsDBController;

@end

@implementation PaxDevice
- (instancetype)initWithIp:(NSString*)_serverIp port:(NSString*)_port {
    self = [super init];
    
    if (self) {
        _busy = NO;
        serverIp = _serverIp;
        serverPort = _port;
        
        paxDeviceQueue = [[NSOperationQueue alloc] init];
        paxDeviceQueue.name = @"Queue.PaxDevice.Rms";
        self.rmsDBController = [RmsDbController sharedRmsDbController];
        [self setupLock];
    }
    return self;
}

- (void)dealloc {
    [paxConnection cancel];
    paxConnection = nil;
    mutableData = nil;
}

#pragma mark - Request Common
- (void)sendRequestWithId:(PDRequest)pdRequest parameters:(NSDictionary*)parameters {
    [self lock];
    PaxRequest *request = nil;
    switch (pdRequest) {
        case PDRequestInitialize:
            request = [[InitializeRequest alloc] init];
            break;

        case PDRequestDoCredit:
        {
            float amount = [parameters[@"Amount"] floatValue];
            NSString *invoiceNumber = parameters[@"InvoiceNumber"];
            NSString *referenceNumber = parameters[@"ReferenceNumber"];
            request = [[DoCreditRequest alloc] initCreditAmount:amount invoiceNumber:invoiceNumber referenceNumber:referenceNumber];
        }
            break;

        default:
            break;
    }

    [self sendRequest:request];
}

- (void)sendRequest:(PaxRequest*)request {
    NSString *requestBase64String = request.base64String; // @"Base64 string from Request..."; //
    self.requestData = request.requestCommandData;
    NSLog(@"requestData = %@",self.requestData);
    NSMutableString *requestUrl = [NSMutableString string];
    [requestUrl appendString:@"https://"];
    [requestUrl appendString:serverIp];
    [requestUrl appendString:@":"];
    [requestUrl appendString:serverPort];
    [requestUrl appendString:@"/?"];

    [requestUrl appendString:requestBase64String];

    NSLog(@"Request Url = %@", requestUrl);

    [_paxDeviceDelegate paxDevice:self willSendRequest:requestUrl];

    NSURLRequest *urlrequest = [NSURLRequest requestWithURL:[NSURL URLWithString:requestUrl]
                                             cachePolicy:NSURLRequestUseProtocolCachePolicy
                                         timeoutInterval:300.0];

//    NSURLRequest *requestURL = [NSURLRequest requestWithURL:[NSURL URLWithString:requestUrl]];
   
    configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    configuration.requestCachePolicy = NSURLRequestUseProtocolCachePolicy;
    configuration.timeoutIntervalForRequest = 40;

    if (self.rmsDBController.paxURLSession == nil) {
        self.rmsDBController.paxURLSession = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    }
    
    self.downloadTask = [self.rmsDBController.paxURLSession downloadTaskWithRequest:urlrequest completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error) {
            NSLog(@"Failure");
            if (mutableData) {
                self.responseData = mutableData;
                NSLog(@"responseData = %@",self.responseData);
            }
            else
            {
                self.responseData = [[NSMutableData alloc] init];
                NSLog(@"responseData = %@",self.responseData);
            }
            [_paxDeviceDelegate paxDevice:self failed:error response:nil];
        }
        else
        {
            NSLog(@"Success");
            NSData *data = [NSData dataWithContentsOfURL:location];
            mutableData = [data mutableCopy];
            
            paxConnection = nil;
            if (mutableData) {
                self.responseData = mutableData;
                NSLog(@"responseData = %@",self.responseData);
            }
            else
            {
                self.responseData = [[NSMutableData alloc] init];
                NSLog(@"responseData = %@",self.responseData);
            }
            PaxResponse *response = [PaxResponse responseFromData:mutableData];
            
            if (response.responseCode.integerValue == 0) {
                [_paxDeviceDelegate paxDevice:self response:response];
            }
            else
            {
                [_paxDeviceDelegate paxDevice:self failed:nil response:response];
            }
            mutableData = nil;
        }
    }];
    [self.downloadTask resume];

  /*  paxConnection = [[NSURLConnection alloc] initWithRequest:urlrequest delegate:self startImmediately:NO];
    [paxConnection setDelegateQueue:paxDeviceQueue];
    [paxConnection start];*/
}


- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler{
    if([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]){
            NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
            completionHandler(NSURLSessionAuthChallengeUseCredential,credential);
    }
}

//- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
//didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
// completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * __nullable credential))completionHandler
//{
//    if([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]){
//        NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
//        completionHandler(NSURLSessionAuthChallengeUseCredential,credential);
//    }
//}

/*- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
    if([protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust])
    {
        
        return YES;
    }
    else
    {
        if([protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodHTTPBasic])
        {
            return YES;
        }
    }
    return NO;
    
    
}
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * __nullable credential))completionHandler
{

    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust])
    {
        [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
//        [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
    }
    else
    {
        if([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodHTTPBasic])
        {
            
            NSURLCredential *creden = [[NSURLCredential alloc] initWithUser:@"USERNAME" password:@"PASSWORD" persistence:NSURLCredentialPersistenceForSession];
            
            [[challenge sender] useCredential:creden forAuthenticationChallenge:challenge];
        }
        else
        {
            [[challenge sender]cancelAuthenticationChallenge:challenge];
            
        }
    }

}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location
{
    NSData *data = [NSData dataWithContentsOfURL:location];
    mutableData = [data mutableCopy];
    
    paxConnection = nil;
    if (mutableData) {
        self.responseData = mutableData;
        NSLog(@"responseData = %@",self.responseData);
    }
    else
    {
        self.responseData = [[NSMutableData alloc] init];
        NSLog(@"responseData = %@",self.responseData);
    }
    PaxResponse *response = [PaxResponse responseFromData:mutableData];
    
    if (response.responseCode.integerValue == 0) {
        [_paxDeviceDelegate paxDevice:self response:response];
    }
    else
    {
        [_paxDeviceDelegate paxDevice:self failed:nil response:response];
    }
    mutableData = nil;
    [self unlock];


}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
  
}


- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes
{
    NSLog(@"fileOffset = %lld",fileOffset);
    NSLog(@"expectedTotalBytes = %lld",expectedTotalBytes);
    
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data
{
   
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
didBecomeStreamTask:(NSURLSessionStreamTask *)streamTask
{
    
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error
{
#ifdef SIMULATE_POSITIVE_RESPONSE
    [self simulatePositiveResponseForResponseCode:self.pdResonse];
    // [_paxDeviceDelegate paxDevice:self failed:error];
#else
    NSLog(@"Failure");
    if (mutableData) {
        self.responseData = mutableData;
        NSLog(@"responseData = %@",self.responseData);
    }
    else
    {
        self.responseData = [[NSMutableData alloc] init];
        NSLog(@"responseData = %@",self.responseData);
    }
    [_paxDeviceDelegate paxDevice:self failed:error response:nil];
#endif
    
    paxConnection = nil;
    mutableData = nil;
    [self unlock];

}*/


#pragma mark - Connectivity
- (void)checkConnectivity {
    [self initializeDevice];
}

#pragma mark - Request Specific
#pragma mark - Initialize
- (void)initializeDevice {
    [self sendRequestWithId:PDRequestInitialize parameters:nil];
}

#pragma mark - Get Variable
- (void)getVariable:(NSString*)variableName {
    PaxRequest *request = [[GetVariableRequest alloc] initWithVariableName:variableName];
    [self sendRequest:request];
}
- (void)setVariable:(NSString*)variableName withVarialbleValue:(NSString*)variableValue{
    PaxRequest *request = [[SetVariableRequest alloc] initWithVariableName:variableName andVariableValue:variableValue];
    [self sendRequest:request];
}

#pragma mark -  Signture
// Do Signature
- (void)doSignatureWithEdcType:(EdcType)edcType {
    PaxRequest *request = [[DoSignatureRequest alloc] initWithEdcType:edcType];
    [self sendRequest:request];
}

// Get Signature
- (void)getSignature {
    PaxRequest *request = [[GetSignatureRequest alloc] init];
    [self sendRequest:request];
}

#pragma mark - Credit
- (void)doCreditWithAmount:(float)amount invoiceNumber:(NSString*)invoiceNumber referenceNumber:(NSString*)referenceNumber {
    PaxRequest *request = nil;
    
    request = [[DoCreditRequest alloc] initCreditAmount:amount invoiceNumber:invoiceNumber referenceNumber:referenceNumber];
    
    [self sendRequest:request];
}

- (void)doCreditWithAmount:(float)amount tipAmount:(float)tipAmount invoiceNumber:(NSString*)invoiceNumber referenceNumber:(NSString*)referenceNumber {

    PaxRequest *request = [[DoCreditRequest alloc] initCreditAmount:amount tipAmount:tipAmount invoiceNumber:invoiceNumber referenceNumber:referenceNumber];
    
    [self sendRequest:request];
}

- (void)doCreditWithAmount:(float)amount tipAmount:(float)tipAmount taxAmount:(float)taxAmount invoiceNumber:(NSString*)invoiceNumber referenceNumber:(NSString*)referenceNumber {

    PaxRequest *request = [[DoCreditRequest alloc] initCreditAmount:amount tipAmount:tipAmount taxAmount:taxAmount invoiceNumber:invoiceNumber referenceNumber:referenceNumber];
    
    [self sendRequest:request];
}

- (void)adjustCreditTipAmount:(float)tipAmount invoiceNumber:(NSString*)invoiceNumber referenceNumber:(NSString*)referenceNumber transactionNumber:(NSString*)transactionNumber {
    PaxRequest *request = [[DoCreditRequest alloc] initWithTipAdjustment:transactionNumber referenceNumber:referenceNumber tipAmount:tipAmount];

    
    [self sendRequest:request];
}

- (void)refundCreditAmount:(float)refundAmount transactionNumber:(NSString*)transactionNumber referenceNumber:(NSString*)referenceNumber {
    PaxRequest *request = [[DoCreditRequest alloc] initRefund:transactionNumber referenceNumber:referenceNumber amount:refundAmount];
    [self sendRequest:request];
}

- (void)voidCreditTransactionNumber:(NSString*)transactionNumber invoiceNumber:(NSString*)invoiceNumber referenceNumber:(NSString*)referenceNumber {
    PaxRequest *request = nil;
    request = [[DoCreditRequest alloc] initVoidTransactionNumber:transactionNumber invoiceNumber:invoiceNumber referenceNumber:referenceNumber];
    [self sendRequest:request];
}

- (void)doCreditAuthWithAmount:(float)amount tipAmount:(float)tipAmount taxAmount:(float)taxAmount invoiceNumber:(NSString*)invoiceNumber referenceNumber:(NSString*)referenceNumber {
    
    PaxRequest *request = [[DoCreditRequest alloc] initCreditAuthAmount:amount tipAmount:tipAmount taxAmount:taxAmount invoiceNumber:invoiceNumber referenceNumber:referenceNumber];
    [self sendRequest:request];
}

- (void)doCreditCaptureWithAmount:(float)amount withInvoiceNumber:(NSString*)invoiceNumber referenceNumber:(NSString*)referenceNumber transactionNumber:(NSString*)transactionNumber withAuthCode:(NSString *)authCode
{
    
    PaxRequest *request = [[DoCreditRequest alloc] initCreditCaptureAmount:amount withInvoiceNumber:invoiceNumber referenceNumber:referenceNumber TransactionNumber:transactionNumber withAuthCode:authCode];
    [self sendRequest:request];
}
#pragma mark - Post Auth
- (void)doCreditPostAuthWithAmount:(float)amount withInvoiceNumber:(NSString*)invoiceNumber referenceNumber:(NSString*)referenceNumber transactionNumber:(NSString*)transactionNumber withAuthCode:(NSString *)authCode
{
    
    PaxRequest *request = [[DoCreditRequest alloc] initCreditPostAuthAmount:amount withInvoiceNumber:invoiceNumber referenceNumber:referenceNumber TransactionNumber:transactionNumber withAuthCode:authCode];
    [self sendRequest:request];
}


#pragma mark - Debit
- (void)doDebitWithAmount:(float)amount invoiceNumber:(NSString*)invoiceNumber referenceNumber:(NSString*)referenceNumber {
    PaxRequest *request = nil;
    
    request = [[DoDebitRequest alloc] initCreditAmount:amount invoiceNumber:invoiceNumber referenceNumber:referenceNumber];
    
    [self sendRequest:request];
}

- (void)doDebitWithAmount:(float)amount tipAmount:(float)tipAmount invoiceNumber:(NSString*)invoiceNumber referenceNumber:(NSString*)referenceNumber {
    
    PaxRequest *request = [[DoDebitRequest alloc] initCreditAmount:amount tipAmount:tipAmount invoiceNumber:invoiceNumber referenceNumber:referenceNumber];
    
    [self sendRequest:request];
}

- (void)doDebitWithAmount:(float)amount tipAmount:(float)tipAmount taxAmount:(float)taxAmount invoiceNumber:(NSString*)invoiceNumber referenceNumber:(NSString*)referenceNumber {
    
    PaxRequest *request = [[DoDebitRequest alloc] initCreditAmount:amount tipAmount:tipAmount taxAmount:taxAmount invoiceNumber:invoiceNumber referenceNumber:referenceNumber];
    
    [self sendRequest:request];
}

- (void)adjustDebitTipAmount:(float)tipAmount invoiceNumber:(NSString*)invoiceNumber referenceNumber:(NSString*)referenceNumber  transactionNumber:(NSString*)transactionNumber {
    NSLog(@"IMPLEMENT");
    PaxRequest *request = [[DoDebitRequest alloc] initWithTipAdjustment:transactionNumber referenceNumber:referenceNumber tipAmount:tipAmount];
    [self sendRequest:request];
}

- (void)refundDebitAmount:(float)refundAmount transactionNumber:(NSString*)transactionNumber referenceNumber:(NSString*)referenceNumber {
    PaxRequest *request = [[DoDebitRequest alloc] initRefund:transactionNumber referenceNumber:referenceNumber amount:refundAmount];
    [self sendRequest:request];
}

- (void)voidDebitTransactionNumber:(NSString*)transactionNumber invoiceNumber:(NSString*)invoiceNumber referenceNumber:(NSString*)referenceNumber {
    PaxRequest *request = nil;
    request = [[DoDebitRequest alloc] initVoidTransactionNumber:transactionNumber invoiceNumber:invoiceNumber referenceNumber:referenceNumber];
    [self sendRequest:request];
}

#define EBT_IMPLEMENTED
#ifdef EBT_IMPLEMENTED
#pragma mark - Ebt
- (void)doEbtWithAmount:(float)amount invoiceNumber:(NSString*)invoiceNumber referenceNumber:(NSString*)referenceNumber {
    PaxRequest *request = nil;

    request = [[DoEbtRequest alloc] initCreditAmount:amount invoiceNumber:invoiceNumber referenceNumber:referenceNumber];

    [self sendRequest:request];
}

- (void)doEbtWithAmount:(float)amount tipAmount:(float)tipAmount invoiceNumber:(NSString*)invoiceNumber referenceNumber:(NSString*)referenceNumber {

    PaxRequest *request = [[DoEbtRequest alloc] initCreditAmount:amount tipAmount:tipAmount invoiceNumber:invoiceNumber referenceNumber:referenceNumber];

    [self sendRequest:request];
}

- (void)doEbtWithAmount:(float)amount tipAmount:(float)tipAmount taxAmount:(float)taxAmount invoiceNumber:(NSString*)invoiceNumber referenceNumber:(NSString*)referenceNumber {

    PaxRequest *request = [[DoEbtRequest alloc] initCreditAmount:amount tipAmount:tipAmount taxAmount:taxAmount invoiceNumber:invoiceNumber referenceNumber:referenceNumber];

    [self sendRequest:request];
}

- (void)adjustEbtTipAmount:(float)tipAmount invoiceNumber:(NSString*)invoiceNumber referenceNumber:(NSString*)referenceNumber {
    NSLog(@"IMPLEMENT");
}

- (void)refundEbtAmount:(float)refundAmount transactionNumber:(NSString*)transactionNumber referenceNumber:(NSString*)referenceNumber {
    PaxRequest *request = [[DoEbtRequest alloc] initRefund:transactionNumber referenceNumber:referenceNumber amount:refundAmount];
    [self sendRequest:request];
}

- (void)voidEbtTransactionNumber:(NSString*)transactionNumber invoiceNumber:(NSString*)invoiceNumber referenceNumber:(NSString*)referenceNumber {
    PaxRequest *request = nil;
    request = [[DoEbtRequest alloc] initVoidTransactionNumber:transactionNumber invoiceNumber:invoiceNumber referenceNumber:referenceNumber];
    [self sendRequest:request];
}

#endif


#pragma mark - Host Report
-(void)hostReport
{
    PaxRequest *request = [[HostReportRequest alloc] init];
    [self sendRequest:request];
}
- (void)historyReport
{
    PaxRequest *request = [[HistoryReportRequest alloc] init];
    [self sendRequest:request];
}
- (void)localTotalReport
{
    PaxRequest *request = [[LocalTotalReportRequest alloc] init];
    [self sendRequest:request];
}
- (void)getLocalDetailReportForRecordNumber:(NSInteger)recordNumber  {
    
    PaxRequest *request = [[Local_DetailReportRequest alloc] initWithRecordNumber:recordNumber ];
    [self sendRequest:request];
}

- (void)getLocalDetailReportForReferenceNumber:(NSString *) referenceNumber{
    
    PaxRequest *request = [[Local_DetailReportRequest alloc] initWithReferenceNumber:referenceNumber ];
    [self sendRequest:request];
}


#pragma mark - Batch
- (void)closeBatch {
    PaxRequest *request = [[BatchCloseRequest alloc] init];
    [self sendRequest:request];
}

- (void)forceCloseBatch {
    PaxRequest *request = [[ForceBatchCloseRequest alloc] init];
    [self sendRequest:request];
}

- (void)clearBatch:(EdcType)edcType {
    PaxRequest *request = [[BatchClearRequest alloc] initWithEdcType:edcType];
    [self sendRequest:request];
}


#pragma mark - NSURLConnectionDelegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
//    [data setLength:0];
    mutableData = [NSMutableData data];

    NSHTTPURLResponse *r = (NSHTTPURLResponse*) response;
    NSDictionary *headers = r.allHeaderFields;

    NSLog(@"Code = %ld\nheaders = %@\n", (long)r.statusCode, headers);

}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)incrementalData {
    [mutableData appendData:incrementalData];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)aConnection {
    NSLog(@"Success");
    paxConnection = nil;
    if (mutableData) {
        self.responseData = mutableData;
        NSLog(@"responseData = %@",self.responseData);
    }
    else
    {
        self.responseData = [[NSMutableData alloc] init];
        NSLog(@"responseData = %@",self.responseData);
    }
    PaxResponse *response = [PaxResponse responseFromData:mutableData];

    if (response.responseCode.integerValue == 0) {
        [_paxDeviceDelegate paxDevice:self response:response];
    }
    else
    {
        [_paxDeviceDelegate paxDevice:self failed:nil response:response];
    }
    mutableData = nil;
    [self unlock];
}

- (void)connection:(NSURLConnection *)aConnection didFailWithError:(NSError *)error {
    
  /*  if (self.pdResonse == PDResponseDoSignature)
    {
        [_paxDeviceDelegate paxDevice:self failed:error response:nil];
    }
    else
    {
        [self simulatePositiveResponseForResponseCode:self.pdResonse];
    }*/
    
#ifdef SIMULATE_POSITIVE_RESPONSE
    [self simulatePositiveResponseForResponseCode:self.pdResonse];
   // [_paxDeviceDelegate paxDevice:self failed:error];
#else
    NSLog(@"Failure");
    if (mutableData) {
        self.responseData = mutableData;
        NSLog(@"responseData = %@",self.responseData);
    }
    else
    {
        self.responseData = [[NSMutableData alloc] init];
        NSLog(@"responseData = %@",self.responseData);
    }
    [_paxDeviceDelegate paxDevice:self failed:error response:nil];
#endif

    paxConnection = nil;
    mutableData = nil;
    [self unlock];
}

- (void)setupLock {
    // TODO: Different threads are using operationLock for locking and unlocking it.
    // Need to address this. Till then we will not create NSLock object.
//    operationLock = [[NSLock alloc] init];
}

- (void)lock {
    [operationLock lock];
}

- (void)unlock {
    [operationLock unlock];
}

#ifdef SIMULATE_POSITIVE_RESPONSE
- (NSData *)dataFromSimulatedResponseString:(NSString *)responseString {
    NSMutableData *simulatedResponseData = [NSMutableData data];
    
    responseString = [responseString stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSInteger count = responseString.length;
    
    for (NSInteger index = 0; index < count; index += 2) {
        NSRange range;
        range.location = index;
        range.length = 2;
        NSString *subString = [responseString substringWithRange:range];
        
        char cString[3];
        strcpy(cString, [subString cStringUsingEncoding:NSASCIIStringEncoding]);
        unsigned char byte = (unsigned char) strtol(cString, NULL, 16);
        [PaxResponse appendByte:byte toData:simulatedResponseData];
    }
    
    return simulatedResponseData;
}

- (void)simulatePositiveResponseForResponseCode:(PDResponse)responseCode {
    NSData *simulatedResponseData;
    switch (responseCode) {
        case PDResponseDoCredit:
        {

//            NSString *responseString = @"02301c54 30311c31 2e33321c 30303030 30301c4f 4b1c3030 1f415050 524f5641 4c1f3331 33333335 1f353139 32313336 34333237 371f1f31 1c30311c 3130301f 301f301f 301f301f 301f1f1c 34313131 1f321f31 3232351f 1f1f1f30 321f1f1f 1f301c34 1f311f32 30313530 37313130 39353031 381c1f1c 1c1c5349 474e5354 41545553 3d341f54 433d3045 35323846 31453731 42423845 41361f54 56523d30 34303030 30383030 301f4149 443d4130 30303030 30303034 31303130 1f415443 3d303030 411f4150 504c4142 3d4d4153 54455243 4152441f 41505050 4e3d4d61 73746572 43617264 43726564 69740310";

//            NSString *responseString = @"02301c54 30311c31 2e33321c 30303030 30301c4f 4b1c3030 1f415050 524f5641 4c1f3331 33333337 1f353139 32313336 34333231 351f1f31 1c30311c 3130301f 301f301f 301f301f 301f1f1c 34313131 1f341f31 3232351f 1f1f1f30 321f4449 20546573 742f4361 72642030 361f1f1f 301c351f 311f3230 31353037 31313039 35333134 1c1f1c1c 1c534947 4e535441 5455533d 341f5443 3d323730 41323135 41413241 35414534 351f5456 523d3038 30303030 38303030 1f414944 3d413030 30303030 30303431 3031301f 5453493d 45383030 1f415443 3d303030 421f4150 504c4142 3d4d4153 54455243 4152441f 41505050 4e3d4d61 73746572 43617264 43726564 69740353";
            
            
            NSString *responseString = @"02301c54 30311c31 2e33331c 30303030 30301c4f 4b1c3030 1f415050 524f5641 4c1f3630 30333641 1f353334 34313738 33313736 391f1f32 341c3137 1c353335 1f301f30 1f301f30 1f301f1f 1c303131 391f301f 31323232 1f1f1f1f 30311f1f 1f1f311c 32311f41 43313231 30313530 32333234 301f3230 31353132 31303033 34323137 1c1f1c1c 1c54433d 37373838 45333644 45453241 45344436 1f545652 3d303830 30303038 3030301f 4149443d 41303030 30303030 30333130 31301f54 53493d46 3830301f 4154433d 30303143 1f415050 4c41423d 56697361 20437265 6469741f 41505050 4e3d5669 73612043 72656469 741f4356 4d3d3603 3e";

//            NSString *responseString = @"02301c54 30311c31 2e33331c 30303030 30301c4f 4b1c3030 1f415050 524f5641 4c1f3639 32303630 1f353239 39313637 35353838 341f1f31 351c3031 1c363030 1f301f30 1f301f30 1f301f1f 1c343131 311f341f 31323235 1f1f1f1f 30321f44 49205465 73742f43 61726420 30361f1f 1f301c32 1f2d311f 32303135 31303236 32303433 32371c1f 1c1c1c53 49474e53 54415455 533d4e1f 54433d35 42423131 33304433 44303042 3237301f 5456523d 30383030 30303830 30301f41 49443d41 30303030 30303030 34313031 301f5453 493d4538 30301f41 54433d30 3030351f 4150504c 41423d4d 41535445 52434152 441f4150 50504e3d 4d617374 65724361 72644372 65646974 1f43564d 3d310373";
          
//            NSString *responseString =   @"02301c54 30311c31 2e33331c 30303030 30301c4f 4b1c3030 1f415050 524f5641 4c1f3230 35363833 1f353331 30313730 35313339 301f1f31 371c3031 1c353031 1f301f30 1f301f30 1f301f1f 1c303231 361f341f 31323137 1f1f1f1f 30341f43 4152442f 494d4147 45203136 1f1f1f30 1c341f2d 311f3230 31353131 30363232 31343439 1c1f1c1c 1c534947 4e535441 5455533d 4e1f5443 3d454231 37343643 36363544 30394134 331f5456 523d3432 30303034 38303030 1f414944 3d413030 30303030 31353233 3031301f 5453493d 45383030 1f415443 3d303030 391f4150 504c4142 3d444953 434f5645 521f4356 4d3d3203 43";
            
//                  NSString *responseString = @"02301c54 30311c31 2e33331c 30303030 30301c4f 4b1c3030 1f415050 524f5641 4c1f3539 38383530 1f353331 30313730 35313337 361f1f31 371c3031 1c343030 1f301f30 1f301f30 1f301f1f 1c343131 311f341f 31323235 1f1f1f1f 30321f44 49205465 73742f43 61726420 30361f1f 1f301c31 1f2d311f 32303135 31313036 32323130 35341c1f 1c1c1c53 49474e53 54415455 533d4e1f 54433d35 30334144 32454536 30463041 3537371f 5456523d 30383030 30303830 30301f41 49443d41 30303030 30303030 34313031 301f5453 493d4538 30301f41 54433d30 3031341f 4150504c 41423d4d 41535445 52434152 441f4150 50504e3d 4d617374 65724361 72644372 65646974 1f43564d 3d310302";


            
//            NSString *responseString = @"02301c54 30311c31 2e33321c 30303030 30301c4f 4b1c3030 1f415050 524f5641 4c1f3334 38393838 1f353230 31313338 32333430 331f1f31 1c30311c 38333930 1f301f30 1f301f30 1f301f1f 1c343131 311f341f 31323235 1f1f1f1f 30321f44 49205465 73742f43 61726420 30361f1f 1f301c31 301f311f 32303135 30373230 30393235 31361c1f 1c1c1c53 49474e53 54415455 533d341f 54433d38 44433931 44363642 33314446 3343451f 5456523d 30383030 30303830 30301f41 49443d41 30303030 30303030 34313031 301f5453 493d4538 30301f41 54433d30 3030351f 4150504c 41423d4d 41535445 52434152 441f4150 50504e3d 4d617374 65724361 72644372 65646974 0327";
            
//            NSString *responseString = @"02301c54 30311c31 2e33321c 30303030 30301c4f 4b1c3030 1f415050 524f5641 4c1f3334 38393838 1f353230 31313338 32333430 331f1f31 1c30311c 38333930 1f301f30 1f301f30 1f301f1f 1c343131 311f341f 31323235 1f1f1f1f 30321f44 49205465 73742f43 61726420 30361f1f 1f301c31 301f311f 32303135 30373230 30393235 31361c1f 1c1c1c53 49474e53 54415455 533d341f 54433d38 44433931 44363642 33314446 3343451f 5456523d 30383030 30303830 30301f41 49443d41 30303030 30303030 34313031 301f5453 493d4538 30301f41 54433d30 3030351f 4150504c 41423d4d 41535445 52434152 441f4150 50504e3d 4d617374 65724361 72644372 65646974 0327";

            // Get Signature
//            NSString *responseString = @"02301c41 30391c31 2e33321c 30303030 30301c4f 4b1c313233 1c313233 1c  31302C3130305E32302C35305E35302C36305E37302C3130305E302C36353533355E32302C32305E3130302C3130305E3131302C3130305E3132302C35305E3133302C305E3134302C37357E  03 45";


//            NSString *responseString = @"02301c54 30311c31 2e33321c 31303030 30321c41 424f5254 45440330";
            
//            NSString *responseString = @"02301c54 30311c31 2e33321c 31303030 30321c41 424f5254 45440330";

            // GetVariableResponse
//            NSString *responseString = @"02301c4130331c313032351c3030303030301c4f4f1c4E0330";

            simulatedResponseData = [self dataFromSimulatedResponseString:responseString];
        }
            break;
         case PDResponseInitialize:
        {
            NSString *responseString = @"02301c41 30311c31 2e33321c 30303030 30301c30 313233 313235 303731";
            simulatedResponseData = [self dataFromSimulatedResponseString:responseString];
        }
            break;
         case PDResponseDoSignature:
        {
            NSString *responseString = @"02301c41 32311c31 2e33321c 30303030 30301c";
            simulatedResponseData = [self dataFromSimulatedResponseString:responseString];
        }
            break;
        case PDResponseDoCash:
        {
            NSString *responseString = @"02301c54 30311c31 2e33331c 30303030 30301c4f 4b1c3030 1f415050 524f5641 4c1f3630 30333641 1f353334 34313738 33313736 391f1f32 341c3137 1c353335 1f301f30 1f301f30 1f301f1f 1c303131 391f301f 31323232 1f1f1f1f 30311f1f 1f1f311c 32311f41 43313231 30313530 32333234 301f3230 31353132 31303033 34323137 1c1f1c1c 1c54433d 37373838 45333644 45453241 45344436 1f545652 3d303830 30303038 3030301f 4149443d 41303030 30303030 30333130 31301f54 53493d46 3830301f 4154433d 30303143 1f415050 4c41423d 56697361 20437265 6469741f 41505050 4e3d5669 73612043 72656469 741f4356 4d3d3603 3e";
            simulatedResponseData = [self dataFromSimulatedResponseString:responseString];
        }
            break;
        case PDResponseGetSignature:
        {
            NSString *responseString = @"02301c41 30391c31 2e33321c 30303030 30301c4f 4b1c313233 1c313233 1c  31302C3130305E32302C35305E35302C36305E37302C3130305E302C36353533355E32302C32305E3130302C3130305E3131302C3130305E3132302C35305E3133302C305E3134302C37357E  03 45";
            simulatedResponseData = [self dataFromSimulatedResponseString:responseString];
        }
            break;
        default:
            break;
    }
    
    data = [simulatedResponseData mutableCopy];
    if (simulatedResponseData) {
        [self connectionDidFinishLoading:nil];
    } else {
        NSLog(@"No simulation available for response code = %d", SIMULATE_RESPONSE_CODE);
        [_paxDeviceDelegate paxDevice:self failed:nil response:nil];
    }
}
#endif
@end
