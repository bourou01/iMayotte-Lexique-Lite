//
//  DictionaryViewController.m
//  imayottelexique
//
//  Created by bourou01 on 02/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "RootViewController.h"
#import <QuartzCore/QuartzCore.h>





#define PRETTY_BLUE [UIColor colorWithRed:51.0/255.0 green:102.0/255.0 blue:153.0/255.0 alpha:1.0]

@implementation RootViewController

@synthesize savedSearchTerm = savedSearchTerm_;
@synthesize savedScopeButtonIndex = savedScopeButtonIndex_;
@synthesize searchWasActive = searchWasActive_;
@synthesize managedObjectContext = managedObjectContext_;
@synthesize fetchedResultsController = fetchedResultsController_;
@synthesize searchFetchedResultsController = searchFetchedResultsController_;
@synthesize mySearchDisplayController;
@synthesize currentLanguageProperty = currentLanguageProperty_;

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
    [currentLanguageProperty_ release];
    // seachBar
    [savedSearchTerm_ release];
    [managedObjectContext_ release];
    [fetchedResultsController_ release];
    [searchFetchedResultsController_ release];
    [mySearchDisplayController release];
    
}
/*
 *---------------------------------------------------------------------------
 *
 * @prototype: - (id)initWithStyle:(UITableViewStyle)style
 * @brief    : Initialise le style du tableView
 * @param 1  : style = le style choisit
 * @return   : none
 *
 *---------------------------------------------------------------------------
 */
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    
    
    
    return self;
}


/*
 *---------------------------------------------------------------------------
 *
 * @prototype: - (void)changeLanguageList:(id)sender
 * @brief    : Intervertir la langue du lexique 
 * @param 1  : sender
 * @return   : none
 *
 *---------------------------------------------------------------------------
 */
- (void)changeLanguageList:(id)sender
{
    
    NSDictionary *myMahoraisDictionary = [NSDictionary dictionary];
    myMahoraisDictionary = [NSDictionary dictionaryWithDictionary:[self performLanguage:@"ma"]];
    
    NSDictionary *myFrancaisDictionary = [NSDictionary dictionary];
    myFrancaisDictionary = [NSDictionary dictionaryWithDictionary:[self performLanguage:@"fr"]];
    
    // si c'est reglé en mahorais
    if ([[currentLanguageProperty_ objectForKey:@"title"] isEqualToString:[myMahoraisDictionary objectForKey:@"title"]])
    {
        currentLanguageProperty_ = [[NSDictionary dictionaryWithDictionary:myFrancaisDictionary] retain];
    }
    else
    {
        currentLanguageProperty_ = [[NSDictionary dictionaryWithDictionary:myMahoraisDictionary] retain];
    }
    self.navigationItem.title = [currentLanguageProperty_ objectForKey:@"title"];
    
    // on initialise pour forcer le réinitialisation de la tableView
    fetchedResultsController_ = nil;
    searchFetchedResultsController_ = nil;
    
    
    [[self tableView] reloadData];
    
    // Replace la search bar à la bonne position
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
}
/*
 *---------------------------------------------------------------------------
 *
 * @prototype: - (NSDictionary *)performLanguage:(NSString *)whichLanguage
 * @brief    : fournir les paramètre d'un langage
 * @param 1  : whichLanguage = "ma" pour le mahorais et "fr" pour le francais
 * @return   : Un NSDictionary contenant les paramètres de ce langage
 *
 *---------------------------------------------------------------------------
 */
- (NSDictionary *)performLanguage:(NSString *)whichLanguage
{
    // auto released
    NSDictionary *myLanguageProperty = [NSDictionary dictionary];
    
    if ([whichLanguage isEqualToString:@"ma"])
    {
        myLanguageProperty = [NSDictionary dictionaryWithObjectsAndKeys:@"Mahorais @ Français", @"title", @"DictionaryM", @"entity", @"mahorais", @"word", @"francais", @"definition", nil];
    }
    else if ([whichLanguage isEqualToString:@"fr"])
    {
        myLanguageProperty = [NSDictionary dictionaryWithObjectsAndKeys:@"Français @ Mahorais", @"title", @"DictionaryF", @"entity", @"francais", @"word", @"mahorais", @"definition", nil];
    }
    return myLanguageProperty;
}

