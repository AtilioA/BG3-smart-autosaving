-- TODO: make version number dynamic
print("Smart Autosaving: version 2.1.0 loaded")

local EventSubscription = Ext.Require("Server/subscribed_events.lua")

EventSubscription.SubscribeToEvents()
