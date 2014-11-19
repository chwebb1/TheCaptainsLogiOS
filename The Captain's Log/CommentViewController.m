//
//  CommentViewController.m
//  The Captain's Log
//
//  Created by Chris Webb on 3/8/13.
//  Copyright (c) 2013 The Captain's Log. All rights reserved.
//

#import "CommentViewController.h"
#import "NSString+HTML.h"
#import "Reachability.h"
@interface CommentViewController ()

@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
@end

@implementation CommentViewController
@synthesize authorName = _authorName;

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }
    
    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }
    //NSLog(@"%c",_errorOccured);
}

- (void)configureView
{
//    Reachability * reachID = [Reachability reachabilityWithHostname:@"http://www.intensedebate.com/"]; // checks to see if IntenseDebate is reachable
   // NSLog([reachID isReachable] ? @"Yes" : @"No");
    // Update the user interface for the detail item.
    _activityIndicator.hidesWhenStopped = YES;
    
//    if ([reachID isReachable]) { // process this code if ID is reachable
        if (self.detailItem) { // checks to make sure we have a detail item
            [_activityIndicator startAnimating]; // animate activity indicator
            NSDictionary *authorInfo = [self.detailItem objectForKey:@"author"]; // grabs author info from detail item dictionary.
            NSString *title = [[self.detailItem valueForKey:@"title"] stringByDecodingHTMLEntities]; // grabs the title from the dictionary, decodes HTML special chars

            NSString *author = [[authorInfo valueForKey:@"name"] stringByDecodingHTMLEntities];// grabs the author from the dictionary, decodes HTML special chars

            self.articleTitle.text = title;// places article title in the title at the top of the view

            self.authorName.text = author; // places author name in the title at the top of the view

            NSString *articleURL = [self.detailItem objectForKey:@"URL"]; // grabs the URL for the article if it was viewed on the website. Sent to ID.
            NSNumber *artIDNo = [self.detailItem objectForKey:@"ID"]; // grabs the ID No. of the article if viewed on the website. Sent to ID.
            NSString *articleID = [artIDNo stringValue]; // converts ID No. to string
            NSMutableString *articleContentHTML = [[NSMutableString alloc] init]; // creates a NSMutableString, used for storage of HTML.
            [articleContentHTML setString:@"<html><head><title>Comment</title></head><body><script>var idcomments_acct ='REDACTED INTENSEDEBATE ACCOUNT NUMBER';"]; // this number is set by ID. This should be changed to reflect your ID account number
            [articleContentHTML appendString:@"var idcomments_post_id = '"];
            [articleContentHTML appendString:articleID]; // article ID from above
            [articleContentHTML appendString:@"';var idcomments_post_url = '"];
            [articleContentHTML appendString:articleURL]; // article URL from above
            [articleContentHTML appendString:@"';</script>"];
            [articleContentHTML appendString:@"<span id=\"IDCommentsPostTitle\" style=\"display:none\"></span>"];
            [articleContentHTML appendString:@"<script type='text/javascript' src='http://www.intensedebate.com/js/genericCommentWrapperV2.js'></script></body></html>"]; // send to ID
            [self.articleContent loadHTMLString:articleContentHTML baseURL:nil]; // display commenting in a web view
            while (self.articleContent.loading) { // shows activity indicator while loading
                //NSLog(@"loading");
                [_activityIndicator startAnimating];
            }
            [_activityIndicator stopAnimating]; // stops activity indicator
        }

//    }
/*    else {
        if (!_errorOccured) { // display an error box to the user if ID was unreachable.
            [_activityIndicator stopAnimating];
            //NSLog(@"errorOccured");
            _errorOccured = true;
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"IntenseDebate Unreachable" message:@"It appears that our commenting system provider, IntenseDebate, is having issues, or or you have lost Internet connectivity since launching this app. We appologize for the inconvenience." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
            [self.navigationController popViewControllerAnimated:YES];
            }
*/        //}
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Split view
//not used
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
