#import "CPDLibraryDetailViewController.h"
#import "CPDLibrary.h"

@import WebKit;

@interface CPDLibraryDetailViewController () <UIActionSheetDelegate>
@property (nonatomic, strong) WKWebView *view;
@property (readonly, nonatomic, strong) CPDLibrary *library;
@end

@implementation CPDLibraryDetailViewController

@dynamic view;

- (id)initWithLibrary:(CPDLibrary *)library
{
    self = [super init];
    if (!self) return nil;

    _library = library;
    self.title = _library.title;

    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if (self.library.hasActions) {
        UIBarButtonItem *shareButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareTapped:)];
        self.navigationItem.rightBarButtonItem = shareButton;
    }
}

- (void)shareTapped:(UIBarButtonItem *)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
    actionSheet.delegate = self;

    [self.library.actionTitlesForLibrary enumerateObjectsUsingBlock:^(NSString *title, NSUInteger idx, BOOL *stop) {
        [actionSheet addButtonWithTitle:title];
    }];

    [actionSheet addButtonWithTitle:@"Cancel"];
    [actionSheet setCancelButtonIndex:actionSheet.numberOfButtons - 1];
    [actionSheet showFromBarButtonItem:sender animated:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == actionSheet.cancelButtonIndex) return;

    [self.library performActionAtIndex:buttonIndex];
}

- (void)loadView
{
    self.view = [self createWebview];;
	[self openLicenseInWebview:self.view];
}

- (void)openLicenseInWebview:(WKWebView *)webView
{
	NSString *html = self.HTML ?: [self.class defaultHTMLTemplate];
    NSString *headerHTML = self.headerHTML ?: [self.class defaultHeaderTemplate];
	NSString *css = self.CSS ?: [self.class defaultCSS];
	NSString *renderedHTML = [self.class generatedHTMLWithHTML:html headerHTML:headerHTML CSS:css acknowledgement:self.library];

	[webView loadHTMLString:renderedHTML baseURL:nil];
}

- (WKWebView *)createWebview
{
    WKWebView *webView = [[WKWebView alloc] init];
    webView.backgroundColor = [UIColor whiteColor];
    webView.opaque = NO;
    webView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;


    if([webView respondsToSelector:@selector(scrollView)])
        webView.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal;

    return webView;
}

+ (NSString *)generatedHTMLWithHTML:(NSString *)html headerHTML:(NSString *)headerHTML CSS:(NSString *)css acknowledgement:(CPDLibrary *)acknowledgement
{
    NSMutableString *mutableHTML = [html mutableCopy];

    NSString *summary = acknowledgement.libraryDescription.length > 0 ? acknowledgement.libraryDescription : acknowledgement.summary;

    [mutableHTML replaceOccurrencesOfString:@"{{STYLESHEET}}" withString:css options:0 range:NSMakeRange(0, mutableHTML.length)];
    NSString *htmlLicense = [acknowledgement.licenseBody stringByReplacingOccurrencesOfString:@"\n\n" withString:@"</p><p>"];

    [mutableHTML replaceOccurrencesOfString:@"{{BODY}}" withString:htmlLicense options:0 range:NSMakeRange(0, mutableHTML.length)];
    [mutableHTML replaceOccurrencesOfString:@"{{HEADER}}" withString:headerHTML options:0 range:NSMakeRange(0, mutableHTML.length)];

    [mutableHTML replaceOccurrencesOfString:@"{{SUMMARY}}" withString:summary options:0 range:NSMakeRange(0, mutableHTML.length)];
    [mutableHTML replaceOccurrencesOfString:@"{{VERSION}}" withString:acknowledgement.version options:0 range:NSMakeRange(0, mutableHTML.length)];
    [mutableHTML replaceOccurrencesOfString:@"{{SHORT_LICENSE}}" withString:acknowledgement.licenseType options:0 range:NSMakeRange(0, mutableHTML.length)];

    return [mutableHTML copy];
}

+ (NSString *)defaultHTMLTemplate
{
    return @"<html><head>{{STYLESHEET}}<meta name='viewport' content='width=device-width'></head><body>{{HEADER}}<p>{{BODY}}</p></body></html>";
}


+ (NSString *)defaultHeaderTemplate
{
    return @"<p id='summary'>{{SUMMARY}}</p><p id='version'>{{VERSION}}</p><p id='license'>{{SHORT_LICENSE}}</p> <br class='clear-fix' />";
}

+ (NSString *)defaultCSS
{
    return @"<style> body{ font-family:HelveticaNeue; font-size: 14px; padding:12px; -webkit-user-select:none; } \
            #summary{ font-size: 18px; } \
            #version{ float: left; padding: 6px; } \
            #license{ float: right; padding: 6px; } .clear-fix { clear:both } ; </style>";
}

@end
