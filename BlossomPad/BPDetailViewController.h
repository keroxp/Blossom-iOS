//
//  BPDetailViewController.h
//  BlossomPad
//
//  Created by 桜井雄介 on 2013/05/04.
//  Copyright (c) 2013年 Yusuke Sakurai / Keio University Masui Toshiyuki Laboratory All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Entry.h"

@interface BPDetailViewController : UIViewController <UISplitViewControllerDelegate>

@property (strong, nonatomic) Entry *entry;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end
