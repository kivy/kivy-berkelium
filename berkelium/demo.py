from kivy.app import App
from . import Webbrowser

class BerkeliumBrowserApp(App):
    def build(self):
        return Webbrowser(url='http://kivy.org/', transparency=False)

if __name__ == '__main__':
    BerkeliumBrowserApp().run()
