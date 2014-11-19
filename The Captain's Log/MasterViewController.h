//
//  MasterViewController.h
//  The Captain's Log
//
//  Created by Chris Webb on 2/4/13.
//  Copyright (c) 2013 The Captain's Log. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DetailViewController;

#import <CoreData/CoreData.h>
#include "AppDelegate.h"
#include "Reachability.h"
#define kNewsEnabled @"newsEnabled"
#define kSportsEnabled @"sportsEnabled"
#define kOpinionsEnabled @"opinionsEnabled"
#define kArtsEnabled @"artsEnabled"
#define kLifestyleEnabled @"lifestyleEnabled"
@interface MasterViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) DetailViewController *detailViewController;

@property (atomic) Boolean alertAlreadyDisplayed;
@property (atomic) Boolean errorOccured;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSMutableArray *allArticlesArray;
@property (strong, nonatomic) NSDictionary *jsonfeeds;
@property (strong, nonatomic) NSMutableArray *sections;
@property (strong, nonatomic) NSDictionary *categorizedArticles;
@property Boolean newsEnabled;
@property Boolean sportsEnabled;
@property Boolean opinionsEnabled;
@property Boolean lifestyleEnabled;
@property Boolean artsEnabled;
@property (strong, atomic) NSMutableArray *newsArray;
@property (strong, atomic) NSMutableArray *sportsArray;
@property (strong, atomic) NSMutableArray *opinionsArray;
@property (strong, atomic) NSMutableArray *artsArray;
@property (strong, atomic) NSMutableArray *lifestyleArray;
- (void) errorDownloading;
- (void) noInternet;
- (void) serverDown;
- (BOOL) checkInternetConnectivity;
- (BOOL) checkCLOGJSONreachable;
- (BOOL) checkCLOGWPreachable;
- (void) setupDefaults;
- (void) setupSections;
- (void) setupJSONDict:(bool)CLOGreachable;
- (void) setupNews;
- (void) setupSports;
- (void) setupOpinions;
- (void) setupArts;
- (void) setupLifestyle;
- (void) setupSectionContent;
@end
