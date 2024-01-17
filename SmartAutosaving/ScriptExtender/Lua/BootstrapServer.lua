-- TODO: make version number dynamic
print("Smart Autosaving: version 1.0.1 loaded")

local EventSubscription = Ext.Require("Server/subscribed_events.lua")

EventSubscription.SubscribeToEvents()
