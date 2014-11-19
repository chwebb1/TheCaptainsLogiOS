//
//  DetailViewController.m
//  The Captain's Log
//
//  Created by Chris Webb on 2/4/13.
//  Copyright (c) 2013 The Captain's Log. All rights reserved.
//

#import "DetailViewController.h"
#import "NSString+HTML.h"
@interface DetailViewController ()

@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
@end

@implementation DetailViewController
@synthesize authorName = _authorName;

#pragma mark - Managing the detail item
- (IBAction)sendPost:(id)sender { // share button
    NSArray *activityItems; // used to store items for the share button
    NSURL *URL = [[NSURL alloc] initWithString:[_detailItem objectForKey:@"URL"]]; // grabs url of article
    NSString *title = [[self.detailItem valueForKey:@"title"] stringByDecodingHTMLEntities]; // grabs title of article, decodes HTML so there is no special character issues
    NSString *excerpt =[[[self.detailItem valueForKey:@"excerpt"] stringByDecodingHTMLEntities] stringByConvertingHTMLToPlainText]; //grabs an excerpt of the article. Decodes HTML and converts to plain text
    NSString *newline = @"\n"; // new line character
    NSString *titleTitle = @"Title"; // Displays title in the share
    NSString *excerptTitle = @"Excerpt"; // displays excerpt in the share
    activityItems = @[titleTitle, title, newline, excerptTitle, excerpt, URL]; // copy all of the stuff from above to pass below
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil]; // prepares activity controller for sharing
    [self presentViewController:activityController animated:YES completion:nil]; // displays sharing options to user
}
- (void)activityController:(UIActivityViewController*)controller // dismisses activity controller afer user is finished
          didFinishWithResult:(UIActivityViewController*)result error:(NSError*)error {
	[self dismissViewControllerAnimated:YES completion:nil];
}
- (void)setDetailItem:(id)newDetailItem 
{
    if (_detailItem != newDetailItem) { // sets the item to the item that the user pressed
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView]; //call to set up the display
    }

    if (self.masterPopoverController != nil) { // not used
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }        
}

- (void)configureView
{
    // Update the user interface for the detail item.
    _activityIndicator.hidesWhenStopped = YES; // set the activity indicator to hide when not loading
    if (self.detailItem) { // makes sure detail item isn't nil.
        NSDictionary *authorInfo = [self.detailItem objectForKey:@"author"]; // grabs author info from detail item dictionary.
        NSString *title = [[self.detailItem valueForKey:@"title"] stringByDecodingHTMLEntities]; // grabs the title from the dictionary, decodes HTML special chars
        NSString *author = [[authorInfo valueForKey:@"name"] stringByDecodingHTMLEntities]; // grabs the author from the dictionary, decodes HTML special chars
        NSNumber *commentCountNo = [self.detailItem objectForKey:@"comment_count"]; // grabs the comment count
        NSString *commentCount = [commentCountNo stringValue]; // convert comment count to string
        NSMutableString *commentString = [[NSMutableString alloc] init]; // mutable string for comment button title
        [commentString setString:@"Comments ("]; // set up title
        [commentString appendString:commentCount];
        [commentString appendString:@")"];
        self.articleTitle.text = title; // places article title in the title at the top of the view
        self.authorName.text = author; // places author name in the title at the top of the view
        self.commentButton.title = commentString; // makes the comment button display our comment count
        NSMutableString *articleContentHTML = [self.detailItem objectForKey:@"content"];
//        [articleContentHTML insertString:@"<div id=\"body\" style=\"font=Helvetica;\">" atIndex:0];
//        [articleContentHTML appendString:@"</div>"];
//        NSURL *articleURL = [self.detailItem objectForKey:@"URL"];
        [self.articleContent loadHTMLString:articleContentHTML baseURL:nil]; // displays article content in a web view.
        while ([self.articleContent isLoading]) { // shows an activity indicator while loading
            [_activityIndicator startAnimating];
        }
        [_activityIndicator stopAnimating]; // stops activity indicator
        }
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
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender // segue to comments
{
    if ([[segue identifier] isEqualToString:@"showComments"]) { 
        [[segue destinationViewController] setDetailItem:_detailItem]; // sends info to CommentViewController
    }
}
#pragma mark - Split view
// this code isn't used
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
