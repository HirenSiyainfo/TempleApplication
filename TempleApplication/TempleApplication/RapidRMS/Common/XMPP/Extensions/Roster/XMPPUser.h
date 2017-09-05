#import <Foundation/Foundation.h>
#import "XMPP.h"

@protocol XMPPResource;


@protocol XMPPUser <NSObject>
@required

@property (NS_NONATOMIC_IOSONLY, readonly, copy) XMPPJID *jid;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *nickname;

@property (NS_NONATOMIC_IOSONLY, getter=isOnline, readonly) BOOL online;
@property (NS_NONATOMIC_IOSONLY, getter=isPendingApproval, readonly) BOOL pendingApproval;

@property (NS_NONATOMIC_IOSONLY, readonly, strong) id<XMPPResource> primaryResource;
- (id <XMPPResource>)resourceForJID:(XMPPJID *)jid;

@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSArray *allResources;

@end
