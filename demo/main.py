'''
Berkelium extension demo
========================

Check http://github.com/kivy/kivy-berkelium for more information.
You must have berkelium-1.2 extension installed before running the demo

'''
from kivy.uix.scatter import Scatter
from kivy.uix.floatlayout import FloatLayout
from kivy.app import App

from kivy.ext import load
berkelium = load('berkelium', (1, 2))

urls = (
    'http://kivy.org',
    'http://www.youtube.com/watch?v=QKh1Rv0PlOQ',
)

class BerkeliumBrowserApp(App):
    def build(self):
        root = FloatLayout()
        size = (1024, 768)
        for url in urls:
            scatter = Scatter(size=size)
            bk = berkelium.Webbrowser(url=url, size=size)
            scatter.add_widget(bk)
            root.add_widget(scatter)
        return root

if __name__ == '__main__':
    BerkeliumBrowserApp().run()
