//
//  JXTextTableGenerator.m
//  CSV Converter
//
//  Created by Jan on 24.11.12.
//
//  Copyright 2012 Jan Weiß. Some rights reserved: <http://opensource.org/licenses/mit-license.php>
//

#import "JXTextTableGenerator.h"

@implementation JXTextTableGenerator

- (NSMutableAttributedString *)attributedStringForCSVArray:(NSArray *)rowColArray
										  tableHeaderIndex:(NSUInteger)headerIndex;
{
	CGFloat defaultSize = [NSFont systemFontSize];
    NSFont *font = [NSFont fontWithName:@"Helvetica" size:defaultSize];
    NSColor *textColor = [NSColor blackColor];
    NSMutableDictionary *basicAttributes = [NSMutableDictionary dictionaryWithObjectsAndKeys:
										   font,		NSFontAttributeName,
										   textColor,	NSForegroundColorAttributeName,
										   nil];
	
	NSMutableDictionary *headerAttributes = [[basicAttributes mutableCopy] autorelease];
	NSFont *boldFont = [[NSFontManager sharedFontManager] convertFont:font
														  toHaveTrait:NSBoldFontMask];
	if (boldFont != nil) {
		[headerAttributes setObject:boldFont
							 forKey:NSFontAttributeName];
	}
	
	// Should a row have a column count that differs from the *usual* column count in the table, it will be prepended to the result as tabbed text.
	NSUInteger columnCount;
	NSArray *headerRow = nil;
	if (headerIndex != NSNotFound) {
		headerRow = [rowColArray objectAtIndex:headerIndex];
		columnCount = headerRow.count;
	}
	else {
		columnCount = [(NSArray *)[rowColArray lastObject] count];
	}
	
	NSInteger rowCount = rowColArray.count;
	NSInteger colCount = columnCount;
	NSMutableAttributedString *tableString = [[NSMutableAttributedString alloc] initWithString:@""
																					attributes:basicAttributes];

	NSMutableAttributedString *preambleAttributedString = [[NSMutableAttributedString alloc] initWithString:@""
																					attributes:basicAttributes];
	NSMutableString *preambleString = preambleAttributedString.mutableString;
	
	NSTextTable *table = [[NSTextTable alloc] init];
	[table setNumberOfColumns:colCount];
	
	NSInteger rowIndex = 0;
	
	NSDictionary *currentAttributes = basicAttributes;
	
	for (NSMutableArray *row in rowColArray) {
		NSInteger colIndex = 0;
		
		if ((NSInteger)row.count != colCount) {
			[preambleString appendString:[[row componentsJoinedByString:@"\t"] stringByAppendingString:@"\n"]];
			continue;
		}
		
		if (row == headerRow) {
			currentAttributes = headerAttributes;
		}
		
		for (NSString *cellString in row) {
			[tableString appendAttributedString:[self tableCellAttributedStringWithString:cellString
																					table:table
																					  row:rowIndex
																				 rowCount:rowCount
																				   column:colIndex
																				 colCount:colCount
																			   attributes:currentAttributes]];
			
			colIndex++;
		}
		
		if (row == headerRow) {
			currentAttributes = basicAttributes;
		}
		
		rowIndex++;
	}
	
	[tableString insertAttributedString:preambleAttributedString atIndex:0];
	
	[preambleAttributedString release];
	[table release];
	
	return [tableString autorelease];
}

- (NSMutableAttributedString *)tableCellAttributedStringWithString:(NSString *)string
															 table:(NSTextTable *)table
															   row:(NSInteger)row
														  rowCount:(NSInteger)rowCount
															column:(NSInteger)column
														  colCount:(NSInteger)colCount
														attributes:(NSDictionary *)basicAttributes
{
	NSTextTableBlock *tableBlock = [[NSTextTableBlock alloc] initWithTable:table
															   startingRow:row
																   rowSpan:1
															startingColumn:column
																columnSpan:1];
	
	[tableBlock setWidth:4.0 type:NSTextBlockAbsoluteValueType forLayer:NSTextBlockPadding];

	{
		[tableBlock setBorderColor:[NSColor colorWithCalibratedHue:0.00 saturation:0.00 brightness:0.80 alpha:1.00]]; // Numbers-style gray
		
		[tableBlock setWidth:1.0 type:NSTextBlockAbsoluteValueType forLayer:NSTextBlockBorder edge:NSMinYEdge];
		[tableBlock setWidth:1.0 type:NSTextBlockAbsoluteValueType forLayer:NSTextBlockBorder edge:NSMinXEdge];
		
		if (row == (rowCount - 1)) {
			[tableBlock setWidth:1.0 type:NSTextBlockAbsoluteValueType forLayer:NSTextBlockBorder edge:NSMaxYEdge];
		}
		
		if (column == (colCount - 1)) {
			[tableBlock setWidth:1.0 type:NSTextBlockAbsoluteValueType forLayer:NSTextBlockBorder edge:NSMaxXEdge];
		}
	}
	
	NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
	[paragraphStyle setTextBlocks:[NSArray arrayWithObjects:tableBlock, nil]];
	[tableBlock release];
	
	NSString *terminatedString = [string stringByAppendingString:@"\n"];
	NSMutableAttributedString *cellString = [[NSMutableAttributedString alloc] initWithString:terminatedString
																				   attributes:basicAttributes];
	[cellString addAttribute:NSParagraphStyleAttributeName
					   value:paragraphStyle
					   range:NSMakeRange(0, [cellString length])];
	[paragraphStyle release];
	
	return [cellString autorelease];
}

@end
