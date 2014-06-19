//
//  KonotorImageInput.h
//  KonotorDemo
//
//  Created by Srikrishnan Ganesan on 10/03/14.
//  Copyright (c) 2014 Demach. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KonotorImageInput : NSObject <UIAlertViewDelegate,UIImagePickerControllerDelegate,UIActionSheetDelegate,UINavigationControllerDelegate>

@property (strong, nonatomic) UIView* sourceView;
@property (strong, nonatomic) UIView* alertOptions;
@property (strong, nonatomic) UIViewController* sourceViewController;
@property (strong, nonatomic) UIImage* imagePicked;
@property (strong, nonatomic) UIPopoverController* popover;

+ (KonotorImageInput*) sharedInstance;
+ (void) showInputOptions:(UIViewController*) viewController;
+ (void) rotateToOrientation:(UIInterfaceOrientation) orientation duration:(NSTimeInterval) duration;

@end
