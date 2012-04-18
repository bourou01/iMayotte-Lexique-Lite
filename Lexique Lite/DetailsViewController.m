//
//  DetailsViewController.m
//  iMayotte Lexique
//
//  Created by Mouhamadi ABDULLATIF on 15/09/11.
//  Copyright 2011 ABDULLATIF Industry. All rights reserved.
//

#import "DetailsViewController.h"

#import "SimplePage1View.h"


// id de l'appli sur facebook
static NSString *kAppId = @"267872783253733";


@implementation DetailsViewController

#define kHostName @"www.facebook.com"

@synthesize word;
@synthesize definition;
@synthesize facebook = _facebook;
@synthesize internetConnectionStatus;
@synthesize pagedScrollView;

@synthesize fbState =_fbState;



/*
 *---------------------------------------------------------------------------
 *
 * @prototype: - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
 * @brief    : The designated initializer
 * @param 1  : nibNameOrNil
 * @param 2  : nibBundleOrNil
 * @return   : id
 *
 *---------------------------------------------------------------------------
 */
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (!kAppId) {
        NSLog(@"missing app id!");
        exit(1);
        return nil;
    }

    
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        
        _permissions = [[[NSArray alloc] initWithObjects:
                                @"publish_stream",
                                nil] retain];
        _facebook = [[[Facebook alloc] initWithAppId:kAppId andDelegate:self] retain];
    }
    return self;
}


/*
 *---------------------------------------------------------------------------
 *
 * @prototype: - (void)dealloc
 * @brief    : Libération des objets
 * @return   : none
 *
 *---------------------------------------------------------------------------
 */
- (void)dealloc
{
    [super dealloc];



    // facebook
    [_fbState release];
    
    //[_publishButton release];
    
    [_publishButton release];
    
    [_facebook release];
    [_permissions release];

    [word release];
    [definition release];

    
}


#pragma mark facebook connexion
/*
 *---------------------------------------------------------------------------
 *
 * @prototype: - (void)login
 * @brief    : Show the authorization dialog.
 * @return   : none
 *
 *---------------------------------------------------------------------------
 */
- (void)login {
    [_facebook authorize:_permissions];
}

/*
 *---------------------------------------------------------------------------
 *
 * @prototype: - (void)logout
 * @brief    : Invalidate the access token and clear the cookie.
 * @return   : none
 *
 *---------------------------------------------------------------------------
 */
- (void)logout {
    [_facebook logout:self];
}

/*
 *---------------------------------------------------------------------------
 *
 * @prototype: - (IBAction)fbStateTitleClick:(id)sender
 * @brief    : Called on a login/logout button click.
 * @param 1  : sender
 * @return   : action
 *
 *---------------------------------------------------------------------------
 */
- (IBAction)fbStateTitleClick:(id)sender
{
    if (_fbState.isLoggedIn) {
        [self logout];
    } else {
        [self login];
    }
}






/*
 *---------------------------------------------------------------------------
 *
 * @prototype: - (IBAction)publishStream:(id)sender
 * @brief    : Publish a stream on the wall
 * @param 1  : sender
 * @return   : action
 *
 *---------------------------------------------------------------------------
 */
- (IBAction)publishStream:(id)sender {
    
    self.navigationController.navigationBarHidden = YES;

    NSString *message = [NSString stringWithFormat:@"J'ai appris un mot en mahorais via iMayotte Lexique : \n\n'%@' signifie : \n\n'%@'", self.word, self.definition];
 
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   message , @"message",
                                   nil];

    [_facebook requestWithGraphPath:@"me/feed" andParams:params andHttpMethod:@"POST" andDelegate:self];

    didFbPostGetError = NO;
    didFbPostSuccesfulDone = NO;
    
    // MBProgressHUD
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
	
    HUD.delegate = self;
    HUD.labelText = @"Chargement";	
    [HUD showWhileExecuting:@selector(myTask) onTarget:self withObject:nil animated:YES];

}

/*
 *---------------------------------------------------------------------------
 *
 * @prototype: - (BOOL)myTask
 * @brief    : Perform tasks while there is not response from the request
 * @return   : oui ou non
 *
 *---------------------------------------------------------------------------
 */
