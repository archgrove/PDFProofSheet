//
//  AppDelegate.h
//  PDFProofSheet
//
//  Created by Adam Wright on 30/09/2013.
//  Copyright (c) 2013 Adam Wright. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ProofSheetGenerator.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSImageView *imageView;

@end
