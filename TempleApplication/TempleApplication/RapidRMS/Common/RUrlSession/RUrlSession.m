//
//  PetroComHandler.m
//  NSURLSession
//
//  Created by Siya10 on 27/03/17.
//  Copyright © 2017 Siya10. All rights reserved.
//

#import "RUrlSession.h"

@interface RUrlSession ()
// Properties for
@property (nonatomic) NSURLSession *session;
@property (nonatomic) NSOperationQueue *queue;
@property (nonatomic) NSURLSessionConfiguration *configuration;
@end

@implementation RUrlSession

- (instancetype)init{
    if(!self){
        self = [super init];
    }
    return [self initWithTimeOut:10];
}
-(instancetype)initWithTimeOut:(NSInteger)timeOut{
    if(!self){
        self = [super init];
    }
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    configuration.requestCachePolicy = NSURLRequestUseProtocolCachePolicy;
    configuration.timeoutIntervalForRequest = timeOut;
    return [self initWithConfiguration:configuration];
}
-(instancetype)initWithConfiguration:(NSURLSessionConfiguration*)configuration{
    if(!self){
        self = [super init];
    }
    _queue.name = @"pumpOperationsQueue";
    _queue.maxConcurrentOperationCount = 1;
    _queue.qualityOfService = NSQualityOfServiceBackground;
    self.session = [NSURLSession sessionWithConfiguration:configuration delegate:nil delegateQueue:_queue];
    return self;
}
#pragma mark - send GET Request Method -
- (void)sendGETRequest:(NSString*)strURL petroHandler:(RUrlSessionHandler)petroHandler{
    NSURLRequest *request = [self _GETRequest:strURL];
    [[self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            petroHandler(data,error);
        }];
    }] resume];
}
- (void)sendGETRequest:(NSString*)strURL withParameters:(NSDictionary*)parameters petroHandler:(RUrlSessionHandler)petroHandler{
    
    NSURLRequest *request = [self _GETRequest:strURL withParameters:parameters];
    [[self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        petroHandler(data,error);
    }] resume];
}
- (void)sendGETRequest:(NSString*)strURL withParameters:(NSDictionary*)parameters withHeaders:(NSDictionary*)headers petroHandler:(RUrlSessionHandler)petroHandler{
    
    NSURLRequest *request = [self _GETRequest:strURL withParameters:parameters withHeaders:headers];
    [[self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        petroHandler(data,error);
    }] resume];
}

#pragma mark - GET Request Method -
- (NSURLRequest*)_GETRequest:(NSString*)strURL {
    return [NSURLRequest requestWithURL:[NSURL URLWithString:strURL]];
}
- (NSURLRequest*)_GETRequest:(NSString*)strURL withParameters:(NSDictionary*)parameters {
    
    NSURLComponents *components = [NSURLComponents componentsWithString:strURL];
    NSMutableArray *queryItems = [NSMutableArray array];
    for (NSString *key in parameters) {
        [queryItems addObject:[NSURLQueryItem queryItemWithName:key value:parameters[key]]];
    }
    components.queryItems = queryItems;
    
    NSURLRequest *req = [self _GETRequest:components.URL.absoluteString];
    
    return req;
}
- (NSURLRequest*)_GETRequest:(NSString*)strURL withParameters:(NSDictionary*)parameters withHeaders:(NSDictionary*)headers {
    NSMutableURLRequest *req = [self _GETRequest:strURL withParameters:parameters].mutableCopy;
    for (NSString *key in parameters) {
        [req setValue:headers[key] forHTTPHeaderField:key];
    }
    return req;
}


#pragma mark - send POST Request Method -
- (void)sendPOSTRequest:(NSString*)strURL petroHandler:(RUrlSessionHandler)petroHandler{
    NSURLRequest *request = [self _POSTRequest:strURL];
    [[self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        petroHandler(data,error);
    }] resume];
}
- (void)sendPOSTRequest:(NSString*)strURL withParameters:(NSDictionary*)parameters petroHandler:(RUrlSessionHandler)petroHandler{
    
    NSURLRequest *request = [self _POSTRequest:strURL withParameters:parameters];
    [[self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        petroHandler(data,error);
    }] resume];
}
- (void)sendPOSTRequest:(NSString*)strURL withParameters:(NSDictionary*)parameters withHeaders:(NSDictionary*)headers petroHandler:(RUrlSessionHandler)petroHandler{
    
    NSURLRequest *request = [self _POSTRequest:strURL withParameters:parameters withHeaders:headers];
    [[self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        petroHandler(data,error);
    }] resume];
}

#pragma mark - GET Request Method -
- (NSMutableURLRequest *)_POSTRequest:(NSString*)strURL {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:strURL]];
    [request setHTTPMethod:@"POST"];
    return request;
}
- (NSMutableURLRequest *)_POSTRequest:(NSString*)strURL withParameters:(NSDictionary*)parameters {

    NSURLComponents *components = [NSURLComponents componentsWithString:strURL];
    NSData *requestData = [NSJSONSerialization dataWithJSONObject:parameters options:NSJSONWritingPrettyPrinted error:nil];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[requestData length]];
    
    NSMutableURLRequest *req = [self _POSTRequest:components.URL.absoluteString];
    [req setHTTPMethod:@"POST"];
    [req setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [req setHTTPBody:requestData];
    
    return req;
}

- (NSURLRequest*)_POSTRequest:(NSString*)strURL withParameters:(NSDictionary*)parameters withHeaders:(NSDictionary*)headers {
    NSMutableURLRequest *req = [self _POSTRequest:strURL withParameters:parameters].mutableCopy;
    for (NSString *key in parameters) {
        [req setValue:headers[key] forHTTPHeaderField:key];
    }
    [req setHTTPMethod:@"POST"];
    NSData *requestData = [NSJSONSerialization dataWithJSONObject:parameters options:NSJSONWritingPrettyPrinted error:nil];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[requestData length]];
    [req setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [req setHTTPBody:requestData];
    
    return req;
}


@end
