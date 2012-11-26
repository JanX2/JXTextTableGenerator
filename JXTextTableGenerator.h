//
//  JXTextTableGenerator.h
//  CSV Converter
//
//  Created by Jan on 24.11.12.
//
//  Copyright 2012 Jan Weiß. Some rights reserved: <http://opensource.org/licenses/mit-license.php>
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

#import "JXArcCompatibilityMacros.h"

@interface JXTextTableGenerator : NSObject {
	NSDictionary *_basicAttributes;
	NSDictionary *_headerAttributes;
	
	NSParagraphStyle *_paragraphStyle;
	CGFloat _tablePadding;

	CGFloat _borderWidth;
	NSColor *_borderColor;
}

// A CSVArray is an array of NSString arrays.
// Each entry in this topmost array represents a row.
// Each of the strings in a row represents the columns for the row.
#if 0
	// Here is an example of such an array:
    NSArray *sampleCSVArray = @[
	@[@"Header 1", @"Header 2"],
	@[@"cell 1", @"cell 2"],
	@[@"second row", @"second row 2"]
	];
#endif

// Should a row have a column count that differs from the *usual* column count in the table,
// it will be prepended to the result as tabbed text.

@property (nonatomic, readwrite, JX_STRONG) NSDictionary *basicAttributes;
@property (nonatomic, readwrite, JX_STRONG) NSDictionary *headerAttributes;

@property (nonatomic, readwrite, JX_STRONG) NSParagraphStyle *paragraphStyle;
@property (nonatomic, readwrite) CGFloat tablePadding;

@property (nonatomic, readwrite) CGFloat borderWidth;
@property (nonatomic, readwrite, JX_STRONG) NSColor *borderColor;

- (instancetype)init;
+ (instancetype)tableGenerator;

- (instancetype)initWithAttributes:(NSDictionary *)basicAttributes;
+ (instancetype)tableGeneratorWithAttributes:(NSDictionary *)basicAttributes;

- (NSMutableAttributedString *)attributedStringForCSVArray:(NSArray *)rowColArray;

- (NSMutableAttributedString *)attributedStringForCSVArray:(NSArray *)rowColArray
										  tableHeaderIndex:(NSUInteger)headerIndex;

@end
