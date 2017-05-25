/*
 * Copyright 2017 Tait Smith. All rights reserved.
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

#import "CloudFactory.h"
#import "DropboxManager.h"
#import "DropboxDocument.h"
//#import "GDriveManager.h"
#import "AppSettings.h"

@implementation CloudFactory

static NSArray *cloudServiceNames = nil;  // Assigned in getServiceNameList
+(NSArray*) getServiceNameList {
    if( cloudServiceNames == nil ) {
        cloudServiceNames = @[@"Dropbox" /*, @"Google Drive" */ ];
    }
    
    return cloudServiceNames;
}

static CloudManager *sharedInstance = nil;

+(CloudManager*) getCloudManager {
    AppSettings *appSettings = [AppSettings sharedInstance];
    CloudManager *initCM = sharedInstance;
    
    switch( appSettings.cloudServiceIndex ) {
        case 0 :    // Dropbox (see cloudServicesNames array order)
            if( ![sharedInstance isKindOfClass:[DropboxManager class]] ) {
                sharedInstance = [[DropboxManager alloc] init];
            }
            break;
        case 1 :    // Google Drive Service
//            if( ![sharedInstance isKindOfClass:[GDriveManager class]] ) {
//                sharedInstance = [[GDriveManager alloc] init];
//            }
//            break;
        default:
            sharedInstance = nil;
            break;
    }
    
    if( sharedInstance != initCM ) {
        // CloudManager was changed so we should initialize it.
        [sharedInstance initAPI];
    }
    
    return sharedInstance;
}

+(void) resetCloudManager {
    sharedInstance = nil;
}

+(CloudDocument*) openCloudFile:(NSString *)filename password:(NSString *)password keyFile:(NSString *)keyFile {
    CloudManager *cloudMgr = [self getCloudManager];
    
    if( cloudMgr == nil ) return nil;
    
    CloudDocument *doc;
    if( [cloudMgr isKindOfClass:[DropboxManager class]] ) {
        doc = [[DropboxDocument alloc] initWithFilename:filename password:password keyFile:keyFile ];
//    } else if( [cloudMgr isKindOfClass:[GDriveManager class]] ) {
//        doc = [[GDriveDocument alloc] initWithFilename:filename password:password keyFile:keyFile ];
    } else {
        doc = nil;
    }
    
    return doc;
}

@end
