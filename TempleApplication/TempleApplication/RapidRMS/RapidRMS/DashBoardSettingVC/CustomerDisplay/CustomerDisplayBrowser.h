//
//  PosServiceBrowser.h
//  CustomerDisplayApp
//
//  Created by Siya Infotech on 02/04/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CustomerDisplayBrowserDelegate <NSObject>

- (void)didFindPos:(NSNetService*)posService;

@optional
- (void)didRemovePos:(NSNetService*)posService;

@end

@interface CustomerDisplayBrowser : NSObject
- (instancetype)initWithDelegate:(id<CustomerDisplayBrowserDelegate>)customerDisplayBrowserDelegate NS_DESIGNATED_INITIALIZER;

- (void)stopBrowsing;
@end
