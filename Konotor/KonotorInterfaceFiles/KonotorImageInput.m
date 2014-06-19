//
//  KonotorImageInput.m
//  KonotorDemo
//
//  Created by Srikrishnan Ganesan on 10/03/14.
//  Copyright (c) 2014 Demach. All rights reserved.
//

#import "KonotorImageInput.h"
#import "KonotorFeedbackScreen.h"
#import <QuartzCore/QuartzCore.h>

static KonotorImageInput* konotorImageInput=nil;

@implementation KonotorImageInput
@synthesize sourceView,alertOptions,sourceViewController,imagePicked,popover;

+ (KonotorImageInput*) sharedInstance
{
    if(konotorImageInput==nil){
        konotorImageInput=[[KonotorImageInput alloc] init];
    }
    return konotorImageInput;
}


+ (void) showInputOptions:(UIViewController*) viewController
{
    UIActionSheet* inputOptions=[[UIActionSheet alloc] initWithTitle:@"Message Type" delegate:nil cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Select Existing Image",@"New Image via Camera",
                                 nil];
    inputOptions.delegate=[KonotorImageInput sharedInstance];
    konotorImageInput.sourceViewController=viewController;
    konotorImageInput.sourceView=viewController.view;
    [inputOptions showInView:konotorImageInput.sourceView];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //  [actionSheet dismissWithClickedButtonIndex:buttonIndex animated:YES];
    
    switch (buttonIndex) {
        case 0:
            [self showImagePicker];
            break;
        case 1:
            [self showCamPicker];
            break;

        default:
            break;
    }
}


- (void)showCamPicker
{
    UIImagePickerController* imagePicker=[[UIImagePickerController alloc] init];
    [imagePicker setAllowsEditing:NO];
    imagePicker.delegate=self;
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
        [self.sourceViewController presentViewController:imagePicker animated:YES completion:NULL];
    }
    else{
        UIAlertView *alertview=[[UIAlertView alloc] initWithTitle:@"Camera Unavailable" message:@"Sorry! Your device doesn't have a camera, or the camera is not available for use." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertview show];
    }
}

