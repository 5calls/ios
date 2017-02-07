@import UIKit;

NS_ASSUME_NONNULL_BEGIN

@class CPDLibrary;

@interface CPDLibraryDetailViewController : UIViewController

- (instancetype)initWithLibrary:(CPDLibrary *)library;

@property (readwrite, nonatomic, copy) NSString * _Nullable HTML;
@property (readwrite, nonatomic, copy) NSString * _Nullable CSS;
@property (readwrite, nonatomic, copy) NSString * _Nullable headerHTML;

@end

NS_ASSUME_NONNULL_END