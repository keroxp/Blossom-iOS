//
//  BPMasterViewController.h
//  BlossomPad
//
//  Created by 桜井雄介 on 2013/05/04.
//  Copyright (c) 2013年 Yusuke Sakurai / Keio University Masui Toshiyuki Laboratory All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
@class BPDetailViewController;

@interface BPMasterViewController : UITableViewController
<NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) BPDetailViewController *detailViewController;

@end
