//
//  BPKeyboardViewController.m
//  BlossomPad
//
//  Created by 桜井雄介 on 2013/05/04.
//  Copyright (c) 2013年 Yusuke Srakuai / Keio University Masui Toshiyuki Laboratory All rights reserved.
//

#import "BPKeyboardViewController.h"
#import "BPKey.h"

#define kKeyboardWidth 1024.f
#define kKeyboardHeight 352.0f

#define kKeyRowHeight 76.0f
#define kKeyRowMargin 10.0f

#define kKeyWidth 82.0f
#define kKeyHeight 74.0f

#define kKeyMarginRight 10.0f
#define kKeyMarginUp 8.0f

#define kRow2MarginLeft 40.0f
#define kDefaultPieViewWidth 200.0f

#define PI 3.1415926535

@interface BPKeyboardViewController ()

@end

@implementation BPKeyboardViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"keyboard" ofType:@"json"];
        NSString *jsonstr = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
        NSError *e = nil;
        NSArray *rows = [jsonstr objectFromJSONStringWithParseOptions:JKParseOptionNone error:&e];
        [rows enumerateObjectsUsingBlock:^(id obj, NSUInteger i, BOOL *stop) {
            [(NSArray*)obj enumerateObjectsUsingBlock:^(id obj2, NSUInteger j, BOOL *stop2) {
                // Keyをインスタンス化
                BPKey *key = [[BPKey alloc] initWithJSON:(NSDictionary*)obj2 line:i index:j];
                TFLog(@"%@",key.pieces);
                CGFloat x = (kKeyWidth + kKeyMarginRight)*j + kKeyMarginRight;
                CGFloat y = (kKeyHeight + kKeyMarginUp)*i + kKeyMarginUp;
                CGFloat w = kKeyWidth;
                CGFloat h = kKeyHeight;
                CGRect frame = CGRectMake(x,y,w,h);
                // ２段目をずらす
                if (i == 1) frame = CGRectMake(kRow2MarginLeft+x,y,w,h);
                key.frame = frame;
                [self.view addSubview:key];
            }];
        }];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardSizeDidChange:)
                                                 name:UIKeyboardDidChangeFrameNotification
                                               object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)keyboardSizeDidChange:(NSNotification*)notification
{
    CGRect begin = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    CGRect end = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    TFLog(@"begin : %@",NSStringFromCGRect(begin));
    TFLog(@"end : %@",NSStringFromCGRect(end));
}

@end
