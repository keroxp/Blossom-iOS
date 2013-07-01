//
//  BPCandidateViewController.h
//  BlossomPad
//
//  Created by 桜井雄介 on 2013/05/05.
//  Copyright (c) 2013年 Yusuke Sakurai / Keio University Masui Toshiyuki Laboratory. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BLDictEntry;
@protocol BLCandidateViewControllerDelegate;

@interface BLCandidateViewController : UIViewController
<UICollectionViewDelegate,UICollectionViewDataSource>

@property (weak) id<BLCandidateViewControllerDelegate> delegate;
//@property (nonatomic) NSString *hiraBuffer;
@property (readonly) NSMutableArray *candidates;
@property (readonly) BOOL opened;

- (id)initWithDelegate:(id<BLCandidateViewControllerDelegate>)delegate;

/* 予測変換 */
- (void)presentSuggestion:(NSString*)text;
/* 連文節変換 */
- (void)convertBuffer;


@end

@protocol BLCandidateViewControllerDelegate <NSObject>

- (void)candidateController:(BLCandidateViewController*)controller didSelectCandidate:(BLDictEntry*)candidate;
- (void)candidateController:(BLCandidateViewController *)controller toggleButtonDidTap:(UIButton *)sender open:(BOOL)open;

@end