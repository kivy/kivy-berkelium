'''
Berkelium Webbrowser Extension
==============================

This extension provide a wrapper in Python / Kivy around Berkelium project.
Berkelium project is a offscreen webbrower based on Chromium. You can check
more about it at http://berkelium.org/

About berkelium
---------------

Berkelium is now used without any patch.
https://github.com/sirikata/berkelium/tree/

Usage of Webbrowser
-------------------

We not providing a direct access to Berkelium (cpp wrapping in Python is
complex), but we are providing a Widget that use Berkelium.

For example, if you want to create a Webbrowser widget that load Google::

    wb = Webbrowser(url='http://google.fr')

You can change the url later::

    wb.url = 'http://youtube.com/'

API
---
'''

__all__ = ('Webbrowser', )

import kivy
kivy.require('1.0.7')

from os import chmod
from os.path import dirname, realpath, join
from weakref import ref
from kivy.base import EventLoop
from kivy.clock import Clock
from kivy.factory import Factory
from kivy.graphics import Color, Rectangle
from kivy.logger import Logger
from kivy.uix.widget import Widget
from kivy.utils import QueryDict
from kivy.properties import StringProperty, ObjectProperty, AliasProperty, \
    BooleanProperty, OptionProperty, ListProperty, NumericProperty

try:
    import _berkelium as berkelium
except ImportError:
    Logger.critical('Unable to load berkelium extension.')
    Logger.critical('Ensure that you have the good version for your platform')
    raise

# ensure the berkelium binary will be executable
curdir = dirname(__file__)
chmod(join(curdir, 'data', 'berkelium'), 0755)

_berkelium_init = False
_berkelium_listeners = []
_berkelium_counter = 0

def _update_berkelium(*largs):
    berkelium.update()
    global _berkelium_counter, _berkelium_listeners
    _berkelium_counter += 1
    if _berkelium_counter % 30 == 0:
        _berkelium_listeners = [x for x in _berkelium_listeners if x()]
        if not _berkelium_listeners:
            Clock.unschedule(_update_berkelium)

def _install_berkelium_update(listener):
    # force the reschedule of the berkelium update.
    Clock.unschedule(_update_berkelium)
    Clock.schedule_interval(_update_berkelium, 1 / 30.)
    # add the listener into the list
    _berkelium_listeners.append(ref(listener))

def _init_berkelium():
    global _berkelium_init
    if _berkelium_init:
        return
    _berkelium_init = True
    berkelium.init(realpath(join(dirname(__file__), 'data')))