- (BOOL)myTask {

    int i;
    for (i=0; i<=10; i++)
    {
        if (didFbPostGetError == YES)
            break;
        else if (didFbPostSuccesfulDone == YES)
            break;

        sleep(1);
    }

    self.navigationController.navigationBarHidden = NO;
    return YES;
}

/*
 *---------------------------------------------------------------------------
 *
 * @prototype: - (void)fbDidLogin
 * @brief    : Called when the user has logged in successfully.
 * @return   : none
 *
 *---------------------------------------------------------------------------
 */
- (void)fbDidLogin {
    _publishButton.hidden = NO;
    
    _fbState.isLoggedIn = YES;

    // update fbState
    self.navigationItem.rightBarButtonItem.title = [_fbState buttonTitle];
    
    
    // perform session
    [[NSUserDefaults standardUserDefaults] setObject:_facebook.accessToken forKey:@"AccessToken"];
    [[NSUserDefaults standardUserDefaults] setObject:_facebook.expirationDate forKey:@"ExpirationDate"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

/*
 *---------------------------------------------------------------------------
 *
 * @prototype: -(void)fbDidNotLogin:(BOOL)cancelled
 * @brief    : Called when the user canceled the authorization dialog.
 * @return   : none
 *
 *---------------------------------------------------------------------------
 */
-(void)fbDidNotLogin:(BOOL)cancelled {
    NSLog(@"did not login");
}
/*
 *---------------------------------------------------------------------------
 *
 * @prototype:- (void)fbDidLogout
 * @brief    : Called when the request logout has succeeded.
 * @return   : none
 *
 *---------------------------------------------------------------------------
 */
- (void)fbDidLogout {
    _publishButton.hidden = YES;

    _fbState.isLoggedIn = NO;

    // update fbState
    self.navigationItem.rightBarButtonItem.title = [_fbState buttonTitle];
    
    
    // on supprime la session
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"AccessToken"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"ExpirationDate"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


#pragma mark facebook request

/*
 *---------------------------------------------------------------------------
 *
 * @prototype: - (void)requestLoading:(FBRequest *)request
 * @brief    : Called just before the request is sent to the server.
 * @param 1  : request
 * @return   : none
 *
 *---------------------------------------------------------------------------
 */
- (void)requestLoading:(FBRequest *)request
{
    NSLog(@"request loaded");
}

/*
 *---------------------------------------------------------------------------
 *
 * @prototype: - (void)request:(FBRequest *)request didReceiveResponse:(NSURLResponse *)response
 * @brief    : Called when the server responds and begins to send back data.
 * @param 1  : request
 * @param 2  : response
 * @return   : none
 *
 *---------------------------------------------------------------------------
 */
- (void)request:(FBRequest *)request didReceiveResponse:(NSURLResponse *)response
{
    didFbPostSuccesfulDone = YES;
    NSLog(@"request response");
}

/*
 *---------------------------------------------------------------------------
 *
 * @prototype: - (void)request:(FBRequest *)request didFailWithError:(NSError *)error
 * @brief    : Called when an error prevents the request from completing successfully.
 * @param 1  : request
 * @param 2  : error
 * @return   : none
 *
 *---------------------------------------------------------------------------
 */
- (void)request:(FBRequest *)request didFailWithError:(NSError *)error
{
    didFbPostGetError = YES;
    NSLog(@"request error");
}

#pragma mark - View lifecycle


- (void)viewDidLoad
{
    [super viewDidLoad];

    // customize the facebook
    
    _fbState = [[FBLoginTitle alloc] init];
    

    
    UIBarButtonItem *fbStateTitle = [[UIBarButtonItem alloc] initWithTitle:[_fbState buttonTitle] style:UIBarButtonItemStylePlain target:self action:@selector(fbStateTitleClick:)];
    self.navigationItem.rightBarButtonItem = fbStateTitle;
    [fbStateTitle release];

    
////////////////////////////////////////////////////////////////////////////////
// 
    // met a jour le titre du navigation controller
    self.navigationController.topViewController.title = @"Détails";
    
    // Configure buttons added to XIB
	//[self.button setupAsGreenButton];
	//[self.smallButton setupAsSmallGreenButton];
    //[_publishButton setupAsGreenButton];
    

    
    
    
////////////////////////////////////////////////////////////////////////////////
// configure les pages views
    
    /*
     Nothing to see here hehe, everything was made in Interface Builder :) 
     If you want to use UIPageControl or UISegmentedControl 
     you can use Interface Builder to assign the outlets properties pageControl and segmentedControl.
     */
    
    // Add Page 1
    
    SimplePage1View *sp1v = [[SimplePage1View alloc] initWithNibName:@"SimplePage1View" bundle:nil];
    
    sp1v.word = word;
    sp1v.definition = definition;

    [self.pagedScrollView addPagedViewController:sp1v];
    
    [sp1v release];
    
    
////////////////////////////////////////////////////////////////////////////////
// Test de reachability de connexion
    
    // verifie s'il y a une connexion internet
    didFbPostSuccesfulDone = NO;
    didFbPostGetError = NO;

    // suprime le bouton de connexion si 
    if ([self isNetworkAvailable] == YES)
    {
        [self.navigationItem.rightBarButtonItem setEnabled:YES];
        _publishButton.hidden = NO;
    }
    else
    {
        [self.navigationItem.rightBarButtonItem setEnabled:NO];
        _publishButton.hidden = YES;
    }
    
////////////////////////////////////////////////////////////////////////////////
// Gestion des sessions facebook  
    
     //Restauration de l'ancienne session
    _facebook.accessToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"AccessToken"];
    _facebook.expirationDate = (NSDate *)[[NSUserDefaults standardUserDefaults] objectForKey:@"ExpirationDate"];
    
    // Vérifie si la session restauré est valide
    if ([_facebook isSessionValid] == YES && [self isNetworkAvailable] == YES) {
        
        NSLog(@"connect");
        
        _publishButton.hidden = NO;
        
        _fbState.isLoggedIn = YES;

        // update fbState
        self.navigationItem.rightBarButtonItem.title = [_fbState buttonTitle];

    }
    else
    {
        
        NSLog(@"not connect");
        
        _publishButton.hidden = YES;

        _fbState.isLoggedIn = NO;
        

        // update fbState
        self.navigationItem.rightBarButtonItem.title = [_fbState buttonTitle];
        
    }
}


/*
 *---------------------------------------------------------------------------
 *
 * @prototype: - (BOOL)isNetworkAvailable
 * @brief    : vérifie s'il y a une connexion internet
 * @return   : oui = connexion/non = pas de connexion
 *
 *---------------------------------------------------------------------------
 */
- (BOOL)isNetworkAvailable
{
    // Query the SystemConfiguration framework for the state of the device's network connections.
    Reachability *reachability = [Reachability reachabilityForInternetConnection]; // release ??
    
    NetworkStatus internetStatus = [reachability currentReachabilityStatus];
    
    self.internetConnectionStatus = internetStatus;
    

    if (self.internetConnectionStatus == NotReachable) {
        //show an alert to let the user know that they can't connect...
        return NO;
    }  else {
        // If the network is reachable, make sure the login button is enabled.
        return YES;
    }
}


/*
 *---------------------------------------------------------------------------
 *
 * @prototype: - (void)viewDidDisappear:(BOOL)animated
 * @brief    : on s'assure que la requête d'envoi du message de poste s'arrète une fois la vue quitée
 * @return   : none
 *
 *---------------------------------------------------------------------------
 */
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [_facebook cancelRequest];
}

/*
 *---------------------------------------------------------------------------
 *
 * @prototype: - (void)viewWillDisappear:(BOOL)animated
 * @brief    : on s'assure que la requête d'envoi du message de poste s'arrète une fois la vue quitée
 * @return   : none
 *
 *---------------------------------------------------------------------------
 */
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_facebook cancelRequest];
}

/*
 *---------------------------------------------------------------------------
 *
 * @prototype: - (void)viewDidUnload
 * @brief    : on s'assure que la requête d'envoi du message de poste s'arrète une fois la vue quitée
 * @return   : none
 *
 *---------------------------------------------------------------------------
 */
- (void)viewDidUnload
{
    [super viewDidUnload];
    [_facebook cancelRequest];
    
    self.pagedScrollView = nil;
    
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
}

/*
 *---------------------------------------------------------------------------
 *
 * @prototype: - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
 * @brief    : permet la rotation de la view
 * @param 1  : interfaceOrientation = rotation ou pas
 * @return   : oui = rotation/non = pas de rotation
 *
 *---------------------------------------------------------------------------
 */
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


@end
