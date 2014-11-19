//
//  MasterViewController.m
//  The Captain's Log
//
//  Created by Chris Webb on 2/4/13.
//  Copyright (c) 2013 The Captain's Log. All rights reserved.
//

#import "MasterViewController.h"

#import "DetailViewController.h"
#import "NSString+HTML.h"
#import "Reachability.h"
@interface MasterViewController ()
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end

@implementation MasterViewController

- (void)awakeFromNib
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
    }

    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    BOOL internetConnected = [self checkInternetConnectivity]; // checks to see if the user can access either Google.com or Apple.com. If not, assumes that the user has no Internet.
    BOOL CLOGJSONreachable = [self checkCLOGJSONreachable]; // checks to see if json.thecaptainslog.org is accessible
    BOOL CLOGWPReachable = [self checkCLOGWPreachable]; // checks to make sure that both thecaptainslog.org and public-api.wordpress.com are accessible
    if (!internetConnected) { // pops up a notification after loading to let user know they have no Internet access
        [self noInternet];
    }
    if (!CLOGJSONreachable && !CLOGWPReachable) { // if neither CLOG JSON or CLOG WP and WP API are unavailable, pop up a message that says server is down
        [self serverDown];
    }
    [self setupDefaults]; // Sets up user preferences
    NSOperationQueue* mainQueue = [[NSOperationQueue alloc] init]; // creates a NSOperationsQueue to allow for threading
    mainQueue.name =  @"viewDidLoad Queue"; // sets queue name. Mostly used for debugging.
    [mainQueue setMaxConcurrentOperationCount:NSOperationQueueDefaultMaxConcurrentOperationCount]; // sets max operations to whatever the default value for max threads is on the device we're working with
    [mainQueue addOperationWithBlock:^{
        [self setupSections]; // sets up section headers
    }];
    [mainQueue addOperationWithBlock:^{
        [self setupJSONDict:CLOGJSONreachable]; // sets up JSON URLs. If for some reason, json.thecaptainslog.org is down, will default to public-api.wordpress.com
    }];
    [mainQueue addOperationWithBlock:^{
        self.allArticlesArray = [NSMutableArray array]; //initalizes the NSMutableArray so that we can add section content later
    }];
    [mainQueue waitUntilAllOperationsAreFinished]; //Waits until these operations are complete before continuing
    [self setupSectionContent]; // acquires section content, and merges it into a large array
    [super awakeFromNib];
}
- (BOOL) checkInternetConnectivity {
    //NSLog(@"Check internet connectivity entered");
    Reachability * reachGoog = [Reachability reachabilityWithHostname:@"www.google.com"]; // checks if we can access Google.com
    Reachability * reachApple = [Reachability reachabilityWithHostname:@"www.apple.com"]; // checks if we can access Apple.com
    //NSLog(@"Internet connected: %d", reachGoog.isReachable || reachApple.isReachable);
    return (reachGoog.isReachable || reachApple.isReachable); // returns true if we can reach 
}
- (void) noInternet { // tells the user we can't access the Internet. 
    if (!_errorOccured) {
        _errorOccured = TRUE;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Internet Connectivity" message:@"Sorry, you currently don't have Internet connectivity. This application requires Internet connectivity to function correctly." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
    }
}
- (BOOL) checkCLOGJSONreachable { // checks if we can access json.thecaptainslog.org
    Reachability * reachCLOGJSON = [Reachability reachabilityWithHostname:@"json.thecaptainslog.org"];
    return reachCLOGJSON.isReachable;
}
- (BOOL) checkCLOGWPreachable { // checks if we can access thecaptainslog.org and public-api.wordpress.com
    Reachability * reachCLOG = [Reachability reachabilityWithHostname:@"www.thecaptainslog.org"];
    Reachability * reachWPAPI = [Reachability reachabilityWithHostname:@"https://public-api.wordpress.com/"];
    return (reachCLOG.isReachable && reachWPAPI.isReachable);
}
- (void) serverDown { // tells the user that our server is down.
    if (!_errorOccured) {
        _errorOccured = TRUE;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Server down" message:@"Sorry, it appears that we are having server issues. Please try again later. We apologize for the inconvenience." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
    }
}
- (void) setupDefaults{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults]; // Sets up the user defaults
    NSOperationQueue* defaultsQueue = [[NSOperationQueue alloc] init]; // creates a NSOperationsQueue to allow for threading
    defaultsQueue.name =  @"viewDidLoad Queue"; // sets queue name. Mostly used for debugging.
    [defaultsQueue setMaxConcurrentOperationCount:NSOperationQueueDefaultMaxConcurrentOperationCount]; // sets max operations to whatever the default value for max threads is on the device we're working with
    [defaultsQueue addOperationWithBlock:^{
        _newsEnabled = [defaults boolForKey:kNewsEnabled];  //checks if News is enabled
    }];
    [defaultsQueue addOperationWithBlock:^{
        _sportsEnabled = [defaults boolForKey:kSportsEnabled];  //checks if Sports is enabled
    }];
    [defaultsQueue addOperationWithBlock:^{
        _opinionsEnabled = [defaults boolForKey:kOpinionsEnabled];  //checks if Opionions is enabled
    }];
    [defaultsQueue addOperationWithBlock:^{
        _artsEnabled = [defaults boolForKey:kArtsEnabled]; // checks if Arts is enabled
    }];
    [defaultsQueue addOperationWithBlock:^{
        _lifestyleEnabled = [defaults boolForKey:kLifestyleEnabled]; //Checks if Lifestyle is enabled
    }];
    [defaultsQueue waitUntilAllOperationsAreFinished];
    if (_newsEnabled || _sportsEnabled || _opinionsEnabled || _artsEnabled || _lifestyleEnabled != YES){ // checks if none are enabled, and if none are, enables all.
        [defaults setBool:YES forKey:@"newsEnabled"];
        [defaults setBool:YES forKey:@"sportsEnabled"];
        [defaults setBool:YES forKey:@"opinionsEnabled"];
        [defaults setBool:YES forKey:@"artsEnabled"];
        [defaults setBool:YES forKey:@"lifestyleEnabled"];
        [defaults synchronize]; // sends info to system
    }
}
- (void) setupJSONDict:(bool)CLOGreachable{ // if CLOG's JSON server is reachable, pull JSON from that. Else, pull directly from WP's API (slower)
    if (CLOGreachable) { // if our server is accessible, download from our server
        NSBundle *bundle = [NSBundle mainBundle];
        NSString *pathToFeedPlist = [bundle pathForResource:@"JSONURLsCLOG" ofType:@"plist"]; // this defines the primary urls
        _jsonfeeds = [[NSDictionary alloc] initWithContentsOfFile:pathToFeedPlist];
    }
    else { // otherwise, download from WordPress' servers.
        NSBundle *bundle = [NSBundle mainBundle];
        NSString *pathToFeedPlist = [bundle pathForResource:@"JSONURLsWP" ofType:@"plist"]; // this defines the backup urls
        _jsonfeeds = [[NSDictionary alloc] initWithContentsOfFile:pathToFeedPlist];
    }
    
}
- (void) setupSectionContent{
    NSOperationQueue* sectionQueue = [[NSOperationQueue alloc] init]; // creates a NSOperationsQueue to allow for threading
    sectionQueue.name =  @"Section Contents Queue"; // sets queue name. Mostly used for debugging.
    [sectionQueue setMaxConcurrentOperationCount:NSOperationQueueDefaultMaxConcurrentOperationCount]; // sets max operations to whatever the default value for max threads is on the device we're working with
    if (_newsEnabled == YES) { // if news is enabled by our user, download and process it
        [sectionQueue addOperationWithBlock:^{
            [self setupNews];
        }];
    }
    if (_sportsEnabled == YES) {// if sports is enabled by our user, download and process it
        [sectionQueue addOperationWithBlock:^{ 
            [self setupSports];
        }];
    }
    if (_opinionsEnabled == YES) {// if opinions is enabled by our user, download and process it
        [sectionQueue addOperationWithBlock:^{
            [self setupOpinions];
        }];
    }
    if (_artsEnabled == YES) {// if arts is enabled by our user, download and process it
        [sectionQueue addOperationWithBlock:^{
            [self setupArts];
        }];
    }
    if (_lifestyleEnabled == YES) {// if lifestyle is enabled by our user, download and process it
        [sectionQueue addOperationWithBlock:^{
            [self setupLifestyle];
        }];
    }
    [sectionQueue waitUntilAllOperationsAreFinished];

    [self.allArticlesArray addObjectsFromArray:_newsArray]; // inserts the news array into main array
    [self.allArticlesArray addObjectsFromArray:_sportsArray]; // inserts the sports array into main array
    [self.allArticlesArray addObjectsFromArray:_opinionsArray]; // inserts the opinions array into main array
    [self.allArticlesArray addObjectsFromArray:_artsArray]; // inserts the arts array into main array
    [self.allArticlesArray addObjectsFromArray:_lifestyleArray]; // inserts the lifestyle array into main array

}

