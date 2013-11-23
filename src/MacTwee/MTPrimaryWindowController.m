//
//  MacTwee
//
//  Created by Chris Braithwaite on 11/23/13.
//  Copyright 2013 Chris Braithwaite. Released under MIT License.
//

#import "MTPrimaryWindowController.h"
#import "MTHomeViewController.h"
#import "MTProjectViewController.h"
#import "MTTweeFileTools.h"
#import "MTProjectEditor.h"


@implementation MTPrimaryWindowController

MTTweeFileTools * tweeFileTools;


#pragma mark - Lifecycle

- (void)awakeFromNib {
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(processNotification:)
												 name:MTPrimaryWindowControllerWillOpenViewNotification
											   object:nil];

	[self selectView:MTPageHome];
}


#pragma mark - Public

- (void)selectView:(NSInteger)whichViewTag {
	[self changeViewController:whichViewTag];
}

- (IBAction)newPassage:(id)sender {
	[[MTProjectEditor sharedMTProjectEditor] newPassage];
}

- (IBAction)buildStory:(id)sender {
	if (tweeFileTools == nil)
		tweeFileTools = [[MTTweeFileTools alloc]init];
	[tweeFileTools buildStory];
}

- (IBAction)buildAndRun:(id)sender {
	if (tweeFileTools == nil)
		tweeFileTools = [[MTTweeFileTools alloc]init];
	[tweeFileTools buildAndRunStory];
}

- (IBAction)importStory:(id)sender {
	if (tweeFileTools == nil)
		tweeFileTools = [[MTTweeFileTools alloc]init];
	[tweeFileTools importTweeFile];
}

- (IBAction)exportStory:(id)sender {
	if (tweeFileTools == nil)
		tweeFileTools = [[MTTweeFileTools alloc]init];
	[tweeFileTools exportTweeFile];
}


#pragma mark - Private

- (void)processNotification:(NSNotification *) notification {
	//NSLog(@"%s:%d:Notification is successfully received! %@", __func__, __LINE__, notification);
	
    if ([notification.name isEqualToString:MTPrimaryWindowControllerWillOpenViewNotification]) {
		if ( [notification userInfo][@"index"] ) {
			//NSLog(@"The object for key index is %@", [[notification userInfo] objectForKey:@"index"]);
			NSNumber *aNumber = [notification userInfo][@"index"];
			[self changeViewController:[aNumber integerValue]];
		}
	}
}

- (void)changeViewController:(NSInteger)whichViewTag {
	//NSLog(@"%s 'Line:%d' - view:'%ld'", __func__, __LINE__, (long)whichViewTag);
		
	if (_currentViewController.view != nil)
		[_currentViewController.view removeFromSuperview];	// remove the current view
	
	if (_currentViewController != nil)
		_currentViewController = nil;		// remove the current view controller
	
	switch (whichViewTag)
	{
		case MTPageHome:	// swap in the "MTProjectSelectionViewController"
		{
			[self.window.toolbar setVisible:NO];
			self.window.title = @"MacTwee - Story Manager";
			MTHomeViewController* view = [[MTHomeViewController alloc] initWithNibName:@"MTHomeView" bundle:nil];
			NSAssert(view != nil, @"MTHomeView is nil");
			if (view != nil)
			{
				_currentViewController = view;	// keep track of the current view controller
				_currentViewController.title = @"Projects";
			}
            [[MTProjectEditor sharedMTProjectEditor] ResetCurrentValues];
			break;
		}
		
		case MTPageProject:	// swap in the "MTProjectViewController"
		{
			self.window.title = @"MacTwee - Story Editor";
			[self.window.toolbar setVisible:YES];
			MTProjectViewController * view = [[MTProjectViewController alloc] initWithNibName:@"MTProjectView" bundle:nil];
			NSAssert(view != nil, @"MTProjectView is nil");
			if (view != nil)
			{
				_currentViewController = view;	// keep track of the current view controller
				_currentViewController.title = @"Project";
			}
			break;
		}
			
		default: break;
	}
	
	NSAssert(_currentViewController != nil, @"_currentViewController is nil");
	
	//constrain a view so that it occupies the entire window’s content view, resizing when appropriate.
	NSView * customView = _currentViewController.view;
	NSAssert(customView != nil, @"customView is nil");
	
	customView.translatesAutoresizingMaskIntoConstraints = NO;
		
	// embed the current view to our host view
	[self.holderView addSubview:customView];
	
	NSDictionary *views = NSDictionaryOfVariableBindings(customView);
	[self.holderView addConstraints:
	 [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[customView]|"
											 options:0
											 metrics:nil
											   views:views]];
	[self.holderView addConstraints:
	[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[customView]|"
											 options:0
											 metrics:nil
											   views:views]];
	
	for (NSView * view in [customView subviews]) {
		view.translatesAutoresizingMaskIntoConstraints = NO;
	}
}


@end
