#import "CPDLibrary.h"
#import "CPDTableViewDataSource.h"
#import "CPDCocoaPodsLibrariesLoader.h"
#import "CPDAcknowledgementsViewController.h"
#import "CPDLibraryDetailViewController.h"
#import "CPDContribution.h"
#import "CPDContributionDetailViewController.h"
#import "CPDStyle.h"

@interface CPDAcknowledgementsViewController () <UITableViewDelegate>
@property (nonatomic, strong) CPDTableViewDataSource *dataSource;
@property (nonatomic, strong) CPDStyle *style;
@end

@implementation CPDAcknowledgementsViewController

- (instancetype)init
{
    return [self initWithStyle:nil];
}

- (instancetype)initWithStyle:(CPDStyle *)style
{
    return [self initWithStyle:style acknowledgements:nil contributions:nil];
}

- (instancetype)initWithStyle:(CPDStyle *)style acknowledgements:(NSArray <CPDLibrary *>*)acknowledgements contributions:(NSArray <CPDContribution *>*)contributions
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (!self) return nil;

    [self configureAcknowledgements:acknowledgements contributions:contributions];
    _style = style;

    self.title = @"Acknowledgements";

    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (!self) return nil;
    
    [self configureAcknowledgements:nil contributions:nil];
    
    self.title = @"Acknowledgements";
    
    return self;
}

- (void)configureAcknowledgements:(NSArray *)acknowledgements contributions:(NSArray *)contributions
{
    if(!acknowledgements){
        NSBundle *bundle = [NSBundle mainBundle];
        acknowledgements = [CPDCocoaPodsLibrariesLoader loadAcknowledgementsWithBundle:bundle];
    }
    
    _dataSource = [[CPDTableViewDataSource alloc] initWithAcknowledgements:acknowledgements contributions:contributions];
}

- (void)loadView
{
    [super loadView];
    self.tableView.dataSource = self.dataSource;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSAssert(self.navigationController, @"The AcknowledgementVC needs to be inside a navigation controller.");

}

#pragma mark UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    id acknowledgement = [self.dataSource acknowledgementAtIndexPath:indexPath];

    id detailController;
    if ([acknowledgement isKindOfClass:CPDLibrary.class]){
        detailController = [[CPDLibraryDetailViewController alloc] initWithLibrary:acknowledgement];
        [detailController setCSS:self.style.libraryCSS];
        [detailController setHTML:self.style.libraryHTML];
        [detailController setHeaderHTML:self.style.libraryHeaderHTML];

    } else if([acknowledgement isKindOfClass:CPDContribution.class]){
        CPDContribution *contribution = acknowledgement;
        if (contribution.websiteAddress){
            detailController = [[CPDContributionDetailViewController alloc] initWithContribution:contribution];
        }
    }

    [self.navigationController pushViewController:detailController animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.dataSource heightForCellAtIndexPath:indexPath];
}

@end
