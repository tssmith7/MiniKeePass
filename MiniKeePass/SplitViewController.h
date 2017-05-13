//
//  SplitViewController.h
//  MiniKeePass
//
//  Created by Tait Smith on 5/4/17.
//  Copyright © 2017 Self. All rights reserved.
//

#ifndef SplitViewController_h
#define SplitViewController_h

#import <UIKit/UIKit.h>

@interface SplitViewController : UISplitViewController <UISplitViewControllerDelegate>

@property (nonatomic, strong) UINavigationController *mainNavController;
@property (nonatomic, strong) UINavigationController *detailNavController;
@property BOOL collapseToPrimary;

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (void)pushDetailViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (UIViewController *)popViewControllerAnimated:(BOOL)animated;
- (UIViewController *)popDetailViewControllerAnimated:(BOOL)animated;

@end

#endif /* SplitViewController_h */
