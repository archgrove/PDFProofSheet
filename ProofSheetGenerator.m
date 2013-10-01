//
//  ProofSheetGenerator.m
//  PDFProofSheet
//
//  Created by Adam Wright on 01/10/2013.
//  Copyright (c) 2013 Adam Wright. All rights reserved.
//

#import "ProofSheetGenerator.h"

typedef struct
{
    NSUInteger horizontalCount;
    NSUInteger verticalCount;
    CGFloat scale;
} ProofSheetDimensions;

@implementation ProofSheetGenerator

- (instancetype)initWithWidth:(NSUInteger)pWidth height:(NSUInteger)pHeight
{
    return [self initWithWidth:pWidth height:pHeight minimumPageCount:0];
}

- (instancetype)initWithWidth:(NSUInteger)pWidth height:(NSUInteger)pHeight
                minimumPageCount:(NSUInteger)minPages
{
    self = [super init];
    
    if (self)
    {
        _size = CGSizeMake(pWidth, pHeight);
        _minimumPageCount = minPages;
    }
    
    return self;
}

- (CGImageRef)newImageFromPDF:(NSURL*)source error:(NSError**)error
{
    CGPDFDocumentRef pdfDoc = CGPDFDocumentCreateWithURL((__bridge CFURLRef)source);
    
    if (pdfDoc == NULL)
    {
        return NULL;
    }
    
    CGPDFPageRef firstPage = CGPDFDocumentGetPage(pdfDoc, 1);
    CGRect pageBounds = CGPDFPageGetBoxRect(firstPage, kCGPDFMediaBox);
    NSUInteger pageCount = CGPDFDocumentGetNumberOfPages(pdfDoc);
    
    // Determine the scale and grid size of the proof sheet
    ProofSheetDimensions dims = [self computeDimensionsWithPageCount:MAX(self.minimumPageCount, pageCount) width:pageBounds.size.width height:pageBounds.size.height];
    
    CGContextRef gfxCtx = [self newBitmapContext];
    
    // Translate the context one page down from the top left, ready to draw a page
    CGContextTranslateCTM(gfxCtx, 0, self.size.height);
    CGContextScaleCTM(gfxCtx, dims.scale, dims.scale);
    CGContextTranslateCTM(gfxCtx, 0, -pageBounds.size.height);

    // Draw each page
    for (int y = 0; y < dims.verticalCount; y++)
    {
        for (int x = 0; x < dims.horizontalCount; x++)
        {
            NSUInteger pageIndex = (y * dims.horizontalCount) + x + 1;
            if (pageIndex > pageCount)
                break;
            
            CGPDFPageRef currentPage = CGPDFDocumentGetPage(pdfDoc, pageIndex);
            CGContextDrawPDFPage(gfxCtx, currentPage);
            
            // Move one page to the right
            CGContextTranslateCTM(gfxCtx, pageBounds.size.width, 0);
        }
        
        // Move back to the far left, and one page down
        CGContextTranslateCTM(gfxCtx, dims.horizontalCount * pageBounds.size.width * -1, pageBounds.size.height * -1);
    }
    
    // Create an image from the context
    CGImageRef cgImage = CGBitmapContextCreateImage(gfxCtx);
    
    CGContextRelease(gfxCtx);
    CGPDFDocumentRelease(pdfDoc);

    return cgImage;
}

- (CGContextRef)newBitmapContext
{
    // Create an image context of the correct dimensions
    CGColorSpaceRef colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
    CGContextRef gfxCtx = CGBitmapContextCreate(NULL, self.size.width, self.size.height,
                                                8, 0, colorSpace, kCGImageAlphaNoneSkipFirst);
    
    // Clear the background, and ensure that all pages will be rendered with proper alpha blending
    CGContextSetRGBFillColor(gfxCtx, 1, 1, 1, 1);
    CGContextFillRect(gfxCtx, CGRectMake(0, 0, self.size.width, self.size.height));
    CGContextSetBlendMode(gfxCtx, kCGBlendModeNormal);
    
    CGColorSpaceRelease(colorSpace);

    return gfxCtx;
}

- (ProofSheetDimensions)computeDimensionsWithPageCount:(NSUInteger)pageCount width:(NSUInteger)pageWidth height:(NSUInteger)pageHeight
{
    /*
         Maximize scale subject to horizontalPages * verticalPages >= pageCount
         
         Scale is computed by assuming we can fill the entire grid with pages by solving the equation
         
         pageCount = horizontalPages * verticalPages
         
         where both:
         
         horizontalPages = width / (pageWidth * scale);
         verticalPages = height / (pageHeight * scale);
     */
    
    // This first approximation of scale assumes we could render fractional pages
    ProofSheetDimensions dims;
    
    dims.scale = sqrt(((self.size.width / pageWidth) * (self.size.height / pageHeight)) / pageCount);
    
    // Round up the page count in both dimensions to handle real page sizez
    dims.horizontalCount = ceil(self.size.width / (pageWidth * dims.scale));
    dims.verticalCount = ceil(self.size.height / (pageHeight * dims.scale));
    
    // Rescale scale
    dims.scale = MIN((self.size.width / dims.horizontalCount) / pageWidth,
                     (self.size.height / dims.verticalCount) / pageHeight);
    
    return dims;
}

@end
