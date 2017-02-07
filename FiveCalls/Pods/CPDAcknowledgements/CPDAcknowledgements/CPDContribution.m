#import "CPDContribution.h"

@implementation CPDContribution

- (id)initWithName:(NSString *)name websiteAddress:(NSString *)address role:(NSString *)role
{
    self = [super init];
    if(!self) return self;

    _name = name;
    _websiteAddress = address;
    _role = role;

    return self;
}

@end
