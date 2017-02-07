#import "CPDContribution.h"
#import "CPDLibrary.h"
#import "CPDExternalActionHandler.h"

@implementation CPDLibrary

- (instancetype)initWithCocoaPodsMetadataPlistDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (!self) return  nil;

    _title = [dictionary[@"name"] copy];
    _licenseBody = [dictionary[@"licenseText"] copy];
    _licenseType = [dictionary[@"licenseType"] copy];

    _socialMediaAddress = [dictionary[@"socialMediaURL"] copy];
    _libraryDescription = [dictionary[@"description"] copy];
    _summary = [dictionary[@"summary"] copy];
    _version = [dictionary[@"version"] copy];

    _authors = [self authorsWithObject:dictionary[@"authors"]];

    return self;
}

- (NSArray *)authorsWithObject:(id)object
{
    if ([object isKindOfClass:NSDictionary.class]){
        NSMutableArray *authors = [NSMutableArray array];

        [object enumerateKeysAndObjectsUsingBlock:^(NSString *name, NSString* email, BOOL *stop) {
            CPDContribution *contribution = [[CPDContribution alloc] initWithName:name websiteAddress:nil role:@""];
            [authors addObject:contribution];
        }];

        return authors;
    }

    if ([object isKindOfClass:NSString.class]){
        return @[[[CPDContribution alloc] initWithName:object websiteAddress:nil role:@""] ];
    }

    return nil;
}

- (NSString *)twitterHandle
{
    if ([self.socialMediaAddress hasPrefix:@"https://twitter"]){
        return [[self.socialMediaAddress componentsSeparatedByString:@"/"] lastObject];
    }
    return nil;
}

- (BOOL)hasActions
{
    return self.websiteAddress.length > 0 || [self.socialMediaAddress hasPrefix:@"https://twitter"];
}

- (NSDictionary *)actionsWithSelectors
{
    return @{
        NSLocalizedString(@"Open Website", @"Open Website alert text"): NSStringFromSelector(@selector(openLibraryWebsite)),
        [NSString stringWithFormat:@"@%@", self.twitterHandle]: NSStringFromSelector(@selector(openTwitterPage)),
    };
}

- (NSArray *)actionTitlesForLibrary
{
    NSMutableArray *actionTitles = [NSMutableArray array];
    if (self.websiteAddress.length > 0){
        [actionTitles addObject:NSLocalizedString(@"Open Website", @"Open Website alert text")];
    }

    if ([self.socialMediaAddress hasPrefix:@"https://twitter"]){
        [actionTitles addObject:[@"@" stringByAppendingString:self.twitterHandle]];
    }

    return actionTitles;
}

- (void)performActionAtIndex:(NSInteger)index
{
    if (self.websiteAddress.length > 0) { index--; }

    NSString *title = self.actionTitlesForLibrary[index];
    NSString *selectorString = self.actionsWithSelectors[title];
    SEL action = NSSelectorFromString(selectorString);

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [self performSelector:action];
#pragma clang diagnostic pop
}

- (void)openTwitterPage
{
    [CPDExternalActionHandler openActionForTwitterHandle:self.twitterHandle];
}

- (void)openLibraryWebsite
{
    [CPDExternalActionHandler openAddressInBrowser:self.websiteAddress];
}

@end
