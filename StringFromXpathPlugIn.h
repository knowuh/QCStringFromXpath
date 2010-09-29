//
//  StringFromXpathPlugIn.h
//  StringFromXpath
//
//  Created by Noah Paessel on 9/14/10.
//  Copyright (c) 2010 Concord Consortium. All rights reserved.
//

#import <Quartz/Quartz.h>

@interface StringFromXpathPlugIn : QCPlugIn
{
	NSString      *url;
	NSString	  *xpath;
	NSXMLDocument *xmlDoc;
	NSUInteger    pathIndex;
	BOOL		  reset;
}

- (void)myLog:(NSString *)formatString, ...;
/*
Declare here the Obj-C 2.0 properties to be used as input and output ports for the plug-in e.g.
@property double inputFoo;
@property(assign) NSString* outputBar;
You can access their values in the appropriate plug-in methods using self.inputFoo or self.inputBar
*/
@property(assign) NSString*  inputUrl;
@property(copy)   NSString*  url;
@property(assign) NSString*  inputXpath;
@property(copy)   NSString*  xpath;
@property(assign) NSUInteger inputIndex;
@property(assign) BOOL		 inputReset;
@property(assign) BOOL		 reset;
@property(assign) NSUInteger pathIndex;
@property(assign) NSString*  outputString;
@property(assign) NSUInteger outputSize;
@property(copy)	  NSXMLDocument* xmlDoc;
@end
