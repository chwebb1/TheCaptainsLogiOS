//
//  BugTrackerController.m
//  The Captain's Log
//
//  Created by Chris Webb on 3/8/13.
//  Copyright (c) 2013 The Captain's Log. All rights reserved.
//

#import "BugTrackerController.h"
#import "NSString+HTML.h"
@interface BugTrackerController ()

@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
@end

@implementation BugTrackerController

#pragma mark - Managing the detail item

- (void)configureView
{
    // Update the user interface for the detail item.
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
    NSURL *bugURL = [NSURL URLWithString:@"http://bugs.thecaptainslog.org/bug_report_page.php"]; // set up the bug URL
    NSURLRequest *bugRequest = [NSURLRequest requestWithURL:bugURL]; // set up the url request for the bug report
    [_bugWebView loadRequest:bugRequest]; // display to user
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Split view
// not used
- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Master", @"Master");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

@end
