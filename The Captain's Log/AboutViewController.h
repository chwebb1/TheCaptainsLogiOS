//
//  AboutViewController.h
//  The Captain's Log
//
//  Created by Chris Webb on 3/8/13.
//  Copyright (c) 2013 The Captain's Log. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
@interface AboutViewController : UIViewController <MFMailComposeViewControllerDelegate,
MFMessageComposeViewControllerDelegate,UISplitViewControllerDelegate>

- (IBAction)emailButton:(id)sender;
-(void)displayMailComposerSheet;
@property (weak, nonatomic) IBOutlet UIButton *bugButton;
@property (weak, nonatomic) IBOutlet UIButton *privacyButton;
@end
