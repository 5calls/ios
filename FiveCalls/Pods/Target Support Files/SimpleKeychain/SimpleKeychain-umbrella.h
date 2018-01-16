#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "A0SimpleKeychain+KeyPair.h"
#import "A0SimpleKeychain.h"
#import "SimpleKeychain.h"

FOUNDATION_EXPORT double SimpleKeychainVersionNumber;
FOUNDATION_EXPORT const unsigned char SimpleKeychainVersionString[];

