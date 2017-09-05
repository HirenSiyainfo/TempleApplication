#import "XMPPModule.h"

@interface XMPPSoftwareVersion : XMPPModule

@property (copy,readonly) NSString *name;
@property (copy,readonly) NSString *version;
@property (copy,readonly) NSString *os;

- (instancetype)initWithDispatchQueue:(dispatch_queue_t)queue;

- (instancetype)initWithName:(NSString *)name
           version:(NSString *)version
                os:(NSString *)os
     dispatchQueue:(dispatch_queue_t)queue NS_DESIGNATED_INITIALIZER;

@end
