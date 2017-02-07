#import "CPDTableViewDataSource.h"
#import "CPDLibrary.h"
#import "CPDContribution.h"

static const NSString *CPDTitle = @"CPDTitle";
static const NSString *CPDEntries = @"CPDEntries";

@interface CPDTableViewDataSource()
@property (nonatomic, strong) NSMutableArray *sections;
@end

@implementation CPDTableViewDataSource

- (id)initWithAcknowledgements:(NSArray *)acknowledgements contributions:(NSArray *)contributions
{
    self = [super init];
    if (!self) return nil;

    _sections = [NSMutableArray array];

    if (contributions){
        [_sections addObject:@{
              CPDTitle: NSLocalizedString(@"Contributions", @"Contributions in detail view"),
            CPDEntries: contributions,
        }];
    }

    if (acknowledgements){
        [_sections addObject:@{
              CPDTitle: NSLocalizedString(@"Libraries", @"Libraries in detail view"),
            CPDEntries: acknowledgements,
        }];
    }

    return self;
}

#pragma mark UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.sections.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSDictionary *sectionInfo = self.sections[(NSUInteger) section];
    return sectionInfo[CPDTitle];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSDictionary *sectionInfo = self.sections[(NSUInteger) section];
    return [sectionInfo[CPDEntries] count];
}

- (CGFloat)heightForCellAtIndexPath:(NSIndexPath *)indexPath
{
    id item = [self acknowledgementAtIndexPath:indexPath];
    return [item isKindOfClass:CPDContribution.class] ? 60 : 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id item = [self acknowledgementAtIndexPath:indexPath];
    NSString *identifier = NSStringFromClass([item class]);

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
        cell.separatorInset = UIEdgeInsetsZero;
    }

    if ([item isKindOfClass:CPDLibrary.class]){
        cell.textLabel.text = [item title];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    } else if ([item isKindOfClass:CPDContribution.class]){
        [self configureCell:cell withContribution:item];
    }

    return cell;
}

- (void)configureCell:(UITableViewCell *)cell withContribution:(CPDContribution *)contribution
{
    cell.textLabel.text = [contribution name];
    cell.detailTextLabel.text = [contribution role];
    cell.detailTextLabel.textColor = [UIColor grayColor];

    BOOL supportsFullViewController = (contribution.websiteAddress != nil);
    cell.accessoryType = supportsFullViewController ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
    cell.selectionStyle = supportsFullViewController ? UITableViewCellSelectionStyleGray : UITableViewCellSelectionStyleNone;

    if ([contribution avatarAddress]){
        [self setImageAsyncForCell:cell contribution:contribution];
    }
}

- (void)setImageAsyncForCell:(UITableViewCell *)cell contribution:(CPDContribution *)contribution
{
    UIImageView *imageView = cell.imageView;
    imageView.layer.cornerRadius = 46;
    imageView.layer.masksToBounds = YES;
    imageView.transform = CGAffineTransformMakeScale(0.45, 0.45);

    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0ul);
    dispatch_async(queue, ^{
        NSURL *imageURL = [NSURL URLWithString:[contribution avatarAddress]];
        NSData *data = [NSData dataWithContentsOfURL:imageURL];
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImage *image = [UIImage imageWithData:data];
            imageView.image = image;
            [cell setNeedsLayout];
        });
    });
}

- (CPDLibrary *)acknowledgementAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *section = self.sections[(NSUInteger) indexPath.section];
    return section[CPDEntries][(NSUInteger) indexPath.row];
}

@end
