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

@synthesize basicAttributes = _basicAttributes;
@synthesize headerAttributes = _headerAttributes;

@synthesize paragraphStyle = _paragraphStyle;
@synthesize tablePadding = _tablePadding;

@synthesize borderWidth = _borderWidth;
@synthesize borderColor = _borderColor;

- (id)init;
{
	return [self initWithAttributes:nil];
}

+ (id)tableGenerator;
{
	id result = [(JXTextTableGenerator *)[[self class] alloc] initWithAttributes:nil];
	
	return JX_AUTORELEASE(result);
}

- (id)initWithAttributes:(NSDictionary *)basicAttributes;
{
	self = [super init];
	
	if (self) {
		if (basicAttributes == nil) {
			// Use defaults
			CGFloat defaultSize = [NSFont systemFontSize];
			
			NSFont *font = [NSFont fontWithName:@"Helvetica"
										   size:defaultSize];
			
			NSColor *textColor = [NSColor blackColor];
			
			basicAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
							   font,		NSFontAttributeName,
							   textColor,	NSForegroundColorAttributeName,
							   nil];
			
		}
		
		_paragraphStyle = JX_RETAIN([NSParagraphStyle defaultParagraphStyle]);
		_tablePadding = 4.0;
		
		_borderWidth = 1.0;
		_borderColor = JX_RETAIN([NSColor colorWithCalibratedHue:0.00
											 saturation:0.00
											 brightness:0.80
												  alpha:1.00]); // Numbers-style gray
		
		_basicAttributes = JX_RETAIN(basicAttributes);
		
		// Derive headerAttributes. 
		NSMutableDictionary *headerAttributes = [_basicAttributes mutableCopy];
		NSFont *font = [basicAttributes objectForKey:NSFontAttributeName];
		NSFont *headerFont = [[NSFontManager sharedFontManager] convertFont:font
																toHaveTrait:NSBoldFontMask];
		if (headerFont != nil) {
			[headerAttributes setObject:headerFont
								 forKey:NSFontAttributeName];
		}
		
		_headerAttributes = JX_RETAIN(headerAttributes);
	}
	
	return self;
}

+ (id)tableGeneratorWithAttributes:(NSDictionary *)basicAttributes;
{
	id result = [(JXTextTableGenerator *)[[self class] alloc] initWithAttributes:basicAttributes];
	
	return JX_AUTORELEASE(result);
}

#if (JX_HAS_ARC == 0)
- (void)dealloc
{
    self.basicAttributes = nil;
    self.headerAttributes = nil;
	
    self.borderColor = nil;
	
    [super dealloc];
}
#endif


- (NSMutableAttributedString *)attributedStringForCSVArray:(NSArray *)rowColArray;
{
	return [self attributedStringForCSVArray:rowColArray tableHeaderIndex:NSNotFound];
}

- (NSMutableAttributedString *)attributedStringForCSVArray:(NSArray *)rowColArray
										  tableHeaderIndex:(NSUInteger)headerIndex;
{
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
																					attributes:_basicAttributes];
	
	NSMutableAttributedString *preambleAttributedString = [[NSMutableAttributedString alloc] initWithString:@""
																								 attributes:_basicAttributes];
	NSMutableString *preambleString = preambleAttributedString.mutableString;
	
	NSTextTable *table = [[NSTextTable alloc] init];
	[table setNumberOfColumns:colCount];
	
	NSInteger rowIndex = 0;
	
	NSDictionary *currentAttributes = _basicAttributes;
	
	for (NSMutableArray *row in rowColArray) {
		NSInteger colIndex = 0;
		
		if ((NSInteger)row.count != colCount) {
			[preambleString appendString:[[row componentsJoinedByString:@"\t"]
										  stringByAppendingString:@"\n"]];
			continue;
		}
		
		if (row == headerRow) {
			currentAttributes = _headerAttributes;
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
			currentAttributes = _basicAttributes;
		}
		
		rowIndex++;
	}
	
	[tableString insertAttributedString:preambleAttributedString
								atIndex:0];
	
	JX_RELEASE(preambleAttributedString);
	JX_RELEASE(table);
	
	return JX_AUTORELEASE(tableString);
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
	
	[tableBlock setWidth:_tablePadding type:NSTextBlockAbsoluteValueType forLayer:NSTextBlockPadding];
	
	{
		[tableBlock setBorderColor:_borderColor];
		
		[tableBlock setWidth:_borderWidth type:NSTextBlockAbsoluteValueType forLayer:NSTextBlockBorder edge:NSMinYEdge];
		[tableBlock setWidth:_borderWidth type:NSTextBlockAbsoluteValueType forLayer:NSTextBlockBorder edge:NSMinXEdge];
		
		if (row == (rowCount - 1)) {
			[tableBlock setWidth:_borderWidth type:NSTextBlockAbsoluteValueType forLayer:NSTextBlockBorder edge:NSMaxYEdge];
		}
		
		if (column == (colCount - 1)) {
			[tableBlock setWidth:_borderWidth type:NSTextBlockAbsoluteValueType forLayer:NSTextBlockBorder edge:NSMaxXEdge];
		}
	}
	
	NSMutableParagraphStyle *paragraphStyle = [_paragraphStyle mutableCopy];
	[paragraphStyle setTextBlocks:[NSArray arrayWithObjects:tableBlock, nil]];
	JX_RELEASE(tableBlock);
	
	NSString *terminatedString = [string stringByAppendingString:@"\n"];
	NSMutableAttributedString *cellString = [[NSMutableAttributedString alloc] initWithString:terminatedString
																				   attributes:basicAttributes];
	[cellString addAttribute:NSParagraphStyleAttributeName
					   value:paragraphStyle
					   range:NSMakeRange(0, [cellString length])];
	JX_RELEASE(paragraphStyle);
	
	return JX_AUTORELEASE(cellString);
}

@end
