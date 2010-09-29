//
//  StringFromXpathPlugIn.m
//  StringFromXpath
//
//  Created by Noah Paessel on 9/14/10.
//  Copyright (c) 2010 Concord Consortium. All rights reserved.
//

/* It's highly recommended to use CGL macros instead of changing the current context for plug-ins that perform OpenGL rendering */
#import <OpenGL/CGLMacro.h>

#import "StringFromXpathPlugIn.h"

#define	kQCPlugIn_Name				@"StringFromXpath"
#define	kQCPlugIn_Description		@"StringFromXpath: Given a URL, Xpath expression, and index, return a NSString."

@implementation StringFromXpathPlugIn

/*
Here you need to declare the input / output properties as dynamic as Quartz Composer will handle their implementation
@dynamic inputFoo, outputBar;
*/
@dynamic inputUrl, inputXpath, inputIndex, inputReset, outputString, outputSize;
@synthesize url,xpath, pathIndex, xmlDoc, reset;


- (void)myLog:(NSString *)formatString, ...
{
	NSString *newMessage;
    va_list args;
    va_start(args, formatString);
    newMessage = [[NSString alloc] initWithFormat:formatString arguments:args];
	self.outputString = newMessage;
	//NSLog(formatString,args);
	va_end(args);
}

+ (NSDictionary*) attributes
{
	/*
	Return a dictionary of attributes describing the plug-in (QCPlugInAttributeNameKey, QCPlugInAttributeDescriptionKey...).
	*/
	
	return [NSDictionary dictionaryWithObjectsAndKeys:kQCPlugIn_Name, QCPlugInAttributeNameKey, kQCPlugIn_Description, QCPlugInAttributeDescriptionKey, nil];
}

+ (NSArray*) sortedPropertyPortKeys {
	return [NSArray arrayWithObjects: @"inputUrl",@"inputXpath",@"inputIndex", @"inputReset", nil];	
}

+ (NSDictionary*) attributesForPropertyPortWithKey:(NSString*)key
{
	/*
	 Specify the optional attributes for property based ports (QCPortAttributeNameKey, QCPortAttributeDefaultValueKey...).
	 */
	if([key isEqualToString:@"inputUrl"])
        return [NSDictionary dictionaryWithObjectsAndKeys:
				@"Input URL", QCPortAttributeNameKey,
				@"http://www.apple.com/main/rss/hotnews/hotnews.rss", QCPortAttributeDefaultValueKey,
				nil];
	if([key isEqualToString:@"inputXpath"])
        return [NSDictionary dictionaryWithObjectsAndKeys:
				@"Xpath Expression", QCPortAttributeNameKey,
				@"//title", QCPortAttributeDefaultValueKey,
				nil];
	if([key isEqualToString:@"inputIndex"])
        return [NSDictionary dictionaryWithObjectsAndKeys:
				@"Article Index", QCPortAttributeNameKey,
				@"0", QCPortAttributeDefaultValueKey,
				nil];
	if([key isEqualToString:@"inputReset"])
        return [NSDictionary dictionaryWithObjectsAndKeys:
				@"Reload feed", QCPortAttributeNameKey,
				FALSE, QCPortAttributeDefaultValueKey,
				nil];
    if([key isEqualToString:@"outputString"])
        return [NSDictionary dictionaryWithObjectsAndKeys:
				@"Result", QCPortAttributeNameKey,
				nil];
	if([key isEqualToString:@"outputSize"])
        return [NSDictionary dictionaryWithObjectsAndKeys:
				@"Number of elements", QCPortAttributeNameKey,
				nil];
	return nil;
}


+ (QCPlugInExecutionMode) executionMode
{
	/*
	Return the execution mode of the plug-in: kQCPlugInExecutionModeProvider, kQCPlugInExecutionModeProcessor, or kQCPlugInExecutionModeConsumer.
	*/
	
	return kQCPlugInExecutionModeProvider;
}

