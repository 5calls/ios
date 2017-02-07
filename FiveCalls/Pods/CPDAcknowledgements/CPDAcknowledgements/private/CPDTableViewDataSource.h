@import UIKit;

@class CPDLibrary, CPDContribution;

@interface CPDTableViewDataSource : NSObject <UITableViewDataSource>

- (instancetype)initWithAcknowledgements:(NSArray <CPDLibrary *>*)acknowledgements contributions:(NSArray <CPDContribution *>*)contributions;

- (CPDLibrary *)acknowledgementAtIndexPath:(NSIndexPath *)indexPath;

- (CGFloat)heightForCellAtIndexPath:(NSIndexPath *)path;

@end
