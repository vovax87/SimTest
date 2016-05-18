//
//  ProjectGlobals.m
//
//  Created by konstantin on 17/05/2012.
//  Copyright (c) 2012 KTTSoft. All rights reserved.
//

#import "ProjectGlobals.h"
#import "Constants.h"


BOOL PRJ_Is_iPad;
BOOL PRJ_Is_iPhone;
CGFloat PRJ_SystemVersion;

NSString *PRJ_userID;
NSString *PRJ_token;
NSString *PRJ_displayName;

//AVPlayer *videoPlayerGlobal;

NSString *PRJ_MovieSoundsDirectory;
NSURL *PRJ_MovieSoundsURL;
NSMutableArray *PRJ_MovieSoundsEditionsURLs;
NSMutableArray *PRJ_MovieSoundsEditionsNames;

BOOL PRJ_IsRecordingState;

static int initialized = 0;

void InitProjectGlobals(void) {
    
    if (initialized)
        return;
    
    initialized = 1;
    
    PRJ_SystemVersion = [[UIDevice currentDevice].systemVersion floatValue];
    
    PRJ_Is_iPad = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;
    PRJ_Is_iPhone = !PRJ_Is_iPad;

    PRJ_userID = PRJ_token = PRJ_displayName = nil;
    PRJ_MovieSoundsDirectory = @"MovieSoundsEditions";
    
    PRJ_IsRecordingState = NO;
    InitMovieSoundsEditions();
}





void ShowTitleErrorAlert(NSString *title, NSError *error) {
    
    if (error == nil)
        return;
    
    NSMutableString *errStr = [NSMutableString stringWithString: NSLocalizedString(@"Error", nil)];
    
    if (error.code)
        [errStr appendFormat:@": %ld", (long)error.code];
    
    // If the user info dictionary doesn’t contain a value for NSLocalizedDescriptionKey
    // error.localizedDescription is constructed from domain and code by default
    [errStr appendFormat:@"\n%@", error.localizedDescription];
    
    if (error.localizedFailureReason)
        [errStr appendFormat:@"\n%@", error.localizedFailureReason];
    
    if (error.localizedRecoverySuggestion)
        [errStr appendFormat:@"\n%@", error.localizedRecoverySuggestion];
    
    UIAlertController * alert =  [UIAlertController
                                  alertControllerWithTitle:title
                                  message:errStr
                                  preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction * action) {
                                                   [alert dismissViewControllerAnimated:YES completion:nil];
                                               }];
    [alert addAction:ok];
    
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];    
}

void ShowErrorAlert(NSError *error) {
    ShowTitleErrorAlert(nil, error);
}






void ShowTitleAlert(NSString *title, NSString *message) {
    UIAlertController * alert =  [UIAlertController
                                  alertControllerWithTitle:title
                                  message:message
                                  preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction * action) {
                                                   [alert dismissViewControllerAnimated:YES completion:nil];
                                               }];
    [alert addAction:ok];
    
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
}

void ShowAlert(NSString *message) {
    UIAlertController * alert =  [UIAlertController
                                  alertControllerWithTitle:@""
                                  message:message
                                  preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction * action) {
                                                   [alert dismissViewControllerAnimated:YES completion:nil];
                                               }];
    [alert addAction:ok];
    
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
}





// check for directory existance and create if it doesn't
void CreateDirectory(NSString *directory)
{
    NSFileManager *fm = [NSFileManager defaultManager];
    
    NSError * __autoreleasing error = nil;
    
    NSArray *urls = [fm URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask];
    
    if (urls.count == 0)
        return;
    
    NSURL *urlDir = [(NSURL*)urls[0] URLByAppendingPathComponent:directory];
    
    BOOL isDirectory = NO;
    
    if (![fm fileExistsAtPath:urlDir.path isDirectory:&isDirectory] || !isDirectory)
    {
        
        [fm createDirectoryAtURL:urlDir withIntermediateDirectories:YES attributes:nil error:&error];
        
        // sometimes directory is created but it returns FALSE (?) so check it simply once more
        if (![fm fileExistsAtPath:urlDir.path isDirectory:&isDirectory] || !isDirectory)
        {
            if (!error)
            {
                NSDictionary *userInfo = @{NSLocalizedDescriptionKey: LOCALIZED(@"Can not create local library directory")};
                error = [NSError errorWithDomain:urlDir.path code:0 userInfo:userInfo];
            }
            
            ShowErrorAlert(error);
        }
    }
}

