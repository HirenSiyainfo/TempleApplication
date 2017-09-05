#import <Foundation/Foundation.h>
#import "XMPPMessage.h"


@interface XMPPMessage (XEP_0184)

@property (NS_NONATOMIC_IOSONLY, readonly) BOOL hasReceiptRequest;
@property (NS_NONATOMIC_IOSONLY, readonly) BOOL hasReceiptResponse;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *receiptResponseID;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) XMPPMessage *generateReceiptResponse;

- (void)addReceiptRequest;

@end
