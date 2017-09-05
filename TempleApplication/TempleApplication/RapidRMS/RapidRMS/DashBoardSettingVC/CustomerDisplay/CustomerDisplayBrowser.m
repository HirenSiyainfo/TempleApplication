//
//  PosServiceBrowser.m
//  CustomerDisplayApp
//
//  Created by Siya Infotech on 02/04/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "CustomerDisplayBrowser.h"

@interface CustomerDisplayBrowser () <NSNetServiceBrowserDelegate>
@property (nonatomic, strong, readwrite) NSNetServiceBrowser *  serviceBrowser;
@property (nonatomic, weak) id<CustomerDisplayBrowserDelegate> custServiceBrowserDelegate;

@end

@implementation CustomerDisplayBrowser

- (instancetype)initWithDelegate:(id<CustomerDisplayBrowserDelegate>)customerDisplayBrowserDelegate {
    self = [super init];
    if (self) {
        self.custServiceBrowserDelegate = customerDisplayBrowserDelegate;

        self.serviceBrowser = [[NSNetServiceBrowser alloc] init];
        self.serviceBrowser.delegate = self;
        [self.serviceBrowser searchForServicesOfType:@"_rapid_cust_Disp._tcp." inDomain:@"local"];
    }
    return self;
}

- (void)dealloc {
    [self.serviceBrowser setDelegate:nil];
    [self.serviceBrowser stop];
}

#pragma mark -
#pragma mark NSNetServiceBrowser delegate methods

// We broadcast the willChangeValueForKey: and didChangeValueForKey: for the NSTableView binding to work.

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindService:(NSNetService *)aNetService moreComing:(BOOL)moreComing {
#pragma unused(aNetServiceBrowser)
#pragma unused(moreComing)
//    if (![self.services containsObject:aNetService]) {
//        [self willChangeValueForKey:@"services"];
//        [self.services addObject:aNetService];
//        [self didChangeValueForKey:@"services"];
//    }
    [self.custServiceBrowserDelegate didFindPos:aNetService];
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didRemoveService:(NSNetService *)aNetService moreComing:(BOOL)moreComing {
#pragma unused(aNetServiceBrowser)
#pragma unused(moreComing)
//    if ([self.services containsObject:aNetService]) {
//        [self willChangeValueForKey:@"services"];
//        [self.services removeObject:aNetService];
//        [self didChangeValueForKey:@"services"];
//    }
    
    if ([self.custServiceBrowserDelegate respondsToSelector:@selector(didRemovePos:)]) {
        [self.custServiceBrowserDelegate didRemovePos:aNetService];
    }
}

- (void)stopBrowsing {
    [self.serviceBrowser stop];
}
@end