/*
 *---------------------------------------------------------------------------
 *
 * @prototype: - (NSFetchedResultsController *)fetchedResultsControllerForTableView:(UITableView *)tableView
 * @brief    : retrieve the correct FRC when working with all of the UITableViewDelegate/DataSource methods
 * @param 1  : tableView dont on veut communiquer des résultats de recherche dans la bdd
 * @return   : résultats de recherche dans la bdd
 *
 *---------------------------------------------------------------------------
 */
- (NSFetchedResultsController *)fetchedResultsControllerForTableView:(UITableView *)tableView
{
    return tableView == self.tableView ? self.fetchedResultsController : self.searchFetchedResultsController;
}


/*
 *---------------------------------------------------------------------------
 *
 * @prototype: - (void)fetchedResultsController:(NSFetchedResultsController *)fetchedResultsController configureCell:(UITableViewCell *)theCell atIndexPath:(NSIndexPath *)theIndexPath
 * @brief    : le controlleur de recherche
 * @param 1  : fetchedResultsController
 * @param 2  : theCell
 * @param 3  : theIndexPath
 * @return   : résultats de recherche dans la bdd
 *
 *---------------------------------------------------------------------------
 */
- (void)fetchedResultsController:(NSFetchedResultsController *)fetchedResultsController configureCell:(UITableViewCell *)theCell atIndexPath:(NSIndexPath *)theIndexPath
{
    theCell.textLabel.textColor = PRETTY_BLUE;
    theCell.detailTextLabel.textColor = [UIColor orangeColor];
    
    // your cell guts here
    if ([[currentLanguageProperty_ objectForKey:@"word"] isEqualToString:@"mahorais"])
    {
        DictionaryM *dictionaryM = [self.searchFetchedResultsController objectAtIndexPath:theIndexPath];
        theCell.textLabel.text = dictionaryM.mahorais;
        theCell.detailTextLabel.text = dictionaryM.francais;
        
    }
    else if ([[currentLanguageProperty_ objectForKey:@"word"] isEqualToString:@"francais"])
    {
        DictionaryF *dictionaryF = [self.searchFetchedResultsController objectAtIndexPath:theIndexPath];
        theCell.textLabel.text = dictionaryF.francais;
        theCell.detailTextLabel.text = dictionaryF.mahorais;
    }
}

/*
 *---------------------------------------------------------------------------
 *
 * @prototype: - (void)didReceiveMemoryWarning
 * @brief    : Sauvegarde les resultats de recherche s'il y a un problème de mémoire
 * @return   : none
 *
 *---------------------------------------------------------------------------
 */
- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
    self.searchWasActive = [self.searchDisplayController isActive];
    self.savedSearchTerm = [self.searchDisplayController.searchBar text];
    self.savedScopeButtonIndex = [self.searchDisplayController.searchBar selectedScopeButtonIndex];
    
    fetchedResultsController_.delegate = nil;
    [fetchedResultsController_ release];
    fetchedResultsController_ = nil;
    searchFetchedResultsController_.delegate = nil;
    [searchFetchedResultsController_ release];
    searchFetchedResultsController_ = nil;
}

