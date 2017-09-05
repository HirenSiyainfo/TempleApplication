#import "XMPPMessage.h"

@interface XMPPMessage (XEP_0308)

@property (NS_NONATOMIC_IOSONLY, getter=isMessageCorrection, readonly) BOOL messageCorrection;

@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *correctedMessageID;

- (void)addMessageCorrectionWithID:(NSString *)messageCorrectionID;

- (XMPPMessage *)generateCorrectionMessageWithID:(NSString *)elementID;
- (XMPPMessage *)generateCorrectionMessageWithID:(NSString *)elementID body:(NSString *)body;

@end
