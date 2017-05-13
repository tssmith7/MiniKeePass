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

#import "InfoViewController.h"

@implementation InfoViewController

- (id)init {
    self = [super init];
    if (self) {
        // Initialization code
        self.title = @"MiniKeePass";
        self.view.backgroundColor = [UIColor whiteColor];
        self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

        self.label = [[UILabel alloc] initWithFrame:CGRectMake(20, self.view.bounds.size.height/2, self.view.bounds.size.width - 20.0f, 0)];
        self.label.backgroundColor = [UIColor clearColor];
        self.label.textAlignment = NSTextAlignmentCenter;
        self.label.numberOfLines = 0;
        self.label.lineBreakMode = NSLineBreakByWordWrapping;
        self.label.textColor = [UIColor grayColor];
        self.label.text = NSLocalizedString(@"Tap the + button to add a new KeePass file.", nil);
        [self.label sizeToFit];
        [self.view addSubview:self.label];
    }
    return self;
}

/*
- (void)layoutSubviews {
    [super layoutSubviews];

    // Resize the label to the width of the screen in case we've rotated
    label.frame = CGRectMake(0, 0, self.bounds.size.width - 20.0f, 0);
    [label sizeToFit];

    // Center the label, in iOS 7 account for the layout guides
    if ([self.viewController respondsToSelector:@selector(topLayoutGuide)]) {
        CGFloat top = self.viewController.topLayoutGuide.length;
        CGFloat bottom = self.viewController.bottomLayoutGuide.length;
        label.center = CGPointMake(self.bounds.size.width / 2.0f, (self.bounds.size.height - top - bottom) / 2.0f + top);
    } else {
        label.center = CGPointMake(self.bounds.size.width / 2.0f, self.bounds.size.height / 2.0f);
    }
}
*/

@end
