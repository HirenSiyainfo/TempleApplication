//
// Keychain.h
//
// Based on code by Michael Mayo at http://overhrd.com/?p=208
//
// Created by Frank Kim on 1/3/11.
//

#import "Keychain.h"
#import <Security/Security.h>

@implementation Keychain

+ (void)saveString:(NSString *)inputString forKey:(NSString	*)account {
	NSAssert(account != nil, @"Invalid account");
	NSAssert(inputString != nil, @"Invalid string");
	
	NSMutableDictionary *query = [NSMutableDictionary dictionary];
	
	query[(id)kSecClass] = (id)kSecClassGenericPassword;
	query[(id)kSecAttrAccount] = account;
	query[(id)kSecAttrAccessible] = (id)kSecAttrAccessibleWhenUnlocked;

	
	OSStatus error = SecItemCopyMatching((CFDictionaryRef)query, NULL);
	if (error == errSecSuccess) {
		// do update
		NSDictionary *attributesToUpdate = @{(id)kSecValueData: [inputString dataUsingEncoding:NSUTF8StringEncoding]};
		
		SecItemUpdate((CFDictionaryRef)query, (CFDictionaryRef)attributesToUpdate);
		//NSAssert1(error == errSecSuccess, @"SecItemUpdate failed: %d", error);
	}
    else if (error == errSecItemNotFound) {
		// do add
		query[(id)kSecValueData] = [inputString dataUsingEncoding:NSUTF8StringEncoding];
		
		SecItemAdd((CFDictionaryRef)query, NULL);
		//NSAssert1(error == errSecSuccess, @"SecItemAdd failed: %d", error);
	}
    else {
		//NSAssert1(NO, @"SecItemCopyMatching failed: %d", error);
	}
}

+ (NSString *)getStringForKey:(NSString *)account {
	NSAssert(account != nil, @"Invalid account");
	
	NSMutableDictionary *query = [NSMutableDictionary dictionary];

	query[(id)kSecClass] = (id)kSecClassGenericPassword;
	query[(id)kSecAttrAccount] = account;
	query[(id)kSecReturnData] = (id)kCFBooleanTrue;

	NSData *dataFromKeychain = nil;
	OSStatus error = SecItemCopyMatching((CFDictionaryRef)query, (CFTypeRef *)&dataFromKeychain);
	
	NSString *stringToReturn = nil;
	if (error == errSecSuccess) {
		stringToReturn = [[[NSString alloc] initWithData:dataFromKeychain encoding:NSUTF8StringEncoding] autorelease];
	}
	[dataFromKeychain release];
	
	return stringToReturn;
}

+ (void)deleteStringForKey:(NSString *)account {
	NSAssert(account != nil, @"Invalid account");
	NSMutableDictionary *query = [NSMutableDictionary dictionary];
	
	query[(id)kSecClass] = (id)kSecClassGenericPassword;
	query[(id)kSecAttrAccount] = account;
	OSStatus status = SecItemDelete((CFDictionaryRef)query);
	if (status != errSecSuccess) {
	}
}

@end
