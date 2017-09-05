#import "XMPPMessage.h"

@interface XMPPMessage (XEP_0066)

- (void)addOutOfBandURL:(NSURL *)URL desc:(NSString *)desc;
- (void)addOutOfBandURI:(NSString *)URI desc:(NSString *)desc;

@property (NS_NONATOMIC_IOSONLY, readonly) BOOL hasOutOfBandData;

@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSURL *outOfBandURL;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *outOfBandURI;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *outOfBandDesc;

@end
