/*
	This file is part of Cocktail http://www.silexlabs.org/groups/labs/cocktail/
	This project is © 2010-2011 Silex Labs and is released under the GPL License:
	This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 
	This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
	To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
package cocktail.core.html;

import cocktail.core.event.MouseEvent;
import cocktail.core.event.UIEvent;
import cocktail.core.renderer.ElementRenderer;
import cocktail.core.renderer.ScrollBarRenderer;
import cocktail.Lib;

/**
 * This HTMLElement is a scrollbar displayed as needed when the content
 * of a BlockBoxRenderer overflows. It might be displayed as horizontal 
 * or vertical.
 * 
 * It is part of the Shadow DOM, meaning that it won't appear in the public
 * DOM tree, as it is owned and instantiated by a BlockBoxRenderer when needed.
 * This allows styling it like any other DOM tree HTMLElement without polluting
 * the public DOM tree
 * 
 * TODO : implement disabled scrollbar when maxScroll is smaller than scroll height / width
 * 
 * TODO : reproducing Windows look and feel, is this what we want ?
 * 
 * @author Yannick DOMINGUEZ
 */
class ScrollBar extends HTMLElement
{
	/**
	 * The amount of scroll offset to add or remove when the up
	 * or down arrow is clicked
	 */
	private static inline var ARROW_SCROLL_OFFSET:Int = 10;
	
	/**
	 * The amount of scroll offset to add or remove the
	 * track is clicked
	 */
	private static inline var TRACK_SCROLL_OFFSET:Int = 50;
	
	/**
	 * wether tht scrollbar should be displayed vertically
	 */
	private var _isVertical:Bool;
	
	/**
	 * The current scroll offset of the scroll bar
	 */
	private var _scroll:Float;
	public var scroll(get_scroll, set_scroll):Float;
	
	/**
	 * The maximum scroll offset of the scrollbar, corresponding
	 * to the height or width bounds of the children of the
	 * BlockBoxRenderer owning the ScrollBar
	 */
	private var _maxScroll:Float;
	public var maxScroll(get_maxScroll, set_maxScroll):Float;
	
	/**
	 * A reference to the thumb of the scroll
	 */
	private var _scrollThumb:HTMLElement;
	
	/**
	 * A reference to the up arrow of the scroll, for
	 * an horizontal scrollbar, it is displayed on the left
	 */
	private var _upArrow:HTMLElement;
	
	/**
	 * A reference to the down arrow of the scroll,
	 * for an horizontal scrollbar it is displayed on the right
	 */
	private var _downArrow:HTMLElement;
	
	/**
	 * When the thumb of the scrollbar is clicked, store
	 * the x or y position of the mouse so that it 
	 * can be used to compute the delta of each subsequent
	 * mouse move
	 */
	private var _mouseMoveStart:Float;
	
	//////////////////////////////////////////////////////////////////////////////////////////
	// CONSTRUCTOR AND INIT
	//////////////////////////////////////////////////////////////////////////////////////////
	
	/**
	 * class constructor. Init class parameter. 
	 * Instantiate and attach scrollbar parts
	 */
	public function new(isVertical:Bool) 
	{
		
		_isVertical = isVertical;
		
		super("");
		
		_scrollThumb = new HTMLElement("");
		_upArrow = new HTMLElement("");
		_downArrow = new HTMLElement("");
	
		_scroll = 0;
		_maxScroll = 0;
		_mouseMoveStart = 0;
		
		//style the scrollbar parts for vertical
		//or horizontal scrollbar
		initScrollBar();
		
		if (_isVertical)
		{
			initVerticalScrollBar();
		}
		else
		{
			initHorizontalScrollBar();
		}
		
		//attach the different scrollbar parts
		appendChild(_scrollThumb);
		appendChild(_upArrow);
		appendChild(_downArrow);
		
		//set callbacks on the scrollbar parts
		_onMouseDown = onTrackMouseDown;
		_scrollThumb.onmousedown = onThumbMouseDown;
		_downArrow.onmousedown = onDownArrowMouseDown;
		_upArrow.onmousedown = onUpArrowMouseDown;
		
	}
	
