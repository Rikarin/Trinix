/**
 * Copyright (c) 2014-2015 Trinix Foundation. All rights reserved.
 * 
 * This file is part of Trinix Operating System and is released under Trinix
 * Public Source Licence Version 1.0 (the 'Licence'). You may not use this file
 * except in compliance with the License. The rights granted to you under the
 * License may not be used to create, or enable the creation or redistribution
 * of, unlawful or unlicensed copies of an Trinix operating system, or to
 * circumvent, violate, or enable the circumvention or violation of, any terms
 * of an Trinix operating system software license agreement.
 * 
 * You may obtain a copy of the License at
 * https://github.com/Bloodmanovski/Trinix and read it before using this file.
 * 
 * The Original Code and all software distributed under the License are
 * distributed on an 'AS IS' basis, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied. See the License for the specific language
 * governing permissions and limitations under the License.
 * 
 * Contributors:
 *      Matsumoto Satoshi <satoshi@gshost.eu>
 */

module System.AppKit.Responder;

import System.AppKit;

//TODO:
class DragEventArgs : RoutedEventArgs { }
class KeyboardFocusChangedEventArgs : RoutedEventArgs { }
class MouseEventArgs : RoutedEventArgs { }
class DependencyPropertyChangedEventArgs : RoutedEventArgs { }
class KeyEventArgs : RoutedEventArgs { }
class MouseButtonEventArgs : RoutedEventArgs { }


abstract class Responder {
    protected void OnGotFocus(RoutedEventArgs e)              { }
    protected void OnLostFocus(RoutedEventArgs e)             { }
    protected void OnChildDesiredSizeChanged(Responder child) { }

    protected void OnDragEnter(DragEventArgs e)               { }
    protected void OnDragLeave(DragEventArgs e)               { }
    protected void OnDragOver(DragEventArgs e)                { }
    protected void OnDrop(DragEventArgs e)                    { }

    protected void OnGotKeyboardFocus(KeyboardFocusChangedEventArgs e) { }
    protected void OnLostKeyboardFocus(KeyboardFocusChangedEventArgs e) { }
    protected void OnIsKeyboardFocusedChanged(DependencyPropertyChangedEventArgs e) { }
    protected void OnIsKeyboardFocusWithinChanged(DependencyPropertyChangedEventArgs e) { }
    protected void OnKeyDown(KeyEventArgs e) { }
    protected void OnKeyUp(KeyEventArgs e) { }

    protected void OnMouseCapture(MouseEventArgs e) { }
    protected void OnLostMouseCapture(MouseEventArgs e) { }
    protected void OnIsMouseCapturedChanged(DependencyPropertyChangedEventArgs e) { }
    protected void OnIsMouseCaptureWithinChanged(DependencyPropertyChangedEventArgs e) { }
    protected void OnIsMouseDirectlyOverChanged(DependencyPropertyChangedEventArgs e) { }

    protected void OnMouseDown(MouseButtonEventArgs e) { }
    protected void OnMouseEnter(MouseEventArgs e) { }
    protected void OnMouseLeave(MouseEventArgs e) { }
    //TODO: tu som skoncil v docu https://msdn.microsoft.com/en-us/library/system.windows.uielement%28v=vs.110%29.aspx

    //TODO: manipulation??
}