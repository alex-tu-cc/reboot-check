#!/usr/bin/python
# -*- coding: utf-8 -*-
from gi.repository import Unity, Gio, GObject, GLib, Dbusmenu
import os

def on_root_changed(client, data):
    f= open('/home/u/.cache/dbus-menu-nmapplet.log','w');
#    print("Client root",client.get_root())
#    print("Client root children",client.get_root().get_children())

    for child in client.get_root().get_children():
#        print("  child properties {}".format(child.properties_list()))

        for prop in child.properties_list():
            print("    {}: {}".format(prop, child.property_get(prop)))
            f.write("    {}: {}\n".format(prop, child.property_get(prop)))
    f.close() 

indicators = Gio.bus_get_sync(Gio.BusType.SESSION).call_sync('com.canonical.indicator.application', '/com/canonical/indicator/application/service', 'com.canonical.indicator.application.service', 'GetApplications', None, None, Gio.DBusCallFlags.NONE, -1, None)
[(menuname, menupath)] = [(i[2], i[3]) for i in indicators[0] if i[8] == 'nm-applet']

print("Dbusmenu.Client.new({}, {})".format(menuname, menupath))
client=Dbusmenu.Client.new(menuname, menupath);
client.get_status();

client.connect('root-changed', on_root_changed)
GLib.MainLoop().run()
