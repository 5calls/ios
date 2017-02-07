NS_ASSUME_NONNULL_BEGIN

@class CPDContribution;

/// A class that represents a library used in your application

@interface CPDLibrary : NSObject

/// Create a library given the default (as of CP 0.30) information
/// from the metadata.plist

- (instancetype)initWithCocoaPodsMetadataPlistDictionary:(NSDictionary *)dictionary;

/// Name of the pod
@property (readonly, nonatomic, copy) NSString *title;

/// Body text of the library's licence
@property (readonly, nonatomic, copy) NSString *licenseBody;

/// The name of the library's license
@property (readonly, nonatomic, copy) NSString *licenseType;

/// The libraries description
@property (readonly, nonatomic, copy) NSString * _Nullable summary;

/// People who have contributed to this library
@property (readonly, nonatomic, copy) NSArray <CPDContribution *> *authors;

/// Full URL of the social media end-point represented by hte library
@property (readonly, nonatomic, copy) NSString * _Nullable socialMediaAddress;

/// A longer description of the library
@property (readonly, nonatomic, copy) NSString * _Nullable libraryDescription;

/// The current version of the library
@property (readonly, nonatomic, copy) NSString *version;

/// The website representing the library
@property (readonly, nonatomic, copy) NSString * _Nullable websiteAddress;

/// Actionable titles for platform dependent views
- (NSArray *)actionTitlesForLibrary;

/// Perform actions from given titles
- (void)performActionAtIndex:(NSInteger)index;

/// Is it worth showing the popover based on the current available metadata?
- (BOOL)hasActions;

@end

NS_ASSUME_NONNULL_END
