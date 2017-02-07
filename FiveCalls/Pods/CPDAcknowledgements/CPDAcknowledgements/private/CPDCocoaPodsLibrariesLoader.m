#import "CPDCocoaPodsLibrariesLoader.h"
#import "CPDLibrary.h"

@implementation CPDCocoaPodsLibrariesLoader

+ (NSArray <CPDLibrary *>*)loadAcknowledgementsWithBundle:(NSBundle *)bundle;
{
    NSString *path = [self pathForFirstFileWithSuffix:@"-metadata.plist" inBundle:bundle];
    NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:path];
    return [self acknowledgementsFromDictionary:dictionary];
}

+ (NSArray *)acknowledgementsFromDictionary:(NSDictionary *)dictionary
{
    NSMutableArray *acknowledgements = [NSMutableArray array];
    NSArray *entries = dictionary[@"specs"];

    for (NSDictionary *entry in entries) {
        CPDLibrary *acknowledgement = [[CPDLibrary alloc] initWithCocoaPodsMetadataPlistDictionary:entry];

        // Feels a bit weird to be including itself in the list.
        if ([acknowledgement.title isEqualToString: @"CPDAcknowledgements"]) { continue; }

        [acknowledgements addObject:acknowledgement];
    }
    return acknowledgements;
}

+ (NSString *)pathForFirstFileWithSuffix:(NSString *)suffix inBundle:(NSBundle *)bundle
{
    NSString *resourcesPath = [bundle resourcePath];
    NSArray *resources = [self filesOfDirectoryAtPath:resourcesPath];
    NSUInteger index = [resources indexOfObjectPassingTest:^BOOL(NSString *path, NSUInteger idx, BOOL *stop) {
        return [path hasSuffix:suffix];
    }];

    if(index == NSNotFound) return nil;

    NSString *path = resources[index];
    return [resourcesPath stringByAppendingPathComponent:path];
}

+ (NSArray *)filesOfDirectoryAtPath:(NSString *)path
{
    NSFileManager *manager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *contents = [manager contentsOfDirectoryAtPath:path error:&error];
    if (error) {
        NSLog(@"Error getting resources in main bundle - %@", error.localizedDescription);
    }
    return contents;
}

@end
