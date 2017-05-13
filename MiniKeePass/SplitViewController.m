//
//  SplitViewController.m
//  MiniKeePass
//
//  Created by Tait Smith on 5/4/17.
//  Copyright © 2017 Self. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "InfoViewController.h"
#import "SplitViewController.h"

@implementation SplitViewController

- (id) init {
    self = [super init];
    if( self ) {

        self.mainNavController = [[UINavigationController alloc] init];
        self.mainNavController.toolbarHidden = NO;
        InfoViewController *infoView = [[InfoViewController alloc] init];
        self.detailNavController = [[UINavigationController alloc] initWithRootViewController:infoView];
        self.detailNavController.toolbarHidden = YES;
        self.detailNavController.navigationItem.leftBarButtonItem = nil;
        
        // Create a split view controller.
        self.delegate = self;
        self.viewControllers = @[self.mainNavController, self.detailNavController];
        self.collapseToPrimary = NO;

    }
    
    return self;
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [self.mainNavController pushViewController:viewController animated:animated];
}

- (void)pushDetailViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if( self.isCollapsed ) {
        [self.mainNavController pushViewController:viewController animated:animated];
    } else {
        [self.detailNavController pushViewController:viewController animated:animated];
//        [self.detailNavController presentViewController:viewController animated:YES completion:nil];
    }
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
    return [self.mainNavController popViewControllerAnimated:animated];
}

- (UIViewController *)popDetailViewControllerAnimated:(BOOL)animated {
    if( self.isCollapsed ) {
        return [self.mainNavController popViewControllerAnimated:animated];
    } else {
        return [self.detailNavController popViewControllerAnimated:animated];
//        [self.detailNavController.presentedViewController dismissViewControllerAnimated:YES completion:nil];
//        return nil;
    }
}

- (BOOL)splitViewController:(UISplitViewController *)splitViewController collapseSecondaryViewController:(UIViewController *)secondaryViewController ontoPrimaryViewController:(UIViewController *)primaryViewController {

    if( self.collapseToPrimary ) {
        // Tell the split view controller not to do anything.
        return YES;
    } else {
        return NO;
    }
}

- (UIViewController *)primaryViewControllerForCollapsingSplitViewController:(UISplitViewController *)splitViewController {
    return self.mainNavController;
}

- (void)splitViewController:(UISplitViewController *)svc willChangeToDisplayMode:(UISplitViewControllerDisplayMode)displayMode {
    switch(displayMode) {
        case UISplitViewControllerDisplayModeAutomatic:
            break;
        case UISplitViewControllerDisplayModePrimaryHidden:
            break;
        default:
            break;
    }
}

@end
