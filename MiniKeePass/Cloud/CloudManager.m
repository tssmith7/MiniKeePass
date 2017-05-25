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

#import "CloudManager.h"

@implementation CloudManager

-(void) initAPI {[self doesNotRecognizeSelector:_cmd];}
-(BOOL) isClientAuthorized {[self doesNotRecognizeSelector:_cmd]; return NO;}
-(BOOL) getAccountAuthorization:(UIApplication*)app controller:(UIViewController*)controller {[self doesNotRecognizeSelector:_cmd]; return NO;}
-(uint32_t) accountAuthorizationRedirect:(NSURL*)url {[self doesNotRecognizeSelector:_cmd]; return 0;}
-(BOOL) isAccountAuthorizing {[self doesNotRecognizeSelector:_cmd]; return NO;}
-(void) resetAccount {[self doesNotRecognizeSelector:_cmd];}

-(void) loadFileList:(CMrequestCallback)requestCallback {[self doesNotRecognizeSelector:_cmd];}
-(NSMutableArray *) getFileList {[self doesNotRecognizeSelector:_cmd]; return nil;}
-(NSDate *) getFileModifiedDate:(NSString*)file {[self doesNotRecognizeSelector:_cmd];return nil;}
-(void) downloadFile:(NSString*)path requestCallback:(CMrequestCallback)requestCallback {[self doesNotRecognizeSelector:_cmd];}
-(void) uploadFile:(NSString*)path requestCallback:(CMrequestCallback)requestCallback {[self doesNotRecognizeSelector:_cmd];}

// Factory Methods to get paths and URLs.
-(NSString *)getLocalPath:(NSString *)filename {[self doesNotRecognizeSelector:_cmd];return nil;}
-(NSURL *)getLocalURL:(NSString *)filename {[self doesNotRecognizeSelector:_cmd];return nil;}
-(NSString *)getRemotePath:(NSString *)filename {[self doesNotRecognizeSelector:_cmd];return nil;}
-(NSString *)getTempDir {[self doesNotRecognizeSelector:_cmd];return nil;}

-(NSDictionary*)getAccountInformation {[self doesNotRecognizeSelector:_cmd];return nil;}

@end
