//
//  DetailsViewController.h
//  iMayotte Lexique
//
//  Created by Mouhamadi ABDULLATIF on 15/09/11.
//  Copyright 2011 ABDULLATIF Industry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBConnect/FBConnect.h"

#import "FBLoginTitle.h"

#import "Reachability.h"

#import "MBProgressHUD.h"

#import "FireUIPagedScrollView.h"






//@class Facebook;

//@class NoteView;

@class MOGlassButton;

@interface DetailsViewController : UIViewController <FBRequestDelegate, FBDialogDelegate, FBSessionDelegate, MBProgressHUDDelegate> {
    
    Facebook* _facebook;
    
    NSArray* _permissions;
    
    FBLoginTitle * _fbState;
    
    
    //IBOutlet UIButton* _publishButton;
    IBOutlet UIButton* _publishButton;
    
    
    // track the network status
    NetworkStatus internetConnectionStatus;

    
    MBProgressHUD *HUD;
    
    
    BOOL didFbPostSuccesfulDone;
    BOOL didFbPostGetError;

}

@property (nonatomic, retain) IBOutlet FireUIPagedScrollView * pagedScrollView;

@property (nonatomic, retain) FBLoginTitle *fbState;


@property (nonatomic, retain) NSString *word;
@property (nonatomic, retain) NSString *definition;


@property (nonatomic, retain) Facebook *facebook;

// network
@property NetworkStatus internetConnectionStatus;

- (BOOL)isNetworkAvailable;

// facebook

- (void)login;
- (void)logout;

-(IBAction)fbStateTitleClick:(id)sender;
-(IBAction)publishStream:(id)sender;

// mytask
- (BOOL)myTask;

@end
