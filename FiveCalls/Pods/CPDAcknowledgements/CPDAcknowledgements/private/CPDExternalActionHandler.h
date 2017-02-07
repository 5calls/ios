@import Foundation;

@class CPDLibrary;

@interface CPDExternalActionHandler : NSObject
+ (void)openActionForTwitterHandle:(NSString *)twitterUsername;
+ (void)openAddressInBrowser:(NSString *)address;
@end