#pragma mark - View lifecycle
/*
 *---------------------------------------------------------------------------
 *
 * @prototype: - (void)viewDidLoad
 * @brief    : exécuté une fois que la vue à été chargé
 * @return   : none
 *
 *---------------------------------------------------------------------------
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////
    // Configure navigation Controller
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBar.tintColor = PRETTY_BLUE;
    // customize the back button
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Retour" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = backButton;
    [backButton release];
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////
    // Initialise la langue à "mahorais"
    
    NSDictionary *myLanguageProperty = [NSDictionary dictionary];
    myLanguageProperty = [NSDictionary dictionaryWithDictionary:[self performLanguage:@"fr"]];
    currentLanguageProperty_ = [[NSMutableDictionary dictionaryWithDictionary:myLanguageProperty] retain];
    self.navigationItem.title = [currentLanguageProperty_ objectForKey:@"title"];
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////
    // Corrige une erreur
    
    /* corriger une erreur !
     In short you are trying to fetch an entity from an 
     objectContext that hadn't been set up yet. 
     Your options therefore are to set it up right then 
     or do elsewhere in the app before this view loads.
     */
    if (managedObjectContext_ == nil) 
    { 
        managedObjectContext_ = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext]; 
    }
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////
    // Initialise la searchBar et la configure
    
    UISearchBar *searchBar = [[[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 44.0)] autorelease];
    searchBar.autoresizingMask = (UIViewAutoresizingFlexibleWidth);
    searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    
    searchBar.tintColor = PRETTY_BLUE;
    searchBar.translucent = YES;
    
    searchBar.placeholder = @"Chercher";
    
    //insère la searchBar dans le header du tableView 
    self.tableView.tableHeaderView = searchBar;
    
    // configure des delegate
    self.mySearchDisplayController = [[[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self] autorelease];
    self.mySearchDisplayController.delegate = self;
    self.mySearchDisplayController.searchResultsDataSource = self;
    self.mySearchDisplayController.searchResultsDelegate = self;
    
    
    // restore search settings if they were saved in didReceiveMemoryWarning.
    if (self.savedSearchTerm)
    {
        [self.searchDisplayController setActive:self.searchWasActive];
        [self.searchDisplayController.searchBar setSelectedScopeButtonIndex:self.savedScopeButtonIndex];
        [self.searchDisplayController.searchBar setText:savedSearchTerm_];
        
        self.savedSearchTerm = nil;
    }
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////
    // Initialise les boutons et les configure
    
    // Change Language Button
    //UIBarButtonItem *changeLanguageButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(changeLanguageList:)];
    UIBarButtonItem *changeLanguageButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"bascule.png"] style:UIBarButtonItemStylePlain target:self action:@selector(changeLanguageList:)];
    self.navigationItem.rightBarButtonItem = changeLanguageButton;
    [changeLanguageButton release];
    
    // Call AboutView
    //UIBarButtonItem *callAboutViewButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(performAboutView:)];
    //UIBarButtonItem *callAboutViewButton = [[UIBarButtonItem alloc] initWithTitle:@"Info" style:UIBarButtonItemStyleBordered target:self action:@selector(performAboutView:) ];
    
    
    
    
    //UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
    //[infoButton addTarget:self action:@selector(performAboutView:) forControlEvents:UIControlEventTouchUpInside];
    //self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:infoButton];
    
    
    UIBarButtonItem *infoButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"about.png"] style:UIBarButtonItemStylePlain target:self action:@selector(performAboutView:)];
    self.navigationItem.leftBarButtonItem = infoButton;
    
    [infoButton release];
    
}

/*
 *---------------------------------------------------------------------------
 *
 * @prototype: - (void)performAboutView:(id)sender
 * @brief    : affiche la page Info
 * @param 1  : sender
 * @return   : none
 *
 *---------------------------------------------------------------------------
 */
- (void)performAboutView:(id)sender
{
    /*
     AboutViewController *about = [[AboutViewController alloc] init];
     [self.navigationController pushViewController:about animated:YES];
     [about release];
     */
    
    //Init Animation
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration: 0.50];
    
    //UIViewAnimationTransitionCurlUp
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.navigationController.view cache:YES];
    
    //Create ViewController
    AboutViewController *about = [[AboutViewController alloc] init];
    
    [self.navigationController pushViewController:about animated:NO];
    [about release];
    
    //Start Animation
    [UIView commitAnimations];
}

