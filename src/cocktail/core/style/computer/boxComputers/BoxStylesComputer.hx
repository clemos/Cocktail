/*
	This file is part of Cocktail http://www.silexlabs.org/groups/labs/cocktail/
	This project is © 2010-2011 Silex Labs and is released under the GPL License:
	This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 
	This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
	To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
package cocktail.core.style.computer.boxComputers;

import cocktail.core.style.ComputedStyle;
import cocktail.core.style.CoreStyle;
import cocktail.core.style.StyleData;
import cocktail.core.unit.UnitData;
import cocktail.core.unit.UnitManager;
import cocktail.core.font.FontData;
import haxe.Log;


/**
 * This is the base class for all classes computing a HTMLElement's box model. 
 * The box model is determined by a combination of styles such as the display of
 * an element, its width, its margins, paddings...
 * 
 * This class use the defined styles value and compute a value for them that will
 * actually be used. 
 * For example, if a width is determined as a percentage, this class compute
 * a pixel width value from it.
 * 
 * In this base class it is assumed that the HTMLElement is a block, non-replaced
 * element, each deriving case as its own inherithing class
 * 
 * @author Yannick DOMINGUEZ
 */
class BoxStylesComputer 
{
	
	/**
	 * class constructor
	 */
	public function new() 
	{
		
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////
	// PUBLIC METHOD
	// Public entry point of this class
	//////////////////////////////////////////////////////////////////////////////////////////
	
	/**
	 * Takes the styles of a htmlElement and measure each of its box model properties from 
	 * them (paddings, margins, width, height...)
	 * 
	 * Stores all the style computed value in its computed style structure
	 * 
	 * @param	style contains each of a HTMLElement styles, a reference to the HTMLElement and a structure to
	 * hold computed styles.
	 * @param	containingBlockData the width and height dimensions of the containing block of this 
	 * HTMLElement, used when computing styles determined as percent or "auto"
	 */
	public function measure(style:CoreStyle, containingBlockData:ContainingBlockData):Void
	{
		var fontMetrics:FontMetricsData = style.fontMetrics;
		
		//measure paddings
		measureHorizontalPaddings(style, containingBlockData, fontMetrics);
		measureVerticalPaddings(style, containingBlockData, fontMetrics);
		
		//The next step is to compute the dimensions
		//constraint style (max-width, min-height...)
		//which will be applied each time the computed height
		//or width ae set
		measureDimensionsConstraints(style, containingBlockData, fontMetrics);
		
		//measure width, height and margins at the same time, as margins can influence or be
		//influenced by the width and height of the HTMLElement
		measureWidthAndHorizontalMargins(style, containingBlockData, fontMetrics);
		measureHeightAndVerticalMargins(style, containingBlockData, fontMetrics);
		
		//measure the top, left, right and bottom offsets
		//used when the HTMLElement is 'positioned' (any position style
		//but 'static')
		measurePositionOffsets(style, containingBlockData, fontMetrics);
		
		//At this point, all the dimensions of the HTMLElement are known maybe except the
		//content height if it was set to 'auto' and thus depends on its content's height.
		//Those dimensions are now enough to layout each of the HTMLElement's children.
		//If the parent's height of this HTMLElement is set to 'auto', it will use the
		//computed dimensions of this HTMLElement to compute its own height.
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////
	// PRIVATE MEASURE METHODS
	// Measure the box model and determine
	// the computed styles using the
	// computing methods
	//////////////////////////////////////////////////////////////////////////////////////////
	
	/**
	 * Compute the 'dimensions constraints' styles :
	 * min-height, max-height, min-width and max-width
	 */
	private function measureDimensionsConstraints(style:CoreStyle, containingBlockData:ContainingBlockData, fontMetrics:FontMetricsData):Void
	{
		//max height
		style.computedStyle.maxHeight = getComputedConstrainedDimension(style.maxHeight, containingBlockData.height, containingBlockData.isHeightAuto, fontMetrics.fontSize, fontMetrics.xHeight);
		
		//min height
		style.computedStyle.minHeight = getComputedConstrainedDimension(style.minHeight, containingBlockData.height, containingBlockData.isHeightAuto, fontMetrics.fontSize, fontMetrics.xHeight, true);
		
		//max width
		style.computedStyle.maxWidth  = getComputedConstrainedDimension(style.maxWidth, containingBlockData.width, containingBlockData.isWidthAuto, fontMetrics.fontSize, fontMetrics.xHeight);
		
		//min width
		style.computedStyle.minWidth = getComputedConstrainedDimension(style.minWidth, containingBlockData.width, containingBlockData.isWidthAuto, fontMetrics.fontSize, fontMetrics.xHeight, true);
	}
	
	/**
	 * Compute the 'position offsets' styles :
	 * top, left, bottom, right, used if the HTMLElement
	 * is 'positioned' (position style other than 'static')
	 */
	private function measurePositionOffsets(style:CoreStyle, containingBlockData:ContainingBlockData, fontMetrics:FontMetricsData):Void
	{
		//left
		style.computedStyle.left = getComputedPositionOffset(style.left, containingBlockData.width, fontMetrics.fontSize, fontMetrics.xHeight);
		
		//right
		style.computedStyle.right = getComputedPositionOffset(style.right, containingBlockData.width, fontMetrics.fontSize, fontMetrics.xHeight);
		
		//top
		style.computedStyle.top = getComputedPositionOffset(style.top, containingBlockData.height, fontMetrics.fontSize, fontMetrics.xHeight);
		
		//bottom
		style.computedStyle.bottom = getComputedPositionOffset(style.bottom, containingBlockData.height, fontMetrics.fontSize, fontMetrics.xHeight);
	}
	

	// PADDINGS
	/////////////////////////////////
	
	/**
	 * Compute the top and bottom paddings of
	 * the HTMLElement's box model
	 */
	private function measureVerticalPaddings(style:CoreStyle, containingBlockData:ContainingBlockData, fontMetrics:FontMetricsData):Void
	{
		//top
		style.computedStyle.paddingTop = getComputedPadding(style.paddingTop, containingBlockData.width, fontMetrics.fontSize, fontMetrics.xHeight);
		
		//bottom
		style.computedStyle.paddingBottom = getComputedPadding(style.paddingBottom, containingBlockData.width, fontMetrics.fontSize, fontMetrics.xHeight);
	}
	
	/**
	 * Compute the left and right paddings of
	 * the HTMLElement's box model
	 */
	private function measureHorizontalPaddings(style:CoreStyle, containingBlockData:ContainingBlockData, fontMetrics:FontMetricsData):Void
	{
		//left
		style.computedStyle.paddingLeft = getComputedPadding(style.paddingLeft, containingBlockData.width, fontMetrics.fontSize, fontMetrics.xHeight);
		
		//right
		style.computedStyle.paddingRight = getComputedPadding(style.paddingRight, containingBlockData.width, fontMetrics.fontSize, fontMetrics.xHeight);
	}
	
	// HORIZONTAL DIMENSIONS
	/////////////////////////////////
	
	/**
	 * Measure the width and the horizontal margins
	 * of the HTMLElement
	 */
	private function measureWidthAndHorizontalMargins(style:CoreStyle, containingBlockData:ContainingBlockData, fontMetrics:FontMetricsData):Void
	{
		if (style.width == Dimension.cssAuto)
		{
			measureAutoWidth(style, containingBlockData, fontMetrics);
		}
		else
		{
			measureWidth(style, containingBlockData, fontMetrics);
		}
	}
	
	/**
	 * Measure the width and the horizontal margins
	 * of the HTMLElement in the case where the 'width'
	 * is set as 'auto' and thus depends on the size of the 
	 * margins.
	 * 
	 * An auto width is equal to the containing HTMLElement width minus
	 * horizontal paddings and margins.
	 */
	private function measureAutoWidth(style:CoreStyle, containingBlockData:ContainingBlockData, fontMetrics:FontMetricsData):Void
	{
		//the width is first set to 0, 
		//it will be computed once the margins are computed
		style.computedStyle.width = 0.0;	
		
		//left margin
		style.computedStyle.marginLeft = getComputedMarginLeft(style, containingBlockData, fontMetrics);
		//right margin
		style.computedStyle.marginRight = getComputedMarginRight(style, containingBlockData, fontMetrics);

		//the width is computed now that the sizes of the margins are computed
		style.computedStyle.width = getComputedAutoWidth(style, containingBlockData, fontMetrics);
	}
	
	/**
	 * Measure the width when it is not 'auto'.
	 * It might be a percentage of its containing 
	 * HTMLElement width or a length value defined
	 * in pixels or any other length unit
	 */
	private function measureWidth(style:CoreStyle, containingBlockData:ContainingBlockData, fontMetrics:FontMetricsData):Void
	{
		//get the content width (width without margins and paddings)
		style.computedStyle.width = getComputedWidth(style, containingBlockData, fontMetrics);
		
		//left margin
		style.computedStyle.marginLeft = getComputedMarginLeft(style, containingBlockData, fontMetrics);
		//right margin
		style.computedStyle.marginRight = getComputedMarginRight(style, containingBlockData, fontMetrics);
	}
	
	// VERTICAL DIMENSIONS
	/////////////////////////////////
	
	/**
	 * Measure the height and
	 * vertical margins of the 
	 * HTMLElement
	 */
	private function measureHeightAndVerticalMargins(style:CoreStyle, containingBlockData:ContainingBlockData, fontMetrics:FontMetricsData):Void
	{
		//get the content height (height without margins and paddings)
		//the height might be null at this point if it must take the content size
		//it will be set once all its children HTMLElements have been laid out
		
		if (style.height == Dimension.cssAuto)
		{
			measureAutoHeight(style, containingBlockData, fontMetrics);
		}
		else
		{
			measureHeight(style, containingBlockData, fontMetrics);
		}
	}
	
	/**
	 * Measure the height and the vertical margins
	 * of the HTMLElement in the case where the 'height' style
	 * is set as 'auto' and thus depends on the total height
	 * of its content
	 * 
	 * An auto height can't be determined until all of its children
	 * height are computed. The auto height of a HTMLElement
	 * is the addition of all of the offset heights (margin + padding + content height)
	 * of its children.
	 */
	private function measureAutoHeight(style:CoreStyle, containingBlockData:ContainingBlockData, fontMetrics:FontMetricsData):Void
	{
		//the height is set to null by default
		style.computedStyle.height = getComputedAutoHeight(style, containingBlockData, fontMetrics);
		
		//left margin
		style.computedStyle.marginTop = getComputedMarginTop(style, containingBlockData, fontMetrics);
		//right margin
		style.computedStyle.marginBottom = getComputedMarginBottom(style, containingBlockData, fontMetrics);
	
	}
	
	/**
	 * Measure the height and the vertical margins
	 * of the HTMLElement in the case where the height is
	 * either a percentage of the containing HTMLElement height
	 * or a length value exprimend in a supported unit, such
	 * as pixel
	 */
	private function measureHeight(style:CoreStyle, containingBlockData:ContainingBlockData, fontMetrics:FontMetricsData):Void
	{
		//get the computed height in pixel
		style.computedStyle.height = getComputedHeight(style, containingBlockData, fontMetrics);
		
		//left margin
		style.computedStyle.marginTop = getComputedMarginTop(style, containingBlockData, fontMetrics);
		//right margin
		style.computedStyle.marginBottom = getComputedMarginBottom(style, containingBlockData, fontMetrics);
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////
	// PRIVATE COMPUTING METHODS
	// These methods actually take a style
	// value and return a computed style value
	//////////////////////////////////////////////////////////////////////////////////////////
	
		// WIDTH
	/////////////////////////////////
	
	/**
	 * Compute the size of the width when not 'auto' and return it as pixels
	 */
	private function getComputedWidth(style:CoreStyle, containingBlockData:ContainingBlockData, fontMetrics:FontMetricsData):Float
	{
		return getComputedDimension(style.width, containingBlockData.width, containingBlockData.isWidthAuto, fontMetrics.fontSize, fontMetrics.xHeight);
	}
	
	/**
	 * Compute the size of the width when 'auto' and return it as pixels. It is equal to
	 * the remaining width of the containing HTMLElement once the margins and paddings width have been
	 * removed
	 */
	private function getComputedAutoWidth(style:CoreStyle, containingBlockData:ContainingBlockData, fontMetrics:FontMetricsData):Float
	{
		return containingBlockData.width - style.computedStyle.paddingLeft - style.computedStyle.paddingRight - style.computedStyle.marginLeft - style.computedStyle.marginRight;
	}
	
		
		// HEIGHT
	/////////////////////////////////
	
	/**
	 * Get the computed height of the HTMLElement when not 'auto' and returns it as pixels
	 */ 
	private function getComputedHeight(style:CoreStyle, containingBlockData:ContainingBlockData, fontMetrics:FontMetricsData):Float
	{		
		return getComputedDimension(style.height, containingBlockData.height, containingBlockData.isHeightAuto, fontMetrics.fontSize, fontMetrics.xHeight);
	}
	
	/**
	 * Get the computed height of the HTMLElement when 'auto' and returns it as pixels. Default for 'auto' is 0
	 * as its children total height is not known yet, it will be set once all its children have been
	 * laid out
	 */ 
	private function getComputedAutoHeight(style:CoreStyle, containingBlockData:ContainingBlockData, fontMetrics:FontMetricsData):Float
	{
		return 0;
	}
	
		// MARGINS
	/////////////////////////////////
	
	/**
	 * Compute the size of the left margin and return it as pixels
	 */
	private function getComputedMarginLeft(style:CoreStyle, containingBlockData:ContainingBlockData, fontMetrics:FontMetricsData):Float
	{
		return getComputedMargin(style.marginLeft, style.marginRight, containingBlockData.width, style.computedStyle.width, style.width == Dimension.cssAuto, style.computedStyle.paddingRight + style.computedStyle.paddingLeft, fontMetrics.fontSize, fontMetrics.xHeight, true  );
	}
	
	/**
	 * Compute the size of the right margin and return it as pixels
	 */
	private function getComputedMarginRight(style:CoreStyle, containingBlockData:ContainingBlockData, fontMetrics:FontMetricsData):Float
	{
		return getComputedMargin(style.marginRight, style.marginLeft, containingBlockData.width, style.computedStyle.width, style.width == Dimension.cssAuto, style.computedStyle.paddingRight + style.computedStyle.paddingLeft, fontMetrics.fontSize, fontMetrics.xHeight, true  );
	}
	
	/**
	 * Compute the size of the top margin and return it as pixels
	 */
	private function getComputedMarginTop(style:CoreStyle, containingBlockData:ContainingBlockData, fontMetrics:FontMetricsData):Float
	{
		return getComputedMargin(style.marginTop, style.marginBottom, containingBlockData.height, style.computedStyle.height, style.height == Dimension.cssAuto, style.computedStyle.paddingTop + style.computedStyle.paddingBottom, fontMetrics.fontSize, fontMetrics.xHeight, false  );
	}
	
	/**
	 * Compute the size of the bottom margin and return it as pixels
	 */
	private function getComputedMarginBottom(style:CoreStyle, containingBlockData:ContainingBlockData, fontMetrics:FontMetricsData):Float
	{
		return getComputedMargin(style.marginBottom, style.marginTop, containingBlockData.height, style.computedStyle.height, style.height == Dimension.cssAuto, style.computedStyle.paddingTop + style.computedStyle.paddingBottom, fontMetrics.fontSize, fontMetrics.xHeight, false  );
	}
	
	/**
	 * Compute the value of a margin thickness from a 
	 * margin style value
	 * @param	marginStyleValue contains the value of the computed margin as a unit, percentage or defined as auto
	 * @param	opositeMargin the complementary margin from the computed margin. For example for the left margin, it
	 * is the right margin
	 * @param	containingHTMLElementDimension the width and height of the HTMLElement containing the current HTMLElement, used for
	 * computing percentage values
	 * @param	computedDimension a computed dimension (width or height) of the content of the current HTMLElement
	 * @param isDimensionAuto wether the reference dimensions is auto, meaning its computed width id not set yet
	 * @param	computedPaddingsDimension the computed dimensions of both horizontal or vertical paddings, depending if the computed
	 * margin is horizontal or vertical
	 * @param  fontSize the computed font size of the containing HTMLElement, used to compute the marginStyleValue if it is a length value
	 * defined in 'em'
	 * @param  xHeight the computed x height of the containing HTMLElement, used to compute the marginStyleValue if it is a length value
	 * defined in 'ex'
	 * @param	isHorizontalMargin true if the margin is horizontal (left or right)
	 * @return the computed thickness of the margin
	 */
	private function getComputedMargin(marginStyleValue:Margin, opositeMargin:Margin, containingHTMLElementDimension:Float, computedDimension:Float, isDimensionAuto:Bool, computedPaddingsDimension:Float, fontSize:Float, xHeight:Float, isHorizontalMargin:Bool):Float
	{
		//the return value
		var computedMargin:Float;
		
		//check which type of value is defined
		switch (marginStyleValue)
		{
			//it's a length (an absolute value
			//with a unit)
			case length(value):
				computedMargin = UnitManager.getPixelFromLength(value, fontSize, xHeight);
			
			//It's a percentage, compute it from the containing dimension
			case percent(value): 
				
				//margin default to 0 if containing dimension is undefined
				if (isDimensionAuto == true)
				{
					computedMargin = 0.0;
				}
				else
				{
					computedMargin = UnitManager.getPixelFromPercent(value, containingHTMLElementDimension);
				}
			
			//auto margins take the remaining place left after
			//paddings, other margin and dimension are set
			case cssAuto:	
				computedMargin = getComputedAutoMargin(marginStyleValue, opositeMargin, containingHTMLElementDimension, computedDimension, isDimensionAuto, computedPaddingsDimension, fontSize, xHeight, isHorizontalMargin);
		}
		
		return computedMargin;
	}
	
	/**
	 * Return the width of an auto margin
	 */
	private function getComputedAutoMargin(marginStyleValue:Margin, opositeMargin:Margin, containingHTMLElementDimension:Float, computedDimension:Float, isDimensionAuto:Bool, computedPaddingsDimension:Float, fontSize:Float, xHeight:Float, isHorizontalMargin:Bool):Float
	{
		var computedMargin:Float;
		
		//if the containing dimension is set to auto,
		//margin default to 0. Top and bottom margin also default to 0 with
		//an auto value
		if (isHorizontalMargin == false || isDimensionAuto == true)
		{
			computedMargin = 0.0;
		}
		//if the margin is either left or right the containing width is defined
		else
		{
			//check if the oposite margin is set to auto too
			switch (opositeMargin)
			{
				//if it is, then both margin have the same thickness and share the place left by the content and paddings
				case cssAuto:
					computedMargin = (containingHTMLElementDimension - computedDimension - computedPaddingsDimension) / 2;
				
				//else the oposite margin thickness is computed and the computed margin is deduced from the remaining space	
				default:
					var opositeComputedMargin:Float = getComputedMargin(opositeMargin, marginStyleValue, containingHTMLElementDimension, computedDimension, isDimensionAuto, computedPaddingsDimension, fontSize, xHeight, isHorizontalMargin);
					computedMargin = containingHTMLElementDimension - computedDimension - computedPaddingsDimension - opositeComputedMargin; 
			}
		}
		
		return computedMargin;
	}
	
	/**
	 * Compute a contrain dimensions (max-height, min-width...)
	 * from a contrain style value
	 * @param	constrainedDimension can be defined as a unit, a percentage
	 * or to "none" if no constraint must be applied
	 * @param	containingHTMLElementDimension the dimension of the HTMLElement into which 
	 * the current HTMLElement must fit
	 * @param  isContainingDimensionAuto wether the containinHTMLElementDimension is defined as 'auto'
	 * @param  fontSize the computed font size of the containing HTMLElement, used to compute the constrainedDimension if it is a length value
	 * defined in 'em'
	 * @param  xHeight the computed x height of the containing HTMLElement, used to compute the constrainedDimension if it is a length value
	 * defined in 'ex'
	 * @param	isMinConstraint true if min-width or min-height is computed
	 * @return a computed contraint dimensions in pixels
	 */
	private function getComputedConstrainedDimension(constrainedDimension:ConstrainedDimension, containingHTMLElementDimension:Float, isContainingDimensionAuto:Bool, fontSize:Float, xHeight:Float, isMinConstraint:Bool = false):Float
	{
		var computedConstraintDimension:Float;
		
		//check which type of value is defined
		switch (constrainedDimension)
		{
			//it's a length (an absolute value
			//with a unit)
			case length(value):
				computedConstraintDimension = UnitManager.getPixelFromLength(value, fontSize, xHeight);
			
			//It's a percentage, compute it from the containing dimension	
			case percent(value):
				//if the containing HTMLElement dimension is not defined,
				//min value default to 0, for max value,
				//default to infinity (no constraints)
				if (isContainingDimensionAuto == true)
				{
					if (isMinConstraint == true)
					{
						computedConstraintDimension = 0;
					}
					else
					{
						computedConstraintDimension = Math.POSITIVE_INFINITY;
					}
				}
				else
				{
					computedConstraintDimension = UnitManager.getPixelFromPercent(value, containingHTMLElementDimension);
				}
				
			//here no constraint are applied,
			//defaults are set
			case none:
				if (isMinConstraint == true)
				{
					computedConstraintDimension = 0.0;
				}
				else 
				{
					computedConstraintDimension = Math.POSITIVE_INFINITY;
				}
		}
		
		return computedConstraintDimension;
	}
	
	/**
	 * Compute a position offset style (left, right, bottom and top) in pixel
	 * from a position offset style value
	 * 
	 * @param positionOffsetStyleValue might be set to 'auto', an absolute value
	 * or a percent value
	 * @param containingHTMLElementDimension, dimension to use as reference to compute 
	 * from a percent value
	 * @param  fontSize the computed font size of the containing HTMLElement, used to compute the PositionOffset if it is a length value
	 * defined in 'em'
	 * @param  xHeight the computed x height of the containing HTMLElement, used to compute the PositionOffset if it is a length value
	 * defined in 'ex'
	 */
	private function getComputedPositionOffset(positionOffsetStyleValue:PositionOffset, containingHTMLElementDimension:Float, fontSize:Float, xHeight:Float):Float
	{
		var computedPositionOffset:Float;
		
		switch(positionOffsetStyleValue)
		{
			case length(value):
				computedPositionOffset = UnitManager.getPixelFromLength(value, fontSize, xHeight);
				
			case percent(value):
				computedPositionOffset = UnitManager.getPixelFromPercent(value, containingHTMLElementDimension);
				
			case cssAuto:
				computedPositionOffset = 0.0;
		}
		
		return computedPositionOffset;
	}
	
	/**
	 * Compute the content dimension (width or height) of a HTMLElement
	 * @param	dimensionStyleValue can be defined as a unit, a percent or auto
	 * @param	containingHTMLElementDimension the dimension of the HTMLElement into which 
	 * the current HTMLElement must fit
	 * @param  isContainingDimensionAuto wether the containinHTMLElementDimension is defined as 'auto'
	 * @param  fontSize the computed font size of the containing HTMLElement, used to compute the Dimension if it is a length value
	 * defined in 'em'
	 * @param  xHeight the computed x height of the containing HTMLElement, used to compute the Dimension if it is a length value
	 * defined in 'ex'
	 * @return a computed dimension in pixel
	 */
	private function getComputedDimension(dimensionStyleValue:Dimension, containingHTMLElementDimension:Float, isContainingDimensionAuto:Bool, fontSize:Float, xHeight:Float):Float
	{
		var computedDimensions:Float;
		
		//check which type of value is defined
		switch (dimensionStyleValue)
		{
			//it's a length (an absolute value
			//with a unit)
			case length(value):
				computedDimensions = UnitManager.getPixelFromLength(value, fontSize, xHeight);
			
			//It's a percentage, compute it from the containing dimension	
			case percent(value):
				computedDimensions = UnitManager.getPixelFromPercent(value, containingHTMLElementDimension);

			case cssAuto:
				//Dealt with in the measureAutoHeight and measureAutoWidth
				//methods
				computedDimensions = 0;
		}
		
		return computedDimensions;
	}
	
	/**
	 * Compute a padding's thickness from a padding style value
	 * @param	paddingStyleValue can be defined as a unit (px, em...) or a percentage
	 * @param	containingHTMLElementDimension the dimensions of the HTMLElement into which 
	 * the current HTMLElement must fit
	 * @param  fontSize the computed font size of the containing HTMLElement, used to compute the Padding if it is a length value
	 * defined in 'em'
	 * @param  xHeight the computed x height of the containing HTMLElement, used to compute the Padding if it is a length value
	 * defined in 'ex'
	 * @return a computed padding in pixel
	 */
	private function getComputedPadding(paddingStyleValue:Padding, containingHTMLElementDimension:Float, fontSize:Float, xHeight:Float):Float
	{
		var computedPaddingValue:Float;
		
		//check which type of value is defined
		switch (paddingStyleValue)
		{
			//it's a length (an absolute value
			//with a unit)
			case length(value):
				computedPaddingValue = UnitManager.getPixelFromLength(value, fontSize, xHeight);
			
			//It's a percentage, compute it from the containing dimension		
			case percent(value):
				computedPaddingValue = UnitManager.getPixelFromPercent(value, containingHTMLElementDimension);
				
		}
		
		return computedPaddingValue;
	}
	
	
}