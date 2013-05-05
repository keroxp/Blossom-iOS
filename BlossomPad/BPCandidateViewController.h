//
//  BPCandidateViewController.h
//  BlossomPad
//
//  Created by 桜井雄介 on 2013/05/05.
//  Copyright (c) 2013年 Yusuke Sakurai / Keio University Masui Toshiyuki Laboratory. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BPCandidateViewControllerDelegate;

@interface BPCandidateViewController : UIViewController
<UICollectionViewDelegate,UICollectionViewDataSource,SRWebSocketDelegate,SocketIODelegate>

- (id)initWithDelegate:(id<BPCandidateViewControllerDelegate>)delegate;

@property (weak) id<BPCandidateViewControllerDelegate> delegate;
@property (nonatomic) NSString *hiraBuffer;

/* 連文節変換 */
- (void)performConversion;

@end

@protocol BPCandidateViewControllerDelegate <NSObject>

- (void)candidateController:(BPCandidateViewController*)controller didSelectCandidate:(NSString*)candidate;

@end