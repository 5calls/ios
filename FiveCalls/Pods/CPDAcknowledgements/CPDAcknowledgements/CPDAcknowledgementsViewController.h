@import UIKit;

NS_ASSUME_NONNULL_BEGIN

@class CPDStyle, CPDLibrary, CPDContribution;

/// The main view controller, and the only one that is a part of the public API.
/// This view controller takes a collection of acknowledgements and contributors and presents information about them.

@interface CPDAcknowledgementsViewController : UITableViewController

/// This will assume that you have the plugin `cocoapods-acknowledgements` installed and running on a `pod install`,
/// and will pull all the library metadata from that. The style can be used to customize the look and feel of a library's
/// information page.

- (instancetype)initWithStyle:(CPDStyle * _Nullable )style;

/// If you put `nil` in contributions the view controller will assume that you have the plugin `cocoapods-acknowledgements`
/// installed and running on a `pod install`, and will pull all the library metadata from that.
/// You can pass in a collection of `CPDContribution`s to provide individual contributions outside of libraries.
/// The style can be used to customize the look and feel of a library's information page.

- (instancetype)initWithStyle:(CPDStyle * _Nullable )style acknowledgements:(NSArray <CPDLibrary *>* _Nullable )acknowledgements contributions:(NSArray <CPDContribution *>* _Nullable )contributions;

@end

NS_ASSUME_NONNULL_END