class _WindowDelegate(berkelium.WindowDelegate):
    def __init__(self, impl, width, height, usetrans):
        self.impl = impl
        self.debug = False
        super(_WindowDelegate, self).__init__(width, height, usetrans)

    def onTitleChanged(self, title):
        if self.debug:
            print 'Wb(%x).onTitleChanged()' % id(self), title
        self.impl.title = title

    def onAddressBarChanged(self, newURL):
        if self.debug:
            print 'Wb(%x).onAddressBarChanged()' % id(self), newURL
        self.impl.url = newURL

    def onStartLoading(self, newURL):
        if self.debug:
            print 'Wb(%x).onStartLoading()' % id(self), newURL
        self.impl.dispatch('on_start_loading', newURL)

    def onLoad(self):
        if self.debug:
            print 'Wb(%x).onLoad()' % id(self)
        self.impl.dispatch('on_load')

    def onCrashedWorker(self):
        if self.debug:
            print 'Wb(%x).onCrashedWorker()' % id(self)
        self.impl.dispatch('on_crashed_worker')

    def onCrashedPlugin(self, pluginName):
        if self.debug:
            print 'Wb(%x).onCrashedPlugin()' % id(self)
        self.impl.dispatch('on_crashed_plugin', pluginName)

    def onProvisionalLoadError(self, url, errorCode, isMain):
        if self.debug:
            print 'Wb(%x).onProvisionalLoadError()' % id(self), \
                    url, errorCode, isMain
        self.impl.dispatch('on_provisional_load_error', url, errorCode, isMain)

    def onConsoleMessage(self, message, sourceId, line_no):
        if self.debug:
            print 'Wb(%x).onConsoleMessage()' % id(self), \
                    message, sourceId, line_no
        self.impl.dispatch('on_console_message', message, sourceId, line_no)

    def onScriptAlert(self, message, defaultValue, url, flags, success):
        if self.debug:
            print 'Wb(%x).onScriptAlert()' % id(self), \
                    message, defaultValue, url, flags, success
        self.impl.dispatch('on_script_alert', message, defaultValue, url, flags, success)

    def onNavigationRequested(self, newURL, referrer, isNewWindow):
        if self.debug:
            print 'Wb(%x).onNavigationRequested()' % id(self), \
                    newURL, referrer, isNewWindow
        return self.impl.dispatch('on_navigation_requested', newURL, referrer, isNewWindow)

    def onLoadingStateChanged(self, isLoading):
        if self.debug:
            print 'Wb(%x).onLoadingStateChanged()' % id(self), isLoading
        self.impl.is_loading = isLoading

    def onTooltipChanged(self, text):
        if self.debug:
            print 'Wb(%x).onTooltipChanged()' % id(self), text
        self.impl.tooltip = text

    def onCrashed(self):
        if self.debug:
            print 'Wb(%x).onCrashed()' % id(self)
        self.impl.status = 'crashed'

    def onUnresponsive(self):
        if self.debug:
            print 'Wb(%x).onUnResponsive()' % id(self)
        self.impl.status = 'unresponsive'

    def onResponsive(self):
        if self.debug:
            print 'Wb(%x).onResponsive()' % id(self)
        self.impl.status = 'ok'

    def onCreatedWindow(self):
        if self.debug:
            print 'Wb(%x).onCreatedWindow()' % id(self)
        self.impl.dispatch('on_created_window')

    def onWidgetCreated(self, _id):
        if self.debug:
            print 'Wb(%x).onWidgetCreated()' % id(self)
        self.impl.dispatch('on_widget_created', _id)

    def onWidgetDestroyed(self, _id):
        if self.debug:
            print 'Wb(%x).onWidgetDestroyed()' % id(self)
        self.impl.dispatch('on_widget_destroyed', _id)

    def onWidgetResize(self, _id, size):
        if self.debug:
            print 'Wb(%x).onWidgetResize()' % id(self)
        self.impl.dispatch('on_widget_resize', _id, size)

    def onWidgetMove(self, _id, pos):
        if self.debug:
            print 'Wb(%x).onWidgetMove()' % id(self)
        self.impl.dispatch('on_widget_move', _id, pos)

    def onWidgetPaint(self, _id, texture):
        if self.debug:
            print 'Wb(%x).onWidgetPaint()' % id(self)
        self.impl.dispatch('on_widget_paint', _id, texture)

    def onPaint(self):
        if self.debug:
            print 'Wb(%x).onPaint()' % id(self)
        self.impl.dispatch('on_paint')


