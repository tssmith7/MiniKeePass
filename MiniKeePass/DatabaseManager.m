/*
 * Copyright 2011-2012 Jason Rush and John Flanagan. All rights reserved.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#import "DatabaseManager.h"
#import "MiniKeePassAppDelegate.h"
#import "KeychainUtils.h"
#import "PasswordViewController.h"
#import "AppSettings.h"
#import "CloudManager.h"
#import "CloudFactory.h"

#import <MBProgressHUD/MBProgressHUD.h>

@implementation DatabaseManager

static DatabaseManager *sharedInstance;

+ (void)initialize {
    static BOOL initialized = NO;
    if (!initialized)     {
        initialized = YES;
        sharedInstance = [[DatabaseManager alloc] init];
    }
}

+ (DatabaseManager*)sharedInstance {
    return sharedInstance;
}

- (void)openDatabaseDocument:(NSString*)filename animated:(BOOL)animated isCloudBased:(BOOL)isCloudBased {
    
    if( isCloudBased ) {
        self.selectedFilename = [[[CloudFactory getCloudManager] getTempDir]
                                 stringByAppendingPathComponent:filename ];
    } else {
        self.selectedFilename = filename;
    }
    
    // Get the application delegate
    MiniKeePassAppDelegate *appDelegate = [MiniKeePassAppDelegate appDelegate];
    
    // Get the documents directory
    NSString *documentsDirectory = [MiniKeePassAppDelegate documentsDirectory];
    
    // Load the password and keyfile from the keychain
    NSString *password = [KeychainUtils stringForKey:self.selectedFilename
                                      andServiceName:KEYCHAIN_PASSWORDS_SERVICE];
    NSString *keyFile = [KeychainUtils stringForKey:self.selectedFilename
                                     andServiceName:KEYCHAIN_KEYFILES_SERVICE];
                                     
    // Try and load the database with the cached password from the keychain
    if (password != nil || keyFile != nil) {
        // Get the absolute path to the database
        NSString *path = [documentsDirectory stringByAppendingPathComponent:self.selectedFilename];
        
        // Get the absolute path to the keyfile
        NSString *keyFilePath = nil;
        if (keyFile != nil) {
            keyFilePath = [documentsDirectory stringByAppendingPathComponent:keyFile];
        }

        // Load the database
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:appDelegate.window.rootViewController.view animated:YES];
        
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.label.text = @"Loading...";
        
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
            DatabaseDocument *dd;
            @try {
                if( isCloudBased ) {
                    dd = [CloudFactory openCloudFile:path password:password keyFile:keyFilePath ];
                } else {
                    dd = [[DatabaseDocument alloc] initWithFilename:path password:password keyFile:keyFilePath];
                }
                [MBProgressHUD hideHUDForView:appDelegate.window.rootViewController.view animated:YES];
            
                // Set the database document in the application delegate
                appDelegate.databaseDocument = dd;
            } @catch (NSException *exception) {
                [self setupPasswordViewController:filename isCloudBased:isCloudBased];
            }
        });
    } else {
        [self setupPasswordViewController:filename isCloudBased:isCloudBased];
    }
}

- (void)setupPasswordViewController:(NSString *)filename isCloudBased:(BOOL)isCloudBased {
    // Prompt the user for the password if we haven't loaded the database yet
    PasswordViewController *passwordViewController = [[PasswordViewController alloc] initWithFilename:filename];
    passwordViewController.donePressed = ^(FormViewController *formViewController) {
        [self openDatabaseWithPasswordViewController:(PasswordViewController *)formViewController isCloudBased:isCloudBased];
    };
    passwordViewController.cancelPressed = ^(FormViewController *formViewController) {
        [formViewController dismissViewControllerAnimated:YES completion:nil];
    };
    
    // Create a default keyfile name from the database name
    NSString *keyFile = [[filename stringByDeletingPathExtension] stringByAppendingPathExtension:@"key"];
    
    // Select the keyfile if it's in the list
    NSInteger index = [passwordViewController.keyFileCell.choices indexOfObject:keyFile];
    if (index != NSNotFound) {
        passwordViewController.keyFileCell.selectedIndex = index;
    } else {
        passwordViewController.keyFileCell.selectedIndex = 0;
    }
    
    // Get the application delegate
    MiniKeePassAppDelegate *appDelegate = [MiniKeePassAppDelegate appDelegate];
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:passwordViewController];
        
    [appDelegate.window.rootViewController presentViewController:navigationController animated:YES completion:nil];
}

- (void)openDatabaseWithPasswordViewController:(PasswordViewController *)passwordViewController isCloudBased:(BOOL)isCloudBased {
    NSString *documentsDirectory = [MiniKeePassAppDelegate documentsDirectory];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:self.selectedFilename];

    // Get the password
    NSString *password = passwordViewController.masterPasswordFieldCell.textField.text;
    if ([password isEqualToString:@""]) {
        password = nil;
    }

    // Get the keyfile
    NSString *keyFile = [passwordViewController.keyFileCell getSelectedItem];
    if ([keyFile isEqualToString:NSLocalizedString(@"None", nil)]) {
        keyFile = nil;
    }

    // Get the absolute path to the keyfile
    NSString *keyFilePath = nil;
    if (keyFile != nil) {
        NSString *documentsDirectory = [MiniKeePassAppDelegate documentsDirectory];
        keyFilePath = [documentsDirectory stringByAppendingPathComponent:keyFile];
    }

    // Load the database
        // Open the database

        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:passwordViewController.view animated:YES];
        
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.label.text = @"Loading...";

        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            DatabaseDocument *dd;
            @try {
                if( isCloudBased ) {
                    dd = [CloudFactory openCloudFile:path password:password keyFile:keyFilePath ];
                } else {
                    dd = [[DatabaseDocument alloc] initWithFilename:path password:password keyFile:keyFilePath];
                }
                [MBProgressHUD hideHUDForView:passwordViewController.view animated:YES];
                
                // Store the password in the keychain
                if ([[AppSettings sharedInstance] rememberPasswordsEnabled]) {
                    [KeychainUtils setString:password forKey:self.selectedFilename
                              andServiceName:KEYCHAIN_PASSWORDS_SERVICE];
                    [KeychainUtils setString:keyFile forKey:self.selectedFilename
                              andServiceName:KEYCHAIN_KEYFILES_SERVICE];
                }
                
                // Dismiss the view controller, and after animation set the database document
                [passwordViewController dismissViewControllerAnimated:YES completion:^{
                    // Set the database document in the application delegate
                    MiniKeePassAppDelegate *appDelegate = [MiniKeePassAppDelegate appDelegate];
                    appDelegate.databaseDocument = dd;
                }];
            } @catch (NSException *exception) {
                NSLog(@"%@", exception);
                [MBProgressHUD hideHUDForView:passwordViewController.view animated:YES];
                [passwordViewController showErrorMessage:exception.reason];
            }
        });
}

+(void)saveDatabaseDocument:(DatabaseDocument*)doc viewController:(UIViewController*)vc andDismiss:(BOOL)dismiss {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:vc.view animated:YES];
    
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.label.text = @"Saving...";
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [doc save:^() {
            [MBProgressHUD hideHUDForView:vc.view animated:YES];
            if( dismiss ) {
                [vc dismissViewControllerAnimated:YES completion:nil];
            }
        }];
    });
}

@end
