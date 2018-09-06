@import Foundation;

NS_ASSUME_NONNULL_BEGIN

/// Allows you to customize the style for the the view
/// controllers for your libraries.

@interface CPDStyle : NSObject

/// HTML provided to the view controller, it's nothing too fancy
/// just a string which has a collection of string replacements on it.
///
/// This is the current default:
/// <html><head>{{STYLESHEET}}<meta name='viewport' content='width=device-width'></head><body>{{HEADER}}<p>{{BODY}}</p></body></html>

@property (nonatomic, copy) NSString * _Nullable libraryHTML;

/// CSS for styling your library
///
/// This is the current default:
/// <style> body{ font-family:HelveticaNeue; font-size: 14px; padding:12px; -webkit-user-select:none; }
// #summary{ font-size: 18px; }
// #version{ float: left; padding: 6px; }
// #license{ float: right; padding: 6px; } .clear-fix { clear:both };
// </style>

@property (nonatomic, copy) NSString * _Nullable libraryCSS;

/// HTML specifically for showing the header information about a library
///
/// This is the current default
/// <p id='summary'>{{SUMMARY}}</p><p id='version'>{{VERSION}}</p><p id='license'>{{SHORT_LICENSE}}</p> <br class='clear-fix'>

@property (nonatomic, copy) NSString * _Nullable libraryHeaderHTML;

@end

NS_ASSUME_NONNULL_END
