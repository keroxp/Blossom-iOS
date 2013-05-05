//
//  BPDetailViewController.m
//  BlossomPad
//
//  Created by 桜井雄介 on 2013/05/04.
//  Copyright (c) 2013年 Yusuke Srakuai / Keio University Masui Toshiyuki Laboratory All rights reserved.
//

#import "BPDetailViewController.h"
#import "BPKeyboardViewController.h"
#import "BPCandidateViewController.h"

@interface BPDetailViewController ()

@property () BPKeyboardViewController *keyboardViewController;
@property () BPCandidateViewController *candidateViewController;

@property (strong, nonatomic) UIPopoverController *masterPopoverController;
@property (weak, nonatomic) IBOutlet UITextView *textView;

- (void)configureView;
@end

@implementation BPDetailViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }

    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }        
}

- (void)configureView
{
    // Update the user interface for the detail item.

    if (self.detailItem) {
        self.detailDescriptionLabel.text = [self.detailItem description];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
    
    BPKeyboardViewController *kvc = [[BPKeyboardViewController alloc] initWithNibName:@"BPKeyboardViewController"
                                                                               bundle:[NSBundle mainBundle]];
    kvc.activeClient = self.textView;
    CGRect f = kvc.view.frame;
    f.size.height = 55.0f;
    [kvc.view setFrame:f];
    self.textView.inputView = kvc.view;
    self.keyboardViewController = kvc;
    
    BPCandidateViewController *cv = [[BPCandidateViewController alloc] initWithNibName:@"BPCandidateViewController" bundle:nil];
    self.textView.inputAccessoryView = cv.view;
    self.candidateViewController = cv;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Master", @"Master");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

@end
