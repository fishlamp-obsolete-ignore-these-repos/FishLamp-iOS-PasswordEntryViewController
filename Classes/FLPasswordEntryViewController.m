//
//	FLPasswordEntryViewController.m
//	FishLamp
//
//	Created by Mike Fullerton on 3/19/11.
//	Copyright (c) 2013 GreenTongue Software LLC, Mike Fullerton.
//  The FishLamp Framework is released under the MIT License: http://fishlamp.com/license 
//

#import "FLPasswordEntryViewController.h"
#import "FLSingleLineTextEditCell.h"
#import "FLAlert.h"
#import "FLButtons.h"

@implementation FLPasswordEntryViewController

- (id) initWithPrompt:(NSString*) prompt withOptions:(FLPasswordEntryViewControllerOptionMask) options
{
	if((self = [super init]))
	{
		_prompt = FLRetain(prompt);
		_options = options;
		[self.dataSourceManager setDefaultDataSource:[NSMutableDictionary dictionary]];
	}
	return self;
}

+ (FLPasswordEntryViewController*) passwordEntryViewController:(NSString*) prompt withOptions:(FLPasswordEntryViewControllerOptionMask) options
{
	return FLAutorelease([[FLPasswordEntryViewController alloc] initWithPrompt:prompt withOptions:options]);
}

- (void) dealloc
{
	FLRelease(_prompt);
	FLSuperDealloc();
}

- (void) willConstructWithTableLayoutBuilder:(FLTableViewLayoutBuilder*) builder
{
	[builder addSection];
	[builder addCell:[FLPasswordTextEditCell passwordTextEditCell:_prompt] forKey:@"password"];
	
	if(FLTestBits(_options, FLPasswordEntryViewControllerOptionConfirmationRequired))
	{
		[builder addSection];
		[builder addCell:[FLPasswordTextEditCell passwordTextEditCell:NSLocalizedString(@"Confirm Password", nil)] forKey:@"password2"];
	}
}					 

- (NSString*) password
{
	return [self.dataSourceManager objectForKeyPath:@"password"];
}

- (void) _beginEditing
{
	[self beginEditingTextInCell:(FLTextEditCell*) [self cellForRowKey:@"password"]];
}

- (void) viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	[self performSelector:@selector(_beginEditing) withObject:nil afterDelay:0.3];

	[self _beginEditing];
}

- (void) didStopEditingText:(BOOL)withDonePress
{
	[super didStopEditingText:withDonePress];
	if(withDonePress)
	{
		[self respondToSaveButton:self];
	}
}

- (BOOL) willBeginSavingChanges
{
	NSString* password = self.password;
	if(FLTestBits(_options, FLPasswordEntryViewControllerOptionPasswordRequired))
	{
		if(FLStringIsEmpty(password))
		{
			FLAlert* alert = [FLAlert alertViewController:NSLocalizedString(@"No password was entered.", nil) 
                message:NSLocalizedString(@"Please enter a valid password.", nil)];
            [alert addButton:[FLConfirmButton okButton]];
			[alert showViewControllerAnimated:YES];
			return NO;
		}
	}

	if(FLTestBits(_options, FLPasswordEntryViewControllerOptionConfirmationRequired))
	{
	
		if(!FLStringsAreEqual(password, [self.dataSourceManager objectForKeyPath:@"password2"]))
		{
			FLAlert* alert = [FLAlert alertViewController:NSLocalizedString(@"The two passwords you entered do not match.", nil) 
                                                                              message:NSLocalizedString(@"Please try again.",nil)];
            [alert addButton:[FLConfirmButton okButton]];
			[alert showViewControllerAnimated:YES];

			[self beginEditingTextInCell:(FLTextEditCell*) [self cellForRowKey:@"password"]];

			return NO;
		}
	}
	
	return YES;
}



@end
