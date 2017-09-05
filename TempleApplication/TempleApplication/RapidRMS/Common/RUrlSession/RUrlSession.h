//
//  PetroComHandler.h
//  NSURLSession
//
//  Created by Siya10 on 27/03/17.
//  Copyright © 2017 Siya10. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^RUrlSessionHandler)(id response, NSError *error);

@interface RUrlSession : NSObject

// Implement this method
-(instancetype)init;
-(instancetype)initWithTimeOut:(NSInteger)timeOut;
-(instancetype)initWithConfiguration:(NSURLSessionConfiguration*)configuration;

- (void)sendGETRequest:(NSString*)strURL petroHandler:(RUrlSessionHandler)petroHandler;
- (void)sendGETRequest:(NSString*)strURL withParameters:(NSDictionary*)parameters petroHandler:(RUrlSessionHandler)petroHandler;
- (void)sendGETRequest:(NSString*)strURL withParameters:(NSDictionary*)parameters withHeaders:(NSDictionary*)headers petroHandler:(RUrlSessionHandler)petroHandler;

- (void)sendPOSTRequest:(NSString*)strURL petroHandler:(RUrlSessionHandler)petroHandler;
- (void)sendPOSTRequest:(NSString*)strURL withParameters:(NSDictionary*)parameters petroHandler:(RUrlSessionHandler)petroHandler;
- (void)sendPOSTRequest:(NSString*)strURL withParameters:(NSDictionary*)parameters withHeaders:(NSDictionary*)headers petroHandler:(RUrlSessionHandler)petroHandler;
@end
