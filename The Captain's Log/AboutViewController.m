//
//  AboutViewController.m
//  The Captain's Log
//
//  Created by Chris Webb on 2/4/13.
//  Copyright (c) 2013 The Captain's Log. All rights reserved.
//

#import "AboutViewController.h"
#import "NSString+HTML.h"
@interface AboutViewController ()

@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
@end

@implementation AboutViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)emailButton:(id)sender
{
    Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
    
	if (mailClass != nil) {
        //[self displayMailComposerSheet];
		// We must always check whether the current device is configured for sending emails
		if ([mailClass canSendMail]) {
			[self displayMailComposerSheet];
		}
		else { // displays UIAlert to user if email doesn't work
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Email not configured" message:@"Sorry, your device is not configured for email." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
		}
	}
	else	{// displays UIAlert to user if email doesn't work
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Email not configured" message:@"Sorry, your device is not configured for email." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
	}

    
}
-(void)displayMailComposerSheet // sets up the mail compose sheet
{
	MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
	picker.mailComposeDelegate = self;
	
	[picker setSubject:@"Help with iOS app"]; // sets subject
	
	
	// Set up recipients
	NSArray *toRecipients = @[@"webmaster@thecaptainslog.org"];
	[picker setToRecipients:toRecipients];

	
	[self presentViewController:picker animated:YES completion:nil]; // show view to user
}

- (void)mailComposeController:(MFMailComposeViewController*)controller // dismisses the mail view after the user finishes with it
          didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
	[self dismissViewControllerAnimated:YES completion:nil];
}
- (void) messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result{ // required for message compose
    
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
