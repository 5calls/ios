@import Foundation;

@class CPDLibrary;

@interface CPDCocoaPodsLibrariesLoader : NSObject

+ (NSArray <CPDLibrary *> *)loadAcknowledgementsWithBundle:(NSBundle *)bundle;

@end
