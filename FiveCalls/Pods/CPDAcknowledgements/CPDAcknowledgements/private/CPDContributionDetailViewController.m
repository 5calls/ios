#import "CPDContributionDetailViewController.h"
#import "CPDContribution.h"
@import WebKit;

@interface CPDContributionDetailViewController () <WKNavigationDelegate, UIAlertViewDelegate>
@property (nonatomic, strong) CPDContribution *contribution;
@property (nonatomic, strong) NSURL *urlForAlertView;
@end

@implementation CPDContributionDetailViewController

- (id)initWithContribution:(CPDContribution *)contribution
{
    if(!contribution.websiteAddress){
        @throw @"The contribution needs to include a web address.";
    }

    self = [super init];
    if (!self) return nil;

    _contribution = contribution;

    return self;
}

- (void)loadView
{
    WKWebView *webView = [[WKWebView alloc] init];
    self.view = webView;

    webView.navigationDelegate = self;
    if([webView respondsToSelector:@selector(scrollView)])
        webView.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal;

    NSURL *url = [NSURL URLWithString:self.contribution.websiteAddress];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [webView loadRequest:request];

	[self showSpinnerInNavigationBar];
}


- (void)showSpinnerInNavigationBar
{
	UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	[indicator startAnimating];
	self.navigationItem.titleView = indicator;
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    
    if (navigationAction.navigationType == WKNavigationTypeLinkActivated) {
        NSString *title = NSLocalizedString(@"Open in Safari", @"Open in Safari popover title");
        NSString *messageFormat = NSLocalizedString(@"Open '%@' in Safari", @"Open in Safari popover body format");
        NSString *message = [NSString stringWithFormat:messageFormat, navigationAction.request.URL.absoluteString];
        self.urlForAlertView = navigationAction.request.URL;
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Open in Safari", nil];
        [alertView show];
        
        decisionHandler(WKNavigationActionPolicyCancel);
    }
    
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
	self.navigationItem.titleView = nil;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex != 0) {
        [[UIApplication sharedApplication] openURL:self.urlForAlertView];
    }
}


@end