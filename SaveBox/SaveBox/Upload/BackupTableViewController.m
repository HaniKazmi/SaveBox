//
//  BackupTableViewController.m
//  SaveBox
//
//  Created by Hani Kazmi on 27/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BackupTableViewController.h"
#import <DropboxSDK/DropboxSDK.h>

@interface BackupTableViewController () <DBRestClientDelegate>

@property (nonatomic, readonly) DBRestClient* restClient;

@end


@implementation BackupTableViewController

@synthesize applicationsArray;
@synthesize applicationNamesArray;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)didPressLink {
    if (![[DBSession sharedSession] isLinked]) {
        [[DBSession sharedSession] linkFromController:self];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Create list of application bundle names
    self.applicationsArray = [[NSArray alloc] initWithArray: self.ReturnBundleDictionaries];

    //Alphabetisize
    NSSortDescriptor *alphaDescriptor = [[NSSortDescriptor alloc] initWithKey: @"CFBundleDisplayName" 
                                                                    ascending: YES 
                                                                     selector: @selector(caseInsensitiveCompare:)];
    self.applicationsArray = [applicationsArray sortedArrayUsingDescriptors:
                              [NSArray arrayWithObject:alphaDescriptor]];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.applicationsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"BackupCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    NSDictionary *applicationDictionary = [applicationsArray objectAtIndex: indexPath.row];
    cell.textLabel.text = [applicationDictionary objectForKey: @"CFBundleDisplayName"];
    cell.detailTextLabel.text = [applicationDictionary objectForKey: @"CFBundleIdentifier"];
    
    return cell;
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }   
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }   
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self didPressLink];
    
    NSString *localPath = [[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"];
    NSString *filename = @"Info.plist";
    NSString *destDir = @"/";
    [[self restClient] uploadFile:filename toPath:destDir
                    withParentRev:nil fromPath:localPath];
    
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

#pragma mark - Data delegates

- (NSArray *)ReturnBundleDictionaries
{
	static NSString *const cacheFileName = @"com.apple.mobile.installation.plist";
    
	NSString *relativeCachePath = [[@"Library" stringByAppendingPathComponent: @"Caches"]
                                   stringByAppendingPathComponent: cacheFileName];
	NSDictionary *cacheDict = nil;//[[NSDictionary alloc] init];
	NSString *path = [[NSString alloc] init];
    
	// Loop through all possible paths the cache could be in
	for (short i = 0; 1; i++)
	{
        
		switch (i) {
            case 0: // Jailbroken apps will find the cache here; their home directory is /var/mobile
                path = [NSHomeDirectory() stringByAppendingPathComponent: relativeCachePath];
                break;
            case 1: // App Store apps and Simulator will find the cache here; home (/var/mobile/) is 2 directories above sandbox folder
                path = [[NSHomeDirectory() stringByAppendingPathComponent: @"../.."]
                        stringByAppendingPathComponent: relativeCachePath];
                break;
            case 2: // If the app is anywhere else, default to hardcoded /var/mobile/
                path = [@"/var/mobile" stringByAppendingPathComponent: relativeCachePath];
                break;
            default: // Cache not found (loop not broken)
                return NULL;
            break; }
		
		BOOL isDir = NO;
		if ([[NSFileManager defaultManager] fileExistsAtPath: path 
                                                 isDirectory: &isDir] 
            && !isDir) // Ensure that file exists
			cacheDict = [NSDictionary dictionaryWithContentsOfFile: path];
		
		if (cacheDict) // If cache is loaded, then break the loop. If the loop is not "broken," it will return NO later (default: case)
			break;
	}
	
	NSDictionary *applicationsDictionary = [cacheDict objectForKey: @"User"]; // Then all the user (App Store /var/mobile/Applications) apps
    
    //Split dictionary by using the keys
    NSMutableArray *applicationBundleNamesArray = [[NSMutableArray alloc] initWithCapacity: 0];
    for (NSString *applicationBundle in applicationsDictionary.allKeys)
    {
        [applicationBundleNamesArray addObject: [applicationsDictionary 
                                                 objectForKey: applicationBundle]];
    }
    
    //Return the new array
	return applicationBundleNamesArray;
}

- (NSArray *)ReturnApplicationNames
{
    NSMutableArray *tApplicationNamesArray = [[NSMutableArray alloc] initWithCapacity:0];
    for (NSDictionary *applicationDictionary in self.applicationsArray) {
        [tApplicationNamesArray addObject:[applicationDictionary objectForKey:@"CFBundleDisplayName"]];
    }
    
    return tApplicationNamesArray;
}

#pragma mark - Dropbox delegates

- (DBRestClient *)restClient {
    if (!restClient) {
        restClient =
        [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        restClient.delegate = self;
    }
    return restClient;
}

- (void)restClient:(DBRestClient*)client uploadedFile:(NSString*)destPath
              from:(NSString*)srcPath metadata:(DBMetadata*)metadata {
    
    NSLog(@"File uploaded successfully to path: %@", metadata.path);
}

- (void)restClient:(DBRestClient*)client uploadFileFailedWithError:(NSError*)error {
    NSLog(@"File upload failed with error - %@", error);
}

@end
