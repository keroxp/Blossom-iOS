//
//  BLKeyCode.h
//  BlossomPad
//
//  Created by 桜井雄介 on 2013/05/04.
//  Copyright (c) 2013年 Yusuke Sakurai / Keio University Masui Toshiyuki Laboratory. All rights reserved.
//

#ifndef BlossomPad_BLKeyCode_h
#define BlossomPad_BLKeyCode_h

typedef enum{
    // 数字キー
    zeroKey = 100,
    oneKey,
    twoKey,
    threeKey,
    fourKey,
    fiveKey,
    sixKey,
    sevenKey,
    eightKey,
    nineKey,
    // アルファベットキー
    qKey = 200,
    wKey,
    eKey,
    rKey,
    tKey,
    yKey,
    uKey,
    iKey,
    oKey,
    pKey,
    aKey,
    sKey,
    dKey,
    fKey,
    gKey,
    hKey,
    jKey,
    kKey,
    lKey,
    zKey,
    xKey,
    cKey,
    vKey,
    bKey,
    nKey,
    mKey,
    // 記号キー
    commaKey = 300,
    periodKey,
    hyphenKey,
    numberKey,    
    // メタキー
    deleteKey = 400,
    commandKey,
    shiftKey,
    enterKey,
    spaceKey,
}BLKeyCode;

#endif
