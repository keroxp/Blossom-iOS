//
//  BPKeyboardViewController.h
//  BlossomPad
//
//  Created by 桜井雄介 on 2013/05/04.
//  Copyright (c) 2013年 Yusuke Sakurai / Keio University Masui Toshiyuki Laboratory All rights reserved.
//

#import <UIKit/UIKit.h>

@class BLKey;

@protocol BLKeyboardViewControllerDelegate;

/* 入力モード */
typedef enum{
    BLInputModeAlphabet = 0,
    BLInputModeRomaKana
}BLInputMode;

/* コマンド */
typedef enum{
    BLKeyboardCommandSpace,
    BLKeyboardCommandDelete,
    BLKeyboardCommandEnter,
    BLKeyboardCommandSmall,
    BLKeyboardCommandClose
}BLKeyboardCommand;

@interface BLKeyboardViewController : UIViewController

/* デリゲート */
@property (weak) id<BLKeyboardViewControllerDelegate> delegate;
/* モード */
@property (readonly) BLInputMode inputMode;
/* すべてのキー */
@property (readonly) NSArray *keys;
/* キーを取得 */
- (BLKey*)keyAtRow:(NSUInteger)row column:(NSUInteger)column;
/* イニシャライザ */
- (id)initWithDelegate:(id<BLKeyboardViewControllerDelegate>)delegate;

@end


@protocol BLKeyboardViewControllerDelegate <NSObject>

- (void)keyboardViewController:(BLKeyboardViewController*)controller didInputText:(NSString*)text inputMode:(BLInputMode)inputMode;
- (void)keyboardViewController:(BLKeyboardViewController *)controller didInputCommand:(BLKeyboardCommand)command inputMode:(BLInputMode)inputMode;
- (void)keyboardViewController:(BLKeyboardViewController *)controller didChangeInputMode:(BLInputMode)inputMode;
@end
