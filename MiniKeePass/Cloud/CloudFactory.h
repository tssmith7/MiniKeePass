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

#import <Foundation/Foundation.h>
#import "CloudDocument.h"

@class CloudManager;

@interface CloudFactory : NSObject

+(CloudManager*) getCloudManager;
+(CloudDocument*) openCloudFile:(NSString *)filename password:(NSString *)password keyFile:(NSString *)keyFile;
+(NSArray*) getServiceNameList;

@end