- (void) setupNews{
    @try {
        NSError *error = nil;
        NSURL *news = [NSURL URLWithString: [_jsonfeeds objectForKey:@"NewsJSONURL"]]; // sets a NSURL to be the URL in the object of the JSON feed
        NSData *newsJSON = [NSData dataWithContentsOfURL:news]; // downloads the data
        NSDictionary *newsDictionary= [NSJSONSerialization JSONObjectWithData:newsJSON options:0 error:&error]; //enters our JSON data into a NSDictionary
        _newsArray = [newsDictionary objectForKey:@"posts"]; // enters our posts into a NSArray
        if (_newsArray == nil) { // if our array is null, throws an exception
            @throw [NSException exceptionWithName:@"nullArrayException" reason:@"The News Array is currently null" userInfo:newsDictionary];
        }
    }
    @catch (NSException *exception) {
        [self errorDownloading]; // displays a dialog to the user saying that we were unable to process the data given by the server
    }
    @finally {
        
    }
}
- (void) setupSports{
    @try {
        //    NSLog(@"Sports Started");
        NSError *error = nil;
        NSURL *sports = [NSURL URLWithString: [_jsonfeeds objectForKey:@"SportsJSONURL"]]; // sets a NSURL to be the URL in the object of the JSON feed
        NSData *sportsJSON = [NSData dataWithContentsOfURL:sports]; // downloads the data
        NSDictionary *sportsDictionary= [NSJSONSerialization JSONObjectWithData:sportsJSON options:0 error:&error]; //enters our JSON data into a NSDictionary
        _sportsArray = [sportsDictionary objectForKey:@"posts"]; // enters our posts into a NSArray
        //    NSLog(@"Sports Finished");
        if (_sportsArray == nil) {// if our array is null, throws an exception
            @throw [NSException exceptionWithName:@"nullArrayException" reason:@"The Sports Array is currently null" userInfo:sportsDictionary];
        }
    }
    @catch (NSException *exception) {
        [self errorDownloading];// displays a dialog to the user saying that we were unable to process the data given by the server

    }
    @finally {
        
    }

    
}
- (void) setupOpinions{
    @try {
        //    NSLog(@"Opinions Started");
        NSError *error = nil;
        NSURL *opinions = [NSURL URLWithString: [_jsonfeeds objectForKey:@"OpinionsJSONURL"]]; // sets a NSURL to be the URL in the object of the JSON feed
        NSData *opinionsJSON = [NSData dataWithContentsOfURL:opinions]; // downloads the data
        NSDictionary *opinionsDictionary= [NSJSONSerialization JSONObjectWithData:opinionsJSON options:0 error:&error]; //enters our JSON data into a NSDictionary
        _opinionsArray = [opinionsDictionary objectForKey:@"posts"]; // enters our posts into a NSArray
        //    NSLog(@"Opinions Finished");
        if (_opinionsArray == nil) {// if our array is null, throws an exception
            @throw [NSException exceptionWithName:@"nullArrayException" reason:@"The Opinions Array is currently null" userInfo:opinionsDictionary]; 
        }
    }
    @catch (NSException *exception) {
        [self errorDownloading];// displays a dialog to the user saying that we were unable to process the data given by the server

        
    }
    @finally {
        
    }
}
- (void) setupArts{
    @try {
        //    NSLog(@"Arts Started");
        NSError *error = nil;
        NSURL *arts = [NSURL URLWithString: [_jsonfeeds objectForKey:@"ArtsJSONURL"]]; // sets a NSURL to be the URL in the object of the JSON feed
        NSData *artsJSON = [NSData dataWithContentsOfURL:arts]; // downloads the data
        NSDictionary *artsDictionary= [NSJSONSerialization JSONObjectWithData:artsJSON options:0 error:&error]; //enters our JSON data into a NSDictionary
        _artsArray = [artsDictionary objectForKey:@"posts"]; // enters our posts into a NSArray
        //    NSLog(@"Arts Finished");
        if (_artsArray == nil) {// if our array is null, throws an exception
            @throw [NSException exceptionWithName:@"nullArrayException" reason:@"The Arts Array is currently null" userInfo:artsDictionary];
        }
    }
    @catch (NSException *exception) {
        [self errorDownloading];// displays a dialog to the user saying that we were unable to process the data given by the server

    }
    @finally {
        
    }

    
}
- (void) setupLifestyle{
    @try {
        //    NSLog(@"Lifestyle Started");
        NSError *error = nil;
        NSURL *lifestyle = [NSURL URLWithString: [_jsonfeeds objectForKey:@"LifestyleJSONURL"]]; // sets a NSURL to be the URL in the object of the JSON feed
        NSData *lifestyleJSON = [NSData dataWithContentsOfURL:lifestyle]; // downloads the data
        NSDictionary *lifestyleDictionary= [NSJSONSerialization JSONObjectWithData:lifestyleJSON options:0 error:&error]; //enters our JSON data into a NSDictionary
        _lifestyleArray = [lifestyleDictionary objectForKey:@"posts"];// enters our posts into a NSArray
        //    NSLog(@"Lifestyle Finished"); 
        if (_lifestyleArray == nil) {
            @throw [NSException exceptionWithName:@"nullArrayException" reason:@"The Lifestyle Array is currently null" userInfo:lifestyleDictionary]; 
        }
    }
    @catch (NSException *exception) {// if our array is null, throws an exception
        [self errorDownloading];// displays a dialog to the user saying that we were unable to process the data given by the server
    }
    @finally {
        
    }

    
}
-(void) errorDownloading {// displays an error box to the user
    if (!_errorOccured) { 
        _errorOccured = TRUE;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Problems downloading" message:@"It appears that our server is currently having issues, or your connection to the Internet is unstable. We appologize for the inconvenience. Please email webmaster@thecaptainslog.org to let us know." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
    }

}
- (void) setupSections{ //sets up section headers
    self.sections = [NSMutableArray array];
    if (_newsEnabled == YES){
        [self.sections addObject:@"News"];
    }
    if (_sportsEnabled == YES){
        [self.sections addObject:@"Sports"];
    }
    if (_opinionsEnabled == YES){
        [self.sections addObject:@"Opinions"];
    }
    if (_artsEnabled == YES){
        [self.sections addObject:@"Arts"];
    }
    if (_lifestyleEnabled == YES){
        [self.sections addObject:@"Lifestyle"];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.sections.count; //returns number of items in "section" array (where headers are stored)
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section { //sets up section headers (gets text and places it into the header)
    NSString *key = [self.sections objectAtIndex:section];
    return key;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.allArticlesArray.count/self.sections.count; //returns the number of articles divided by the number of sections
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath // sets up article titles and authors
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath]; // create a new table cell
    NSDictionary *blogPost = [self.allArticlesArray objectAtIndex:indexPath.row+((self.allArticlesArray.count/self.sections.count)*indexPath.section)]; //grabs the post from the article array, and multiplies it by the cell section. Places it in a dictionary for later use
    NSDictionary *authorInfo = [blogPost objectForKey:@"author"]; // grabs the author info and places it in a cell for later use
    NSString *title = [[blogPost valueForKey:@"title"] stringByDecodingHTMLEntities]; //grabs the article title, sends it to be decoded for special characters, such as &8220;
    NSString *author = [[authorInfo valueForKey:@"name"] stringByDecodingHTMLEntities]; // grabs the article author, sends it to be decoded for special characters
    cell.textLabel.text = title; // sets the article title to the title we set 2 lines above
    cell.detailTextLabel.text = author; // sets the article author to the author set 2 lines above
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The table view should not be re-orderable.
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath // what to do when a user selects a row cell
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        NSManagedObject *object = [[self fetchedResultsController] objectAtIndexPath:indexPath]; // grabs the article selected
        self.detailViewController.detailItem = object; // sends it to the detailViewController
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showAbout"]){ // segues to the about page if the user presses the about button
        [segue destinationViewController];
        }
    else if ([[segue identifier] isEqualToString:@"showDetail"]) { // prepares for segue to detailViewController
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow]; // sets the indexPath to the row selected by the user
        NSManagedObject *object = [self.allArticlesArray objectAtIndex:indexPath.row+((_allArticlesArray.count/_sections.count)*indexPath.section)]; // grabs the article at section*article.
        [[segue destinationViewController] setDetailItem:object]; // segues to DVC
    }
    
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller // prepares to update content. This function is not used by this class, but is required for master-detail controller (MDC)
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo // this method is used if you allow the user to modify your UITableView, however, since we do not, this method is not used by our code, however, is required for the MDC.
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath // this method is used if you allow the user to modify your UITableView, however, since we do not, this method is not used by our code, however, is required for the MDC.
{
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller // this method is used if you allow the user to modify your UITableView, however, since we do not, this method is not used by our code, however, is required for the MDC.
{
    [self.tableView endUpdates];
}

/*
// Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed. 
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // In the simplest, most efficient, case, reload the table view.
    [self.tableView reloadData];
}
 */

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath // this method is not used by our class, however, is required by MDC
{
    NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = [[object valueForKey:@"timeStamp"] description];
}

@end
