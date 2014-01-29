//
//  KonotorTextInputOverlay.h
//  KonotorSampleApp
//
//  Created by Srikrishnan Ganesan on 11/07/13.
//  Copyright (c) 2013 Demach. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KonotorUI.h"

#define KONOTOR_TEXTINPUT_TEXTVIEW_TAG 201
#define KONOTOR_TEXTINPUT_SENDBUTTON_TAG 202

@interface KonotorTextInputOverlay : NSObject <UITextViewDelegate>

@property (strong, nonatomic) UIView* transparentView;
@property (strong, nonatomic) UIView* textInputBox;
@property (strong, nonatomic) UIView* window;
@property (nonatomic) CGRect originalTextInputRect;

+(KonotorTextInputOverlay*) sharedInstance;

+(BOOL) showInputForView:(UIView*) view;

@end