class Webbrowser(Widget):
    '''Webbrowser class. See module documentation for more information.

    :Events:
        `on_start_loading`: url
            Fired when a new page start to load
        `on_load`:
            Fired when loading is in progress
        `on_crashed_worker`:
            Fired when a worker crash
        `on_crashed_plugin`:
            Fired when a plugin crash
        `on_provisional_load_error`: url, error_code, is_main
            Fired when we cannot reach the url
        `on_console_message`: message, source_id, line_no
            Fired when a new message for console is available
        `on_script_alert`: message, default_value, url, flags, success
            Fired when a javascript do a alert() box
        `on_navigation_requested`: url, referrer, is_new_window
            Fired when a navigation is requested from a page (popup for example)
        `on_created_window`:
            Fired when a new window is created
        `on_widget_created`:
            Fired when a new widget is created
        `on_widget_Destroyed`:
            Fired when a widget is destroyed
        `on_widget_resize`:
            Fired when a new widget is resized
        `on_widget_move`:
            Fired when a new widget is moving
        `on_widget_paint`:
            Fired when the Widget texture is updated
        `on_paint`:
            Fired when the texture is updated
    '''

    #
    # Privates
    #
    _bk = ObjectProperty(None)

    def get_bk(self):
        return self._bk

    bk = AliasProperty(get_bk, None, bind=('_bk', ))
    '''
    Internal object that represent the Berkelium instance. You might need it to
    control some internal state of berkelium.
    '''

    #
    # Properties
    #
    url = StringProperty(None)
    '''Url of the page, default to None. As soon as you change it, it will be
    reloaded::

        wb = Webbrowser()
        wb.url = 'http://kivy.org'

    :data:`url` is a :class:`~kivy.properties.StringProperty`, default to None.
    '''

    scroll_timeout = NumericProperty(200)
    '''Wait for an amount of time in milliseconds to a second touch.
    If 2 touches have been placed in that time, do a scroll. Otherwise, send a click.

    .. versionadded:: 1.1

    :data:`scroll_timeout` is a :class:`~kivy.properties.NumericProperty`,
    default to 200.
    '''

    is_loading = BooleanProperty(False)
    '''Indicate if the page is currently loading.

    :data:`is_loading` is a :class:`~kivy.properties.BooleanProperty`, default
    to False, read-only.
    '''

    title = StringProperty('')
    '''Title of the current webpage.

    :data:`title` is a :class:`~kivy.properties.StringProperty`, default
    to '', read-only.
    '''

    tooltip = StringProperty('')
    '''Current tooltip to show under the cursor.

    :data:`tooltip` is a :class:`~kivy.properties.StringProperty`, default to
    '', read-only
    '''

    status = OptionProperty('ok', options=('ok', 'crashed', 'unresponsive'))
    '''Status of the internal browser. The availables options are :

        - ok: everything is ok
        - crashed: the internal module have crashed, you must reload it.
        - unresponsive: the internal module is unresponsive, you may reload it.

    :data:`status` is a `~kivy.properties.StringProperty`, default to 'ok',
    read-only.
    '''

    transparency = BooleanProperty(False)
    '''Indicate if the webpage should have a transparent background or not. Be
    careful, this will work only if your webpage don't set a big div with a
    background color. You can use it for rendering custom html like::

        with open('bleh.html', 'w') as fd:
            fd.write('<h1 style="color: #ff0000">Hello world</h1>')
        wb = Webbrowser(transparency=True, size=(150, 50))
        wb.open_filename('bleh.html')

    This will result to show a big Hello world in red.
    '''

    texture = ObjectProperty(None)
    '''Represent the texture that contain the webpage rendered
    Depending of the texture creation, the value will be a
    :class:`~kivy.graphics.texture.Texture` or
    :class:`~kivy.graphics.texture.TextureRegion` object.

    :data:`texture` is a :class:`~kivy.properties.ObjectProperty`, default to
    None.
    '''

    texture_size = ListProperty([0, 0])
    '''Texture size of the image.

    .. warning::

        The texture size is set after the texture property. So if you listen on
        the change to :data:`texture`, the property texture_size will be not yet
        updated. Use self.texture.size instead.
    '''

    last_console_message = ObjectProperty(None)
    '''Stores the last console message sent by the webpage. A
    'on_console_message' event is fired when a new console message happens. It
    enables the app to get backward triggers coming from the webpage.

    Composed of (message, source_id, line_no)

    :data:`last_console_message` is a :class:`~kivy.properties.ObjectProperty`,
    default to None.
    '''

    def __init__(self, **kwargs):
        _init_berkelium()

        # Before doing anything, ensure the windows exist.
        EventLoop.ensure_window()
        EventLoop.window.bind(on_keyboard=self.on_window_keyboard)

        self._touches = []
        self._bk = _WindowDelegate(self, self.width, self.height,
                                   self.transparency)
        self.register_event_type('on_start_loading')
        self.register_event_type('on_load')
        self.register_event_type('on_crashed_worker')
        self.register_event_type('on_crashed_plugin')
        self.register_event_type('on_provisional_load_error')
        self.register_event_type('on_console_message')
        self.register_event_type('on_script_alert')
        self.register_event_type('on_navigation_requested')
        self.register_event_type('on_created_window')
        self.register_event_type('on_widget_created')
        self.register_event_type('on_widget_destroyed')
        self.register_event_type('on_widget_resize')
        self.register_event_type('on_widget_move')
        self.register_event_type('on_widget_paint')
        self.register_event_type('on_paint')
        super(Webbrowser, self).__init__(**kwargs)
        if self.url is not None:
            self.open_url(self.url)
        with self.canvas:
            self._g_color = Color(1, 1, 1)
            self._g_rect = Rectangle(texture=self._bk.texture, size=self.size)
            self._g_rect.tex_coords = (0, 1, 1, 1, 1, 0, 0, 0)
        _install_berkelium_update(self)

    def on_window_keyboard(self, instance, key, scancode, text, modifiers):
        # handle first special keys
        if key in map(ord, ('\b', '\r', '\n', ' ')) or \
            ord('a') >= key <= ord('z') or \
            ord('A') >= key <= ord('Z'):
            vk_code = ord(chr(key).lower())
            vwmods = 0
            for modifier in modifiers:
                vwmods |= self._bk.modifiers.get(modifier, 0)
            self._bk.keyEvent(1, vwmods, vk_code, 0)

        if text is not None:
            self._bk.textEvent(text)

    def on_size(self, instance, value):
        w, h = map(int, value)
        self._bk.resize(w, h)
        if not hasattr(self, '_g_rect'):
            return
        self._g_rect.texture = self._bk.texture
        self._g_rect.tex_coords = (0, 1, 1, 1, 1, 0, 0, 0)
        self._g_rect.size = w, h
        self._g_rect.pos = self.pos

    def on_pos(self, instance, value):
        x, y = map(int, value)
        if not hasattr(self, '_g_rect'):
            return
        self._g_rect.pos = self.pos

    def on_transparency(self, instance, value):
        self._bk.setTransparent(value)

    def _get_uid(self):
        return 'sv.%d' % id(self)

    def _change_touch_mode(self, dt):
        touches = self._touches
        len_touches = len(touches)
        uid = self._get_uid()
        if len_touches == 0:
            return
        elif len_touches == 1:
            # only one touch, do a click
            touch = touches[0]
            ud = touch.ud[uid]
            if ud.mode == 'unknown':
                # we can still do it.
                touch.ud[uid].mode = 'controlled'
                # dispatch this touch
                touch.push()
                touch.apply_transform_2d(self.to_widget)
                touch.apply_transform_2d(self.to_parent)
                self._mouse_move(touch)
                self._bk.mouseButton(0, 1)
                touch.pop()
            return
        else:
            # if only one touch is controlled, don't do anything.
            for touch in touches:
                ud = touch.ud[uid]
                if ud.mode == 'controlled':
                    return
            # not a single touch is controlled, good.
            # mark 2 of them as scrolled
            for touch in touches[:2]:
                touch.ud[uid].mode = 'scroll'
            return

    def on_touch_down(self, touch):
        if not self.collide_point(*touch.pos):
            return
        for child in self.children:
            if touch.x >= child.x and touch.x <= (child.x + child.width) and touch.y >= child.y and touch.y <= (child.y + child.height):
                child.on_touch_down( touch)
                return
        touch.grab(self)
        self.focus()
        uid = self._get_uid()
        touch.ud[uid] = QueryDict(mode='unknown')
        self._touches.append(touch)
        if self.scroll_timeout == 0:
            touch.ud[uid].mode = 'controlled'
            self._mouse_move(touch)
            self._bk.mouseButton(0, 1)
        else:
            Clock.schedule_once(self._change_touch_mode, self.scroll_timeout / 1000.)
        return True

    def on_touch_move(self, touch):
        if touch.grab_current is not self:
            return
        for child in self.children:
            if touch.x >= child.x and touch.x <= (child.x + child.width) and touch.y >= child.y and touch.y <= (child.y + child.height):
                child.on_touch_move(touch)
                return
        touches = self._touches
        len_touches = len(touches)
        uid = self._get_uid()
        if len_touches == 0:
            assert('this cannot happen?!!')
        elif len_touches == 1:
            touch = touches[0]
            ud = touch.ud[uid]
            if ud.mode == 'controlled':
                self._mouse_move(touch)
        else:
            # take only the first 2 touches
            touch1, touch2 = touches[:2]
            if touch1.ud[uid].mode != 'scroll':
                return
            if touch2.ud[uid].mode != 'scroll':
                return
            # calculate the initial position from the 2 touches
            touch1, touch2 = touches[:2]
            dx = touch2.dx / 2. + touch1.dx / 2.
            dy = touch2.dy / 2. + touch1.dy / 2.
            # do the scrolling on the page
            self._bk.mouseWheel(dx, -dy)
            # cancel the current dx/dy
            touch1.dx = touch1.dy = touch2.dx = touch2.dy = 0

        return True

    def on_touch_up(self, touch):
        for child in self.children:
            if touch.x >= child.x and touch.x <= (child.x + child.width) and touch.y >= child.y and touch.y <= (child.y + child.height):
                child.on_touch_up(touch)
                return
        if touch.grab_current is not self:
            return
        uid = self._get_uid()
        mode = touch.ud[uid].mode

        ignore = False
        for item in self._touches:
            if item is touch:
                continue
            if item.ud[uid].mode != 'unknown':
                ignore = True

        # if we must not ignore this touch...
        if ignore is False:
            # ok, we must not ignore it, so dispatch the first move down
            if mode == 'unknown':
                self._mouse_move(touch)
                self._bk.mouseButton(0, 1)
                mode = 'controlled'
            # dispatch the up
            if mode == 'controlled':
                self._mouse_move(touch)
                self._bk.mouseButton(0, 0)

        touch.ungrab(touch)
        self._touches.remove(touch)
        return True

    def _mouse_move(self, touch):
        x = touch.x - self.x
        y = self.height - (touch.y - self.y)
        self._bk.mouseMoved(x, y)

    #
    # Public methods
    #

    def open_filename(self, filename):
        '''Open a HTML from the disk (filename can be relative or absolute.)
        '''
        filename = realpath(filename)
        self.open_url('file://' + filename)

    def open_url(self, url):
        '''Open an URL (starting with http://)
        '''
        self.url = url
        try:
            self.bk.stop()
            self.bk.navigateTo(str(url))
        except Exception, e:
            print e

    def focus(self):
        '''Focus the window
        '''
        self._have_focus = 1
        self._bk.focus()

    def unfocus(self):
        '''Unfocus the window
        '''
        self._bk.unfocus()
        self._have_focus = 0

    def adjust_zoom(self, mode):
        '''Adjust zoom from mode
        '''
        self._bk.adjustZoom(mode)

    def refresh(self):
        '''Refresh the current page
        '''
        self._bk.refresh()

    def stop(self):
        '''Stop the loading of the page
        '''
        self._bk.stop()

    def cut(self):
        '''Cut the current selection
        '''
        self._bk.cut()

    def copy(self):
        '''Copy the current selection
        '''
        self._bk.copy()

    def paste(self):
        '''Paste the current selection
        '''
        self._bk.paste()

    def undo(self):
        '''Undo last action (in text input)
        '''
        self._bk.undo()

    def redo(self):
        '''Redo last action (in text input)
        '''
        self._bk.redo()

    def select_all(self):
        '''Select all the text
        '''
        self._bk.selectAll()

    def go_back(self):
        '''Go to the previous webpage in the history
        '''
        self._bk.goBack()

    def go_forward(self):
        '''Go to the next webpage in the history
        '''
        self._bk.goForward()

    def can_go_back(self):
        '''Return True if we can go back (if you can display the back button)
        '''
        return self._bk.canGoBack()

    def can_go_forward(self):
        '''Return True if we can go forward (if you can display the forward button)
        '''
        return self._bk.canGoForward()

    def execute_javascript(self, string):
        '''Pass some js code to be executed in the window
        '''
        return self._bk.executeJavascript(string)

    # default handlers
    def on_start_loading(self, url):
        pass

    def on_load(self):
        pass

    def on_crashed_worker(self):
        pass

    def on_crashed_plugin(self, plugin_name):
        pass

    def on_provisional_load_error(self, url, error_code, is_main):
        pass

    def on_console_message(self, message, source_id, line_no):
        self.last_console_message = (message, source_id, line_no)

    def on_script_alert(self, message, default_value, url, flags, success):
        pass

    def on_navigation_requested(self, url, referrer, is_new_window):
        if is_new_window:
            return False
        return True

    def on_created_window(self):
        pass

    def on_widget_created(self, _id):
        w = WebbrowserChildWidget()
        self.add_widget(w)
        w._id = _id

    def on_widget_destroyed(self, _id):
        for child in self.children:
            if child._id == _id:
                self.remove_widget(child)

    def on_widget_resize(self, _id, size):
        for child in self.children:
            if child._id == _id:
                child.size = size

    def on_widget_move(self, _id, pos):
        for child in self.children:
            if child._id == _id:
                child.pos = pos
                child.y = self.height - (child.y + child.height)

    def on_widget_paint(self, _id, texture):
        for child in self.children:
            if child._id == _id:
                child.on_widget_paint(texture)

    def on_paint(self):
        self.canvas.ask_update()


