#import "XMPPMessage.h"

@interface XMPPMessage (XEP_0333)

@property (NS_NONATOMIC_IOSONLY, readonly) BOOL hasChatMarker;

@property (NS_NONATOMIC_IOSONLY, readonly) BOOL hasMarkableChatMarker;
@property (NS_NONATOMIC_IOSONLY, readonly) BOOL hasReceivedChatMarker;
@property (NS_NONATOMIC_IOSONLY, readonly) BOOL hasDisplayedChatMarker;
@property (NS_NONATOMIC_IOSONLY, readonly) BOOL hasAcknowledgedChatMarker;

@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *chatMarker;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *chatMarkerID;

- (void)addMarkableChatMarker;
- (void)addReceivedChatMarkerWithID:(NSString *)elementID;
- (void)addDisplayedChatMarkerWithID:(NSString *)elementID;
- (void)addAcknowledgedChatMarkerWithID:(NSString *)elementID;

@property (NS_NONATOMIC_IOSONLY, readonly, copy) XMPPMessage *generateReceivedChatMarker;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) XMPPMessage *generateDisplayedChatMarker;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) XMPPMessage *generateAcknowledgedChatMarker;

- (XMPPMessage *)generateReceivedChatMarkerIncludingThread:(BOOL)includingThread;
- (XMPPMessage *)generateDisplayedChatMarkerIncludingThread:(BOOL)includingThread;
- (XMPPMessage *)generateAcknowledgedChatMarkerIncludingThread:(BOOL)includingThread;

@end