- (void)showImagePicker
{
    UIImagePickerController* imagePicker=[[UIImagePickerController alloc] init];
    [imagePicker setAllowsEditing:NO];
    imagePicker.delegate=self;
    [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        popover=[[UIPopoverController alloc] initWithContentViewController:imagePicker];
        [popover presentPopoverFromRect:CGRectMake(self.sourceViewController.view.frame.origin.x,self.sourceViewController.view.frame.origin.y+sourceViewController.view.frame.size.height-20,40,40) inView:self.sourceViewController.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    else
        [self.sourceViewController presentViewController:imagePicker animated:YES completion:NULL];
}

+ (void) rotateToOrientation:(UIInterfaceOrientation) orientation duration:(NSTimeInterval) duration
{
    if(konotorImageInput.imagePicked){
        UIImage* img=[KonotorImageInput sharedInstance].imagePicked;
        [[KonotorImageInput sharedInstance] dismissImageSelection];
        
        [KonotorImageInput sharedInstance].imagePicked=img;
        
        NSDictionary* info=[[NSDictionary alloc] initWithObjectsAndKeys:img,UIImagePickerControllerOriginalImage,nil];
        [[KonotorImageInput sharedInstance] imagePickerController:nil didFinishPickingMediaWithInfo:info];
 
    }
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage* selectedImage=(UIImage*)[info valueForKey:UIImagePickerControllerOriginalImage];
    self.imagePicked=selectedImage;
    if((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)&&popover){
        [popover dismissPopoverAnimated:YES];
        popover=nil;
    }
    else
        [picker dismissViewControllerAnimated:NO completion:NULL];

    UIImageView* selectedImageView=[[UIImageView alloc] initWithImage:selectedImage];
    float height=MIN(selectedImage.size.height,([[UIScreen mainScreen] bounds].size.height-100-50-60)*2);
    float width=MIN(520,selectedImage.size.width*height/selectedImage.size.height);
    float screenHeight,screenWidth;
    
    if(((!picker)&&(UIInterfaceOrientationIsPortrait(sourceViewController.interfaceOrientation)))||((picker)&&(UIInterfaceOrientationIsLandscape(sourceViewController.interfaceOrientation))))
    {
        height=MIN(selectedImage.size.height,([[UIScreen mainScreen] bounds].size.width-100-50-60)*2);
        width=MIN(520,selectedImage.size.width*height/selectedImage.size.height);
        screenHeight=[[UIScreen mainScreen] bounds].size.width;
        screenWidth=[[UIScreen mainScreen] bounds].size.height;
    }
    else{
        height=MIN(selectedImage.size.height,([[UIScreen mainScreen] bounds].size.height-100-50-60)*2);
        width=MIN(520,selectedImage.size.width*height/selectedImage.size.height);
        screenHeight=[[UIScreen mainScreen] bounds].size.height;
        screenWidth=[[UIScreen mainScreen] bounds].size.width;
    }
    
    height=selectedImage.size.height*width/selectedImage.size.width;
    //float width=selectedImage.size.width*150/selectedImage.size.height;
    [selectedImageView setFrame:CGRectMake((screenWidth-40-width/2)/2, 20+((screenHeight-100-50-50)-height/2)/2,width/2, height/2)];
    selectedImageView.layer.cornerRadius=15.0;
    
    UIView* alertOptionsBackground=[[UIView alloc] initWithFrame:CGRectMake(0,0,screenWidth,screenHeight)];
    [alertOptionsBackground setBackgroundColor:[UIColor colorWithRed:0.4 green:0.4 blue:0.4 alpha:0.4]];
    
    alertOptions=[[UIView alloc] initWithFrame:CGRectMake(20,50,screenWidth-40,screenHeight-100)];
    [alertOptions setBackgroundColor:[UIColor whiteColor]];
    alertOptions.layer.cornerRadius=15.0;
    alertOptions.layer.shadowColor=[[UIColor blackColor] CGColor];
    alertOptions.layer.shadowOffset=CGSizeMake(1.0, 1.0);
    alertOptions.layer.shadowRadius=3.0;
    alertOptions.layer.shadowOpacity=1.0;
    
    [alertOptionsBackground addSubview:alertOptions];
    
    
    UIButton* buttonCancel=[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    
   // [buttonCancel setImage:[UIImage imageNamed:@"konotor_cross.png"] forState:UIControlStateNormal];
    [buttonCancel setTitle:@"X" forState:UIControlStateNormal];
    [buttonCancel setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    buttonCancel.layer.cornerRadius=15.0;
    buttonCancel.layer.borderWidth=3.5;
    buttonCancel.layer.borderColor=[[UIColor whiteColor] CGColor];
    
    if(picker.sourceType==UIImagePickerControllerSourceTypePhotoLibrary)
        [buttonCancel addTarget:self action:@selector(dismissImageSelection) forControlEvents:UIControlEventTouchUpInside];
    else
        [buttonCancel addTarget:self action:@selector(cleanUpImageSelection) forControlEvents:UIControlEventTouchUpInside];
    
    [alertOptions addSubview:buttonCancel];
    [alertOptions bringSubviewToFront:buttonCancel];
    [alertOptions addSubview:selectedImageView];
    
    UIButton* send=[[UIButton alloc] initWithFrame:CGRectMake(screenWidth-16-80-20, screenHeight-180, 80, 45)];
    //[send setImage:[UIImage imageNamed:@"konotor_send.png"] forState:UIControlStateNormal];
    [send setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [send setTitle:@"SEND" forState:UIControlStateNormal];
    [send addTarget:self action:@selector(dismissImageSelectionWithSelectedImage:) forControlEvents:UIControlEventTouchUpInside];
    
   
    
    
    [alertOptions addSubview:send];
  //  [alertOptions addSubview:sendLabel];
    
    
    [sourceView addSubview:alertOptionsBackground];
    
}


- (void) cleanupMenuSent
{
    [self cleanUpImageSelection];
}

- (void) dismissImageSelection
{
    UIView* alertOptionsBackground=[alertOptions superview];
    [alertOptionsBackground removeFromSuperview];
    alertOptions=nil;
    alertOptionsBackground=nil;
    self.imagePicked=nil;
}

- (void) cleanUpImageSelection
{
    [self dismissImageSelection];
   // [self.sourceViewController dismissViewControllerAnimated:NO completion:NULL];
    self.imagePicked=nil;
}

- (void) cleanupMenu
{
    UIView * win=[[[UIApplication sharedApplication] delegate] window];
    UIView* sendLabel=(UIView*)[win viewWithTag:5000];
    UIView* editLabel=(UIView*)[win viewWithTag:5001];
    [sendLabel setHidden:NO];
    [editLabel setHidden:NO];
}

- (void) dismissImageSelectionWithSelectedImage:(id) sender
{    
    
//    [(AppDelegate*)[[UIApplication sharedApplication] delegate] sendImage:button.photo forConversation:self.conversation participants:self.participants withSubject:self.conversation.subject withMetrics:nil withPhotoURL:self.conversation.photoURL];
    if(self.imagePicked)
        [Konotor uploadImage:self.imagePicked];
    [self cleanUpImageSelection];
    [KonotorFeedbackScreen refreshMessages];
    self.imagePicked=nil;

}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    if((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)&&popover){
        [popover dismissPopoverAnimated:YES];
        popover=nil;
    }
    else
        [picker dismissViewControllerAnimated:YES completion:NULL];
    //  [self loadViewFirstTime];
}



@end
