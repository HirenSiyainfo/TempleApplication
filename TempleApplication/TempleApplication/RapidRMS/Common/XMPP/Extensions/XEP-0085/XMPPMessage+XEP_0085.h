#import <Foundation/Foundation.h>
#import "XMPPMessage.h"


@interface XMPPMessage (XEP_0085)

@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *chatState;

@property (NS_NONATOMIC_IOSONLY, readonly) BOOL hasChatState;

@property (NS_NONATOMIC_IOSONLY, readonly) BOOL hasActiveChatState;
@property (NS_NONATOMIC_IOSONLY, readonly) BOOL hasComposingChatState;
@property (NS_NONATOMIC_IOSONLY, readonly) BOOL hasPausedChatState;
@property (NS_NONATOMIC_IOSONLY, readonly) BOOL hasInactiveChatState;
@property (NS_NONATOMIC_IOSONLY, readonly) BOOL hasGoneChatState;

- (void)addActiveChatState;
- (void)addComposingChatState;
- (void)addPausedChatState;
- (void)addInactiveChatState;
- (void)addGoneChatState;

@end
