//
//  CustomerDisplayClient.h
//  CustomerDisplayApp
//
//  Created by Siya Infotech on 02/04/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DisplayDataReceiver <NSObject>

- (void)didConnectToPos:(NSString*)posName;
- (void)didDisconnectToPos:(NSString*)posName;

@end

@interface CustomerDisplayClient : NSObject

@property (nonatomic) BOOL isConnected;


- (instancetype)initWithDelegate:(id<DisplayDataReceiver>)displayReceiver NS_DESIGNATED_INITIALIZER;

- (void)openStreamsToNetService:(NSNetService *)netService;

- (void)reconnectToPreviousPos;

- (void)writeData:(NSData*)dataToSend;

@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *displayName;

- (void)disconnectFromDisplay;
@end
