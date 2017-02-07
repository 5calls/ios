#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// A class that represents an individual's contributions to the app
/// These are presented as tableview cells with a title and a subtitle

/// Optionally you can set an avatar address, and CPDAcknowledgements
/// will include a round thumbnail for them.

@interface CPDContribution : NSObject

/// Usual inits
- (instancetype)initWithName:(NSString *)name websiteAddress:(NSString * _Nullable)address role:(NSString *)role;

/// Name of the contributor: .e.g Fabio Pelosin
@property (nonatomic, copy, readonly) NSString *name;

/// Website address representing the contributor: .e.g https://orta.io
/// if one is not set, you cannot tap on the contributor

@property (nonatomic, copy, readonly) NSString * _Nullable websiteAddress;

/// Responsibility in their part of shipping your app
@property (nonatomic, copy, readonly) NSString *role;

/// Optional avatar url which will be grabbed asynchronously
@property (nonatomic, copy) NSString * _Nullable avatarAddress;

@end

NS_ASSUME_NONNULL_END
