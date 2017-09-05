//
//  NSData+Encryption.m
//  Encription
//
//  Created by Siya Infotech on 20/06/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "NSData+Encryption.h"
#import <CommonCrypto/CommonCryptor.h>

#ifndef __has_feature
#define __has_feature(x) 0
#endif

@implementation NSData (Encryption)
- (NSData *)AES256EncryptWithKey:(NSString *)key {
    // 'key' should be 32 bytes for AES256,otherwise will be first 32 characters
    key=[self sha256:key length:32];
    char keyPtr[kCCKeySizeAES256+1]; // room for terminator (unused)
    bzero(keyPtr, sizeof(keyPtr)); // fill with zeroes (for padding)
    
    // fetch key data
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    NSUInteger dataLength = self.length;
    
    //See the doc: For block ciphers, the output size will always be less than or
    //equal to the input size plus the size of one block.
    //That's why we need to add the size of one block here
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    char initializationVector[32];
    memset(initializationVector, 0, sizeof(initializationVector));
    [@"Rapid_RMS" getCString:initializationVector maxLength:sizeof(initializationVector) encoding:NSUTF8StringEncoding];
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding,
                                          keyPtr, kCCKeySizeAES256,
                                          initializationVector /* initialization vector (optional) */,
                                          self.bytes, dataLength, /* input */
                                          buffer, bufferSize, /* output */
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        //the returned NSData takes ownership of the buffer and will free it on deallocation
        return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
    }
    
    free(buffer); //free the buffer;
    return nil;
}

- (NSData *)AES256DecryptWithKey:(NSString *)key {
    // 'key' should be 32 bytes for AES256,otherwise will be first 32 characters
    key=[self sha256:key length:32];
    char keyPtr[kCCKeySizeAES256+1]; // room for terminator (unused)
    bzero(keyPtr, sizeof(keyPtr)); // fill with zeroes (for padding)
    
    // fetch key data
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    NSUInteger dataLength = self.length;
    
    //See the doc: For block ciphers, the output size will always be less than or
    //equal to the input size plus the size of one block.
    //That's why we need to add the size of one block here
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    char initializationVector[32];
    memset(initializationVector, 0, sizeof(initializationVector));
    [@"Rapid_RMS" getCString:initializationVector maxLength:sizeof(initializationVector) encoding:NSUTF8StringEncoding];
//    char ivPointer[kCCBlockSizeAES128+2];
//    [@"Rapid_RMS" getCString:ivPointer maxLength:sizeof(ivPointer) encoding:NSUTF8StringEncoding];
    
    size_t numBytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding,
                                          keyPtr, kCCKeySizeAES256,
                                          initializationVector /* initialization vector (optional) */,
                                          self.bytes, dataLength, /* input */
                                          buffer, bufferSize, /* output */
                                          &numBytesDecrypted);
    
    if (cryptStatus == kCCSuccess) {
        //the returned NSData takes ownership of the buffer and will free it on deallocation
        return [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
    }
    
    free(buffer); //free the buffer;
    return nil;
}

- (NSString*) sha256:(NSString *)key length:(NSInteger) length{
    const char *s=[key cStringUsingEncoding:NSASCIIStringEncoding];
    NSData *keyData=[NSData dataWithBytes:s length:strlen(s)];
    
    uint8_t digest[CC_SHA256_DIGEST_LENGTH]={0};
    CC_SHA256(keyData.bytes, (CC_LONG)keyData.length, digest);
    NSData *out=[NSData dataWithBytes:digest length:CC_SHA256_DIGEST_LENGTH];
    NSString *hash=out.description;
    hash = [hash stringByReplacingOccurrencesOfString:@" " withString:@""];
    hash = [hash stringByReplacingOccurrencesOfString:@"<" withString:@""];
    hash = [hash stringByReplacingOccurrencesOfString:@">" withString:@""];
    
    if(length > hash.length)
    {
        return  hash;
    }
    else
    {
        return [hash substringToIndex:length];
    }
}
@end
