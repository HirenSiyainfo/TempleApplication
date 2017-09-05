#import <Foundation/Foundation.h>

@interface NSData (XMPP)

@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSData *xmpp_md5Digest;

@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSData *xmpp_sha1Digest;

@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *xmpp_hexStringValue;

@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *xmpp_base64Encoded;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSData *xmpp_base64Decoded;

@property (NS_NONATOMIC_IOSONLY, readonly) BOOL xmpp_isJPEG;
@property (NS_NONATOMIC_IOSONLY, readonly) BOOL xmpp_isPNG;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *xmpp_imageType;

@end

#ifndef XMPP_EXCLUDE_DEPRECATED

#define XMPP_DEPRECATED($message) __attribute__((deprecated($message)))

@interface NSData (XMPPDeprecated)
- (NSData *)md5Digest XMPP_DEPRECATED("Use -xmpp_md5Digest");
- (NSData *)sha1Digest XMPP_DEPRECATED("Use -xmpp_sha1Digest");
- (NSString *)hexStringValue XMPP_DEPRECATED("Use -xmpp_hexStringValue");
- (NSString *)base64Encoded XMPP_DEPRECATED("Use -xmpp_base64Encoded");
- (NSData *)base64Decoded XMPP_DEPRECATED("Use -xmpp_base64Decoded");
@end

#undef XMPP_DEPRECATED

#endif
