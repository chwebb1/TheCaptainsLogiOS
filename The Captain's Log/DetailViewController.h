//
//  DetailViewController.h
//  The Captain's Log
//
//  Created by Chris Webb on 2/4/13.
//  Copyright (c) 2013 The Captain's Log. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController <UISplitViewControllerDelegate>

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *commentButton;
@property (weak, nonatomic) IBOutlet UILabel *articleTitle;
@property (weak, nonatomic) IBOutlet UILabel *authorName;
@property (strong, nonatomic) NSDictionary *selectedArticle;
@property (weak, nonatomic) IBOutlet UIWebView *articleContent;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
- (IBAction)sendPost:(id)sender;
@end

