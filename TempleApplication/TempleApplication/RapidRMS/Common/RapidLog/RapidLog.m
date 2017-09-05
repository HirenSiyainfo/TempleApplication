//
//  RapidLog.m
//  RapidRMS
//
//  Created by Siya10 on 15/09/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "RapidLog.h"
#import <sys/utsname.h>
#import "XMPP.h"
#import "RmsDbController.h"


@interface RapidLog ()

@property (nonatomic, strong) RmsDbController *rmsDbController;

@property (nonatomic, strong) NSRecursiveLock *rapidLogLock;


@end

@implementation RapidLog


-(instancetype)init
{
    self = [super init];
    if (self) {
        [self initializeOjbect];
    }
    return self;
}
-(void)initializeOjbect
{
    self.rmsDbController = [RmsDbController sharedRmsDbController];
}

#pragma mark Log Message
-(void)xmppMessagewithReq:(NSMutableDictionary *)logDictionary
{
    RapidAutoLock *lock = [[RapidAutoLock alloc] initWithLock:self.rapidLogLock];
    [self _xmppMessagewithReq:logDictionary];
    [lock unlock];
    
}
-(void)_xmppMessagewithReq:(NSMutableDictionary *)logDictionary{
    
    NSString *jsonString;
    NSMutableDictionary *dictParam = [[NSMutableDictionary alloc]init];
    dictParam[@"Database"] = (self.rmsDbController.globalDict)[@"DBName"];
    dictParam[@"RegId"] = (self.rmsDbController.globalDict)[@"RegisterId"];
    dictParam[@"SequenceNo"] = @(1);
    dictParam[@"BranchId"] = (self.rmsDbController.globalDict)[@"BranchID"];
    dictParam[@"Module"] = logDictionary[@"Module"];
    dictParam[@"Submodule"] = logDictionary[@"Submodule"];
    dictParam[@"RCR"] = logDictionary[@"RCR"];
    
    NSString *appVersion = [NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"];
    dictParam[@"Version"] = appVersion;
    NSString *osVersion = [[UIDevice currentDevice] systemVersion];
    dictParam[@"OSVersion"] = osVersion;
    
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceType = [NSString stringWithCString:systemInfo.machine
                                              encoding:NSUTF8StringEncoding];
    dictParam[@"DeviceType"] = deviceType;
    
    NSDate *date = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM/dd/yyyy hh:mm a";
    NSString *currentDateTime = [formatter stringFromDate:date];
    dictParam[@"LocalTime"] = currentDateTime;
    dictParam[@"MessageType"] = @(1);
    
    NSMutableDictionary *messageDict = [[NSMutableDictionary alloc]init];
    messageDict[@"Dir"] = logDictionary[@"Dir"];
    messageDict[@"Mode"] = @"WS";
    messageDict[@"InitiatedBy"] = logDictionary[@"InitiatedBy"];
    messageDict[@"ReqUrl"] = logDictionary[@"ReqUrl"];
    messageDict[@"Req"] = logDictionary[@"Req"];
    messageDict[@"Resp"] = logDictionary[@"Resp"];

    dictParam[@"Message"] = messageDict;
    
    jsonString = [self.rmsDbController jsonStringFromObject:dictParam];
    
    [self sendMessageToServer:jsonString];
}

#pragma mark Send Message To Server

-(void)sendMessageToServer:(NSString *)logmessage
{
    NSLog(@"XMPP Send Message = %@",logmessage);
    if([logmessage length] > 0)
    {
        NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
        [body setStringValue:logmessage];
        NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
        [message addAttributeWithName:@"type" stringValue:@"chat"];
        [message addAttributeWithName:@"to" stringValue:@"admin@ongocloud.com"];
        [message addChild:body];
        [self.rmsDbController.xmppStream sendElement:message];
    }
}

-(void)rapidLogWC:(NSMutableDictionary *)dictParam{
    
    RapidWebServiceConnection *rapidLogWC = [[RapidWebServiceConnection alloc] init];

    AsyncCompletionHandler asyncCompletionHandler = ^(id response, NSError *error) {
        [self regConfigrationResponse:response error:error];
    };
    
    NSMutableDictionary *dictMain = [[NSMutableDictionary alloc]init];
    [dictMain setObject:dictParam forKey:@"ObjInsertCreditCardTransaction"];

   rapidLogWC = [rapidLogWC initWithAsyncRequest:KURL actionName:@"InsertCreditCardTransactionLog" params:dictMain asyncCompletionHandler:asyncCompletionHandler];

}

- (void)regConfigrationResponse:(id)response error:(NSError *)error
{
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
           // NSMutableArray *responseArray = [self objectFromJsonString:response[@"Data"]];
            
        }
    }
}
-(id)objectFromJsonString:(NSString *)jsonString {
    NSError *error;
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    if (! jsonData) {
        return nil;
    }
    return [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves error:&error];
}
@end