/*
 *---------------------------------------------------------------------------
 *
 * @prototype: - (void)viewDidDisappear:(BOOL)animated
 * @brief    : sauvegarde les resultats de la recherche pour pouvoir les remettre plutard
 * @param 1  : animated = animé ou pas
 * @return   : none
 *
 *---------------------------------------------------------------------------
 */
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    // save the state of the search UI so that it can be restored if the view is re-created
    self.searchWasActive = [self.searchDisplayController isActive];
    self.savedSearchTerm = [self.searchDisplayController.searchBar text];
    self.savedScopeButtonIndex = [self.searchDisplayController.searchBar selectedScopeButtonIndex];
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

#pragma mark - Table view data source

/*
 *---------------------------------------------------------------------------
 *
 * @prototype: - (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
 * @brief    : calcule le nombre de sections visible sur la tableView
 * @param 1  : tableView
 * @return   : le nombre de sections
 *
 *---------------------------------------------------------------------------
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    NSInteger count = [[[self fetchedResultsControllerForTableView:tableView] sections] count];
    return count;
}

/*
 *---------------------------------------------------------------------------
 *
 * @prototype: - (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
 * @brief    : rassembler les indexes des sections
 * @param 1  : tableView
 * @return   : le tableau contenant les indexes des sections
 *
 *---------------------------------------------------------------------------
 */
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    
    return [[self fetchedResultsControllerForTableView:tableView] sectionIndexTitles];
}





/*
 *---------------------------------------------------------------------------
 *
 * @prototype: - (NSString *)controller:(NSFetchedResultsController *)controller sectionIndexTitleForSectionName:(NSString *)sectionName 
 * @brief    : corriger les indexes sur la barre des indexes
 * @param 1  : controller
 * @param 1  : sectionName
 * @return   : l'indexe corrigé
 *
 *---------------------------------------------------------------------------
 */
- (NSString *)controller:(NSFetchedResultsController *)controller sectionIndexTitleForSectionName:(NSString *)sectionName {
    
    return sectionName;
}


/*
 *---------------------------------------------------------------------------
 *
 * @prototype: - (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
 * @brief    : section titles to display in section index view (e.g. "ABCD...Z#")
 * @param 1  : tableView
 * @param 2  : title
 * @param 3  : index
 * @return   : le nombre d'indexes
 *
 *---------------------------------------------------------------------------
 */


- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    
    return [[self fetchedResultsControllerForTableView:tableView] sectionForSectionIndexTitle:title atIndex:index];
}


/*
 *---------------------------------------------------------------------------
 *
 * @prototype: - (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
 * @brief    : calcule la l'indexe à attribuer à un ensemble de mots
 * @param 1  : tableView
 * @param 2  : section = nombre de sections
 * @return   : l'indexe calculé
 *
 *---------------------------------------------------------------------------
 */
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[[self fetchedResultsControllerForTableView:tableView] sections] objectAtIndex:section];
    return [sectionInfo name];
}

