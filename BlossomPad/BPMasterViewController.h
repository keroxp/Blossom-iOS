//
//  BPMasterViewController.h
//  BlossomPad
//
//  Created by 桜井雄介 on 2013/05/04.
//  Copyright (c) 2013年 Yusuke Srakuai / Keio University Masui Toshiyuki Laboratory All rights reserved.
//

#import <UIKit/UIKit.h>

@class BPDetailViewController;

@interface BPMasterViewController : UITableViewController

@property (strong, nonatomic) BPDetailViewController *detailViewController;

@end
