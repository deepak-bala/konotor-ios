//
//  KonotorFeedbackScreenViewController.h
//  KonotorSampleApp
//
//  Created by Srikrishnan Ganesan on 10/07/13.
//  Copyright (c) 2013 Demach. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KonotorFeedbackScreen.h"
#import "KonotorUI.h"

#define KONOTOR_FEEDBACKSCREEN_MARGIN 0

@class KonotorFeedbackScreen,KonotorTextInputOverlay,KonotorConversationViewController;

@interface KonotorFeedbackScreenViewController : UIViewController <UITextViewDelegate>

@property (strong, nonatomic) UIView* transparentView;
@property (strong, nonatomic) UIView* textInputBox;

@property (strong, nonatomic) KonotorConversationViewController* messagesView;

@property (weak, nonatomic) IBOutlet UITableView *messageTableView;

@property (weak, nonatomic) IBOutlet UIView *headerContainerView;

@property (weak, nonatomic) IBOutlet UITextView *headerView;
@property (weak, nonatomic) IBOutlet UIButton* closeButton;

@property (weak, nonatomic) IBOutlet UIView *footerView;
@property (weak, nonatomic) IBOutlet UIButton *voiceInput;
@property (weak, nonatomic) IBOutlet UIButton *input;

- (void) refreshView;

@end