/*
 *---------------------------------------------------------------------------
 *
 * @prototype: - (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
 * @brief    : calcule la l'indexe à attribuer
 * @param 1  : tableView
 * @param 2  : section = nombre de sections
 * @return   : l'indexe calculé
 *
 *---------------------------------------------------------------------------
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    
    NSInteger numberOfRows = 0;
    NSFetchedResultsController *fetchController = [self fetchedResultsControllerForTableView:tableView];
    NSArray *sections = fetchController.sections;
    if(sections.count > 0)
    {
        id <NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:section];
        numberOfRows = [sectionInfo numberOfObjects];
    }    
    
    return numberOfRows;
}

/*
 *---------------------------------------------------------------------------
 *
 * @prototype: - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
 * @brief    : Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)
 * @param 1  : tableView
 * @param 2  : indexPath = l'indexe
 * @return   : tableView = cellule
 *
 *---------------------------------------------------------------------------
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Indique qu’une touche sur la ligne permet d’accéder à des informations plus détaillées.
    //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    UIFont *cellFont = [UIFont boldSystemFontOfSize:19];
    cell.textLabel.font = cellFont;
    
    // remove the separator style
    //tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    
    
    
    // change the selection Style
    // cell.selectionStyle = UITableViewCellSelectionStyleGray;
    
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////
    // Configure indexes
    
    // Configure the cell...
    [self fetchedResultsController:[self fetchedResultsControllerForTableView:tableView] configureCell:cell atIndexPath:indexPath];
    return cell;
}

#pragma mark -
#pragma mark Content Filtering
/*
 *---------------------------------------------------------------------------
 *
 * @prototype: - (void)filterContentForSearchText:(NSString*)searchText scope:(NSInteger)scope
 * @brief    : met a jour le filtre ???
 * @param 1  : searchText = le mot qu'on souhaite chercher
 * @param 2  : scope = ??
 * @return   : none
 *
 *---------------------------------------------------------------------------
 */
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSInteger)scope
{
    // update the filter, in this case just blow away the FRC and let lazy evaluation create another with the relevant search info
    self.searchFetchedResultsController.delegate = nil;
    self.searchFetchedResultsController = nil;
    // if you care about the scope save off the index to be used by the serchFetchedResultsController
    //self.savedScopeButtonIndex = scope;
}

#pragma mark -
#pragma mark Search Bar 
/*
 *---------------------------------------------------------------------------
 *
 * @prototype: - (void)searchDisplayController:(UISearchDisplayController *)controller willUnloadSearchResultsTableView:(UITableView *)tableView
 * @brief    : search is done so get rid of the search FRC and reclaim memory
 * @param 1  : controller
 * @param 2  : tableView
 * @return   : none
 *
 *---------------------------------------------------------------------------
 */
- (void)searchDisplayController:(UISearchDisplayController *)controller willUnloadSearchResultsTableView:(UITableView *)tableView
{
    // search is done so get rid of the search FRC and reclaim memory
    self.searchFetchedResultsController.delegate = nil;
    self.searchFetchedResultsController = nil;
}

/*
 *---------------------------------------------------------------------------
 *
 * @prototype: - (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
 * @brief    : demande si on doit re-charger les resultats de recherche ou pas
 * @param 1  : controller
 * @param 2  : searchString = le mot qu'on souhaite chercher
 * @return   : oui
 *
 *---------------------------------------------------------------------------
 */
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString 
                               scope:[self.searchDisplayController.searchBar selectedScopeButtonIndex]];
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

/*
 *---------------------------------------------------------------------------
 *
 * @prototype: - (void) searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
 * @brief    : when we start/end showing the search UI
 * @param 1  : controller
 * @return   : none
 *
 *---------------------------------------------------------------------------
 */
- (void) searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    
    // Replace la search bar à la bonne position
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

/*
 *---------------------------------------------------------------------------
 *
 * @prototype: - (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
 * @brief    : demande si on doit re-charger les resultats de recherche ou pas
 * @param 1  : controller
 * @param 2  : searchString = le mot qu'on souhaite chercher
 * @return   : oui
 *
 *---------------------------------------------------------------------------
 */
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    [self filterContentForSearchText:[self.searchDisplayController.searchBar text] 
                               scope:[self.searchDisplayController.searchBar selectedScopeButtonIndex]];
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

/*
 *---------------------------------------------------------------------------
 *
 * @prototype: - (void)controllerWillChangeContent:(NSFetchedResultsController *)controller 
 * @brief    :  Notifies the delegate that section and object changes are about to be processed and notifications will be sent
 * @param 1  : controller = 
 * @return   : none
 *
 *---------------------------------------------------------------------------
 */
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller 
{
    UITableView *tableView = controller == self.fetchedResultsController ? self.tableView : self.searchDisplayController.searchResultsTableView;
    [tableView beginUpdates];
}

