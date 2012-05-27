//
//  BackupTableViewController.h
//  SaveBox
//
//  Created by Hani Kazmi on 27/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BackupTableViewController : UITableViewController

@property (strong, nonatomic) NSArray *applicationKeysArray;
@property (strong, nonatomic) NSDictionary *applicationsDictionary;

- (NSArray *)ReturnBundleDictionaries;

@end