	/**
	 * style the scrollbar working for horizontal
	 * and vertical scrollbar
	 */
	private function initScrollBar():Void
	{
		_style.backgroundColor = "#DDDDDD";
		_style.display = "block";
		_style.position = "absolute";
		
		_scrollThumb.style.backgroundColor = "#AAAAAA";
		_scrollThumb.style.position = "absolute";
		_scrollThumb.style.display = "block";
		_scrollThumb.style.width = "15px";
		_scrollThumb.style.height = "15px";
		
		_upArrow.style.backgroundColor = "#CCCCCC";
		_upArrow.style.position = "absolute";
		_upArrow.style.display = "block";
		_upArrow.style.width = "15px";
		_upArrow.style.height = "15px";
		
		_downArrow.style.backgroundColor = "#CCCCCC";
		_downArrow.style.position = "absolute";
		_downArrow.style.display = "block";
		_downArrow.style.width = "15px";
		_downArrow.style.height = "15px";
		
	}
	
	/**
	 * style as a vertical scrollbar
	 */
	private function initVerticalScrollBar():Void
	{
		_style.height = "100%";
		_style.width = "15px";
		_style.right = "0";
		_style.top = "0";
		
		_downArrow.style.bottom = "0";
		
		_scrollThumb.style.top = "15px";
	}
	
		
	/**
	 * style as an horizontal scrollbar
	 */
	private function initHorizontalScrollBar():Void
	{
		_style.width = "100%";
		_style.height = "15px";
		_style.bottom = "0";
		_style.left = "0";
		
		_downArrow.style.right = "0";
		
		_scrollThumb.style.left = "15px";
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////
	// OVERRIDEN PRIVATE RENDERING TREE METHODS
	//////////////////////////////////////////////////////////////////////////////////////////
	
	override private function createElementRenderer():Void
	{
		_elementRenderer = new ScrollBarRenderer(this);
		_elementRenderer.coreStyle = _coreStyle;
	}
	
	
	/**
	 * The Scrollbar has no DOM parent node as it is part of the Shadow DOM
	 * and belongs to a BlockBoxRenderer, however its parent should be considered
	 * rendered so that the scroll can render itself and its parent
	 */ 
	override private function isParentRendered():Bool
	{
		return true;
	}

	/**
	 * do nothing, as attachement is managed by the owning BlockBoxRenderer
	 */
	override private function attachToParentElementRenderer():Void
	{
	
	}

	/**
	 * do nothing, as detachement is managed by the owning BlockBoxRenderer
	 */
	override private function detachFromParentElementRenderer():Void
	{
		
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////
	// SCROLL ARROWS
	//////////////////////////////////////////////////////////////////////////////////////////
	
	/**
	 * on mouse down, increment the scroll offset
	 * 
	 * TODO : add timer to call the method again while the mouse is down
	 */
	private function onDownArrowMouseDown(event:MouseEvent):Void
	{
		scroll += ARROW_SCROLL_OFFSET;
	}
	
	/**
	 * on mouse down, decrement the scroll offset
	 */
	private function onUpArrowMouseDown(event:MouseEvent):Void
	{
		scroll -= ARROW_SCROLL_OFFSET;
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////
	// SCROLL THUMB
	//////////////////////////////////////////////////////////////////////////////////////////
	
	//TODO : should add event listener to body instead of callback
	//which erase all other callbacks
	/**
	 * on mouse down of the thumb of the scroll, start to listen
	 * to global mouse move event to update the scroll and to
	 * global mouse up event to stop scrolling with the thumb
	 */
	private function onThumbMouseDown(event:MouseEvent):Void
	{
		//store the current x and y of the mouse, as the thumb
		//scrolling is applied as a delta with the new mouse position
		//on each mouse move
		if (_isVertical == true)
		{
			_mouseMoveStart = event.screenY;
		}
		else
		{
			_mouseMoveStart = event.screenX;
		}
	
		
		cocktail.Lib.document.body.onmousemove = onThumbMove;
		cocktail.Lib.document.body.onmouseup = onThumbMouseUp;
	}
	
	/**
	 * On mouse up, stops the thumb scrolling
	 */
	private function onThumbMouseUp(event:MouseEvent):Void
	{
		cocktail.Lib.document.body.onmousemove = null;
		cocktail.Lib.document.body.onmouseup = null;
	}
	
	/**
	 * When the mouse move, while thethumb is pressed, update the
	 * scroll offset using the delta of the current mouse position
	 * with its position when the thumb scroll began
	 */
	private function onThumbMove(event:MouseEvent):Void
	{
		if (_isVertical == true)
		{
			scroll = _mouseMoveStart + (event.screenY - _mouseMoveStart) ;
	
		}
		else
		{
			//TODO : doesn't work
			var thumbDelta:Float = event.screenX - _mouseMoveStart;
			scroll += thumbDelta;
			
			_mouseMoveStart = event.screenX;
		}
	}
	 
	//////////////////////////////////////////////////////////////////////////////////////////
	// SCROLL TRACK
	//////////////////////////////////////////////////////////////////////////////////////////
	
	/**
	 * When the track is clicked, either increment or decrement
	 * the scroll offset based on wether the click on the track
	 * was before or after the scroll thumb
	 */
	private function onTrackMouseDown(event:MouseEvent):Void
	{
		if (_isVertical == true)
		{
			if (event.screenY > _scrollThumb.elementRenderer.globalBounds.y)
			{
				scroll += TRACK_SCROLL_OFFSET;
			}
			else
			{
				scroll -= TRACK_SCROLL_OFFSET;
 			}
			
		}
		else
		{
			if (event.screenX > _scrollThumb.elementRenderer.globalBounds.x)
			{
				scroll += TRACK_SCROLL_OFFSET;
			}
			else
			{
				scroll -= TRACK_SCROLL_OFFSET;
 			}
		}
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////
	// SCROLL UPDATE
	//////////////////////////////////////////////////////////////////////////////////////////
	
	private function updateScroll():Void
	{
		if (_scroll > _maxScroll)
		{
			_scroll = maxScroll;
		}
		else if (_scroll < 0)
		{
			_scroll = 0;
		}
		
		var progress:Float = scroll / maxScroll;
		
		if (_isVertical == true)
		{
			var thumbY:Int = Math.round(progress * (_coreStyle.computedStyle.height -
			_upArrow.coreStyle.computedStyle.height - _downArrow.coreStyle.computedStyle.height - _scrollThumb.coreStyle.computedStyle.height)
			+  _upArrow.coreStyle.computedStyle.height);
			_scrollThumb.style.top = thumbY + "px";
		}
		else
		{
			var thumbX:Int = Math.round(progress * (_coreStyle.computedStyle.width -
			_upArrow.coreStyle.computedStyle.width - _downArrow.coreStyle.computedStyle.width - _scrollThumb.coreStyle.computedStyle.width)
			+  _upArrow.coreStyle.computedStyle.width);
			
			_scrollThumb.style.left = thumbX + "px";
		}
		
		dispatchScrollEvent();
	}
	
	/**
	 * When the max scroll offset changes, 
	 * the size of the thumb to reflect
	 * the amount of scrollablze offset
	 */
	private function updateThumbSize():Void
	{
		
		if (_isVertical == true)
		{
			var thumbHeight:Float = _coreStyle.computedStyle.height - _downArrow.coreStyle.computedStyle.height - _upArrow.coreStyle.computedStyle.height - maxScroll;

			//TODO : min size should not be hard-coded
			if (thumbHeight < 15)
			{
				thumbHeight = 15;
			}
			
			if (thumbHeight != _scrollThumb.coreStyle.computedStyle.height)
			{
				_scrollThumb.style.height = thumbHeight + "px";
			}
			
		}
		else
		{
			var thumbWidth:Float = _coreStyle.computedStyle.width - _downArrow.coreStyle.computedStyle.width - _upArrow.coreStyle.computedStyle.width - maxScroll;
			
			if (thumbWidth < 15)
			{
				thumbWidth = 15;
			}
			
			if (thumbWidth != _scrollThumb.coreStyle.computedStyle.width)
			{
				_scrollThumb.style.width = thumbWidth + "px";
			}
		}
	}
	
	private function dispatchScrollEvent():Void
	{
		if (_onScroll != null)
		{
			var scrollEvent:UIEvent = new UIEvent();
			scrollEvent.initUIEvent(UIEvent.SCROLL, false, false, 0.0);
			_onScroll(scrollEvent);
		}
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////
	// GETTER/SETTER
	//////////////////////////////////////////////////////////////////////////////////////////
	
	private function get_maxScroll():Float 
	{
		return _maxScroll;
	}
	
	private function set_maxScroll(value:Float):Float 
	{
		_maxScroll = value;
		updateThumbSize();
		return value;
	}

	private function get_scroll():Float
	{
		return _scroll ;
	}
	
	private function set_scroll(value:Float):Float 
	{
		_scroll = value;
		updateScroll();
		return value;
	}
}