+ (QCPlugInTimeMode) timeMode
{
	/*
	Return the time dependency mode of the plug-in: kQCPlugInTimeModeNone, kQCPlugInTimeModeIdle or kQCPlugInTimeModeTimeBase.
	*/
	
	return kQCPlugInTimeModeNone;
}

- (id) init
{
	if(self = [super init]) {
		/*
		Allocate any permanent resource required by the plug-in.
		*/
	}
	
	return self;
}

- (void) finalize
{
	/*
	Release any non garbage collected resources created in -init.
	*/
	
	[super finalize];
}

- (void) dealloc
{
	/*
	Release any resources created in -init.
	*/
	
	[super dealloc];
}

@end

@implementation StringFromXpathPlugIn (Execution)

- (BOOL) startExecution:(id<QCPlugInContext>)context
{
	/*
	Called by Quartz Composer when rendering of the composition starts: perform any required setup for the plug-in.
	Return NO in case of fatal failure (this will prevent rendering of the composition to start).
	*/
	
	return YES;
}

- (void) enableExecution:(id<QCPlugInContext>)context
{
	/*
	Called by Quartz Composer when the plug-in instance starts being used by Quartz Composer.
	*/
}

- (BOOL) execute:(id<QCPlugInContext>)context atTime:(NSTimeInterval)time withArguments:(NSDictionary*)arguments
{
	/*
	Called by Quartz Composer whenever the plug-in instance needs to execute.
	Only read from the plug-in inputs and produce a result (by writing to the plug-in outputs or rendering to the destination OpenGL context) within that method and nowhere else.
	Return NO in case of failure during the execution (this will prevent rendering of the current frame to complete).
	
	The OpenGL context for rendering can be accessed and defined for CGL macros using:
	CGLContextObj cgl_ctx = [context CGLContextObj];
	*/
	NSError *error = nil;
	BOOL needs_update = FALSE;
	BOOL need_reset = self.inputReset;
	if (self.url == nil || ([self.url compare:self.inputUrl] != NSOrderedSame) || (need_reset && (! self.reset))) {
		self.url = self.inputUrl;
		NSURL *nsurl = [NSURL URLWithString:self.url];
		NSXMLDocument *xmldoc = [[NSXMLDocument alloc]initWithContentsOfURL:nsurl options:0 error:&error];
		if (!error) {
			self.xmlDoc = xmldoc;
			needs_update = TRUE;
			NSLog(@"Loaded document AOK %@", self.url);
		}
		else {
			NSLog(@"Problem parsing xml document at %@: %@", self.url, [error localizedDescription]);
		}
	}
	// prevent retriggering if edge not change
	self.reset = need_reset;
	if (self.xpath == nil || ([self.xpath compare:self.inputXpath] != NSOrderedSame)) {
		self.xpath = self.inputXpath;
		needs_update = TRUE;
	}
	if (self.pathIndex != self.inputIndex) {
		self.pathIndex = self.inputIndex;
		needs_update = TRUE;
	}
	if (needs_update) {
		if(self.xmlDoc) {
			NSArray *results = [self.xmlDoc nodesForXPath:self.xpath error:&error];
			if (!error) {
				if ([results count] > 0) {
					if([results count] > self.pathIndex) {
						self.outputString = [NSString stringWithFormat:@"%@",[[results objectAtIndex:self.pathIndex] objectValue]];
						self.outputSize = [results count];
					}
					else {
						self.outputString = [[results lastObject] stringValue];
					}
				}
				else {
					NSLog(@"empty results for xpath query %@", self.xpath);
				}
			}
			else {
				NSLog(@"Error parsing xpath %@",[error localizedDescription]);
			}
		}
		else {
			NSLog(@"No root element found");
		}

	}
	return YES;
}

			   
- (void) disableExecution:(id<QCPlugInContext>)context
{
	/*
	Called by Quartz Composer when the plug-in instance stops being used by Quartz Composer.
	*/
}

- (void) stopExecution:(id<QCPlugInContext>)context
{
	/*
	Called by Quartz Composer when rendering of the composition stops: perform any required cleanup for the plug-in.
	*/
}

@end