class WebbrowserChildWidget(Widget):
    '''WebbrowserWidget class. See module documentation for more information.

    :Events:

         `on_widget_paint`:
            Fired when the Widget texture is updated
    '''

    #
    # Privates
    #

    def __init__(self, **kwargs):

        # Before doing anything, ensure the windows exist.
        EventLoop.ensure_window()
        EventLoop.window.bind(on_keyboard=self.on_widget_keyboard)
        super(WebbrowserChildWidget, self).__init__(**kwargs)
        self._id = 0

    def on_widget_keyboard(self, instance, key, scancode, text, modifiers):
        # handle first special keys
        if key in map(ord, ('\b', '\r', '\n', ' ')) or \
            ord('a') >= key <= ord('z') or \
            ord('A') >= key <= ord('Z'):
            vk_code = ord(chr(key).lower())
            vwmods = 0
            for modifier in modifiers:
                vwmods |= self.parent._bk.modifiers.get(modifier, 0)
            self.parent._bk.widget_keyEvent(self._id, 1, vwmods, vk_code, 0)

        if text is not None:
            self.parent._bk.widget_textEvent(self._id, text)

    def on_touch_down(self, touch):
        self.focus()
        self._mouse_move(touch)
        self.parent._bk.widget_mouseButton(self._id, 0, 1)

    def on_touch_move(self, touch):
        self._mouse_move(touch)

    def on_touch_up(self, touch):
        self._mouse_move(touch)
        self.parent._bk.widget_mouseButton(self._id, 0, 0)

    def _mouse_move(self, touch):
        x = touch.x - self.x
        y = self.height - (touch.y - self.y)
        self.parent._bk.widget_mouseMoved(self._id, x, y)

    #
    # Public methods
    #

    def focus(self):
        '''Focus the window
        '''
        self._have_focus = 1
        self.parent._bk.widget_focus(self._id)

    def unfocus(self):
        '''Unfocus the window
        '''
        self.parent._bk.widget_unfocus(self._id)
        self._have_focus = 0

    def on_widget_paint(self, texture):
        with self.canvas:
            self._g_color = Color(1, 1, 1)
            self._g_rect = Rectangle(texture = texture, size=self.size, pos = self.pos)
            self._g_rect.tex_coords = (0, 1, 1, 1, 1, 0, 0, 0)
        self.canvas.ask_update()


Factory.register('Webbrowser', cls=Webbrowser)


if __name__ == '__main__':

    from kivy.app import App
    class WebbrowserApp(App):
        def build(self):
            wb = Webbrowser(size_hint=(None, None), size=(300, 64),
                            transparency=True)
            with open('bleh.html', 'w') as fd:
                fd.write('<h1><span style="color: #ff0000">Hello</span>'
                         '<span style="color: #00ff00">World</span></h1>')
            wb.open_filename('bleh.html')
            return wb

    WebbrowserApp().run()
