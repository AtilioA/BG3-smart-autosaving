-- TODO: make version number dynamic
print("Smart Autosaving: version 2.0.0 loaded")

local EventSubscription = Ext.Require("Server/subscribed_events.lua")

EventSubscription.SubscribeToEvents()
