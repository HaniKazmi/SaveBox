//
//  BackupTableViewController.h
//  SaveBox
//
//  Created by Hani Kazmi on 27/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DBRestClient;

@interface BackupTableViewController : UITableViewController{
    DBRestClient *restClient;
}

@property (strong, nonatomic) NSArray *applicationsArray;
@property (strong, nonatomic) NSArray *applicationNamesArray;
- (NSArray *)ReturnBundleDictionaries;
- (NSArray *)ReturnApplicationNames;

@end