// check for directory existance and create if it doesn't
BOOL CheckDirectory(NSString *directory)
{
    BOOL isExist = NO;
    NSFileManager *fm = [NSFileManager defaultManager];
    
    NSError * __autoreleasing error = nil;
    
    NSArray *urls = [fm URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask];
    
    if (urls.count == 0)
        return isExist;
    
    NSURL *urlDir = [(NSURL*)urls[0] URLByAppendingPathComponent:directory];
    
    BOOL isDirectory = NO;
    
    isExist = [fm fileExistsAtPath:urlDir.path isDirectory:&isDirectory] && isDirectory;
    
    if (!isExist)
    {
        [fm createDirectoryAtURL:urlDir withIntermediateDirectories:YES attributes:nil error:&error];
        
        // sometimes directory is created but it returns FALSE (?) so check it simply once more
        isExist = [fm fileExistsAtPath:urlDir.path isDirectory:&isDirectory] && isDirectory;
        
    }
    
    return isExist;
}

// check if MovieSounds directory exists and create it if doesn't; also fill SoundEditions arrays
void InitMovieSoundsEditions()
{
    PRJ_MovieSoundsURL = nil;
    PRJ_MovieSoundsEditionsURLs = nil;
    PRJ_MovieSoundsEditionsNames = nil;
    
    NSFileManager *fm = [NSFileManager defaultManager];
    
    NSError * __autoreleasing error = nil;
    
    NSArray *urls = [fm URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask];
    
    if (urls.count == 0)
        return;
    
    NSURL *urlDir = [(NSURL*)urls[0] URLByAppendingPathComponent:PRJ_MovieSoundsDirectory];
    
    BOOL isDirectory = NO;
    
    if (![fm fileExistsAtPath:urlDir.path isDirectory:&isDirectory] || !isDirectory)
    {
        [fm createDirectoryAtURL:urlDir withIntermediateDirectories:YES attributes:nil error:&error];
        
        // sometimes directory is created but it returns FALSE (?) so check it simply once more
        if (![fm fileExistsAtPath:urlDir.path isDirectory:&isDirectory] || !isDirectory)
        {
            if (!error)
            {
                NSDictionary *userInfo = @{NSLocalizedDescriptionKey: LOCALIZED(@"Can not create local library directory")};
                error = [NSError errorWithDomain:urlDir.path code:0 userInfo:userInfo];
            }
            
            ShowErrorAlert(error);
            return;
        }
    }
    
    PRJ_MovieSoundsURL = urlDir;
    NSLog(@"__Sound edition directory:%@", PRJ_MovieSoundsURL);
    
//    PRJ_MovieSoundsEditionsURLs = [NSMutableArray array];
//    PRJ_MovieSoundsEditionsNames = [NSMutableArray array];
    
//    NSArray *dirList = [fm contentsOfDirectoryAtURL:PRJ_MovieSoundsURL includingPropertiesForKeys:nil options:0 error:nil];
//
//    for (NSURL *url in dirList)
//    {
//        NSDictionary *attribDict = [fm attributesOfItemAtPath:url.path error:&error];
//        if ([attribDict[NSFileType] isEqualToString:NSFileTypeDirectory])
//        {
//            [PRJ_MovieSoundsEditionsURLs addObject:url];
//            [PRJ_MovieSoundsEditionsNames addObject:url.lastPathComponent];
//        }
//    }
    
//    if (!PRJ_MovieSoundsEditionsURLs.count)
//    {
//        NSURL *urlDefaultEdition = [PRJ_MovieSoundsURL URLByAppendingPathComponent:@"DefaultEdition"];
//        if ([fm createDirectoryAtURL:urlDefaultEdition withIntermediateDirectories:YES attributes:nil error:&error])
//        {
//            [PRJ_MovieSoundsEditionsURLs addObject:urlDefaultEdition];
//            [PRJ_MovieSoundsEditionsNames addObject:urlDefaultEdition.lastPathComponent];
//        }
//    }
    
}

///////
MovieSoundEdition* CreateMovieSoundEdition(NSString* editionName)
{
    MovieSoundEdition *edition = nil;
    NSFileManager *fm = [NSFileManager defaultManager];
    
    NSURL *urlEdition = [PRJ_MovieSoundsURL URLByAppendingPathComponent:editionName];
    NSError * __autoreleasing error;
    
    if ([fm createDirectoryAtURL:urlEdition withIntermediateDirectories:YES attributes:nil error:&error])
    {
//        [PRJ_MovieSoundsEditionsURLs addObject:urlEdition];
//        [PRJ_MovieSoundsEditionsNames addObject:urlEdition.lastPathComponent];
        
        edition = [[MovieSoundEdition alloc] init];
        edition.encodingDirectoryURL = urlEdition;
        edition.name = editionName;
    }
    
    return edition;
}

MovieSoundEdition* LoadMovieSoundEdition(NSString* editionName)
{
    MovieSoundEdition *edition = nil;
    NSFileManager *fm = [NSFileManager defaultManager];
    
    NSURL *urlEdition = [PRJ_MovieSoundsURL URLByAppendingPathComponent:editionName];
    
    BOOL isDirectory = NO;
    
    if ([fm fileExistsAtPath:urlEdition.path isDirectory:&isDirectory] && isDirectory)
    {
        edition = [MovieSoundEdition loadObjectFromURL:urlEdition];
    }
    
    return edition;
}