/*
 *---------------------------------------------------------------------------
 *
 * @prototype: - (void)controller:(NSFetchedResultsController *)controller 
 didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
 atIndex:(NSUInteger)sectionIndex 
 forChangeType:(NSFetchedResultsChangeType)type 
 * @brief    : Notifies the delegate of added or removed sections.
 * @param 1  : controller = 
 * @param 2  : sectionInfo
 * @param 3  : sectionIndex
 * @param 4  : type
 * @return   : none
 *
 *---------------------------------------------------------------------------
 */
- (void)controller:(NSFetchedResultsController *)controller 
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex 
     forChangeType:(NSFetchedResultsChangeType)type 
{
    UITableView *tableView = controller == self.fetchedResultsController ? self.tableView : self.searchDisplayController.searchResultsTableView;
    
    switch(type) 
    {
        case NSFetchedResultsChangeInsert:
            [tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

/*
 *---------------------------------------------------------------------------
 *
 * @prototype: - (void)controller:(NSFetchedResultsController *)controller 
 didChangeObject:(id)anObject
 atIndexPath:(NSIndexPath *)theIndexPath 
 forChangeType:(NSFetchedResultsChangeType)type
 newIndexPath:(NSIndexPath *)newIndexPath 
 * @brief    : Notifies the delegate that a fetched object has been changed due to an add, remove, move, or update
 * @param 1  : searchText = le mot qu'on souhaite chercher
 * @param 2  : scope = ??
 * @return   : none
 *
 *---------------------------------------------------------------------------
 */
- (void)controller:(NSFetchedResultsController *)controller 
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)theIndexPath 
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath 
{
    UITableView *tableView = controller == self.fetchedResultsController ? self.tableView : self.searchDisplayController.searchResultsTableView;
    
    switch(type) 
    {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:theIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self fetchedResultsController:controller configureCell:[tableView cellForRowAtIndexPath:theIndexPath] atIndexPath:theIndexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:theIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


/*
 *---------------------------------------------------------------------------
 *
 * @prototype: - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller 
 * @brief    : Notifies the delegate that all section and object changes have been sent
 * @param 1  : controller
 * @return   : none
 *
 *---------------------------------------------------------------------------
 */
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller 
{
    UITableView *tableView = controller == self.fetchedResultsController ? self.tableView : self.searchDisplayController.searchResultsTableView;
    [tableView endUpdates];
}


/*
 *---------------------------------------------------------------------------
 *
 * @prototype: - (NSFetchedResultsController *)newFetchedResultsControllerWithSearch:(NSString *)searchString
 * @brief    : initialise un nouveau controlleur de recherche
 * @param 1  : searchString = le mont qu'on souhaite rechercher
 * @return   : le controlleur
 *
 *---------------------------------------------------------------------------
 */
- (NSFetchedResultsController *)newFetchedResultsControllerWithSearch:(NSString *)searchString
{
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////
    // Initialise et récupère les paramètre du langage courant
    NSString *myCurrentWord = [NSString string];
    myCurrentWord = [currentLanguageProperty_ objectForKey:@"word"];
    
    NSString *myCurrentEntity = [NSString string];
    myCurrentEntity = [currentLanguageProperty_ objectForKey:@"entity"];
    
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////
    // Desctiption de la manière de comparer, ordonner, filter les données,
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:myCurrentWord ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    NSPredicate *filterPredicate = nil;
    
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    // fetchRequest needs to know what entity to fetch
    NSEntityDescription *callEntity = [NSEntityDescription entityForName:myCurrentEntity inManagedObjectContext:managedObjectContext_];
    [fetchRequest setEntity:callEntity];
    
    NSMutableArray *predicateArray = [NSMutableArray array];
    if(searchString.length)
    {
        // your search predicate(s) are added to this array
        if ([[currentLanguageProperty_ objectForKey:@"word"] isEqualToString:@"mahorais"])
        {
            [predicateArray addObject:[NSPredicate predicateWithFormat:@"mahorais CONTAINS[cd] %@", searchString]];
        }
        else if ([[currentLanguageProperty_ objectForKey:@"word"] isEqualToString:@"francais"])
        {
            [predicateArray addObject:[NSPredicate predicateWithFormat:@"francais CONTAINS[cd] %@", searchString]];
        }
        // finally add the filter predicate for this view
        if(filterPredicate)
        {
            filterPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:filterPredicate, [NSCompoundPredicate orPredicateWithSubpredicates:predicateArray], nil]];
        }
        else
        {
            filterPredicate = [NSCompoundPredicate orPredicateWithSubpredicates:predicateArray];
        }
        
    }
    [fetchRequest setPredicate:filterPredicate];
    
    // Set the batch size to a suitable number.
    //[fetchRequest setFetchBatchSize:20];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest 
                                                                                                managedObjectContext:self.managedObjectContext 
                                                                                                  sectionNameKeyPath:@"uppercaseFirstLetterOfName" 
                                                                                                           cacheName:nil];
    
    
    
    
    aFetchedResultsController.delegate = self;
    [fetchRequest release];
    
    
    NSError *error = nil;
    if (![aFetchedResultsController performFetch:&error]) 
    {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return aFetchedResultsController;
    
}    

/*
 *---------------------------------------------------------------------------
 *
 * @prototype: - (NSFetchedResultsController *)fetchedResultsController 
 * @brief    : getter de fetchedResultController
 * @return   : resultats de recherche
 *
 *---------------------------------------------------------------------------
 */
- (NSFetchedResultsController *)fetchedResultsController 
{
    if (fetchedResultsController_ != nil) 
    {
        return fetchedResultsController_;
    }
    fetchedResultsController_ = [self newFetchedResultsControllerWithSearch:nil];
    return [[fetchedResultsController_ retain] autorelease];
}

/*
 *---------------------------------------------------------------------------
 *
 * @prototype: - (NSFetchedResultsController *)searchFetchedResultsController 
 * @brief    : getter de searchFetchedResultsController
 * @return   : controlleur de resultats de recherche
 *
 *---------------------------------------------------------------------------
 */
- (NSFetchedResultsController *)searchFetchedResultsController 
{
    if (searchFetchedResultsController_ != nil) 
    {
        return searchFetchedResultsController_;
    }
    searchFetchedResultsController_ = [self newFetchedResultsControllerWithSearch:self.searchDisplayController.searchBar.text];
    return [[searchFetchedResultsController_ retain] autorelease];
}

#pragma mark - Table view delegate

/*
 *---------------------------------------------------------------------------
 *
 * @prototype: - (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
 * @brief    : Called after the user changes the selection.
 * @param 1  : tableView
 * @param 2  : indexPath 
 * @return   : none
 *
 *---------------------------------------------------------------------------
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    
    DetailsViewController *detailsViewController = [[DetailsViewController alloc] initWithNibName:@"DetailsViewController" bundle:nil];
    
    if ([[currentLanguageProperty_ objectForKey:@"word"] isEqualToString:@"mahorais"])
    {
        
        DictionaryM *dictionaryM = (DictionaryM *)[self.searchFetchedResultsController objectAtIndexPath:indexPath];
        detailsViewController.word = [dictionaryM mahorais];
        detailsViewController.definition = [dictionaryM francais];
        
    }
    else if ([[currentLanguageProperty_ objectForKey:@"word"] isEqualToString:@"francais"])
    {
        DictionaryF *dictionaryF = (DictionaryF *)[self.searchFetchedResultsController objectAtIndexPath:indexPath];
        detailsViewController.word = [dictionaryF francais];
        detailsViewController.definition = [dictionaryF mahorais];
    }
    
    //Create ViewController
    // ...
    // Pass the selected object to the new view controller.
    [self.navigationController pushViewController:detailsViewController animated:YES];
    [detailsViewController release];
    
}

@end
