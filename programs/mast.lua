-- mast.lua
-- Copyleft daysant 2024 - OCNet
-- This file is licensed under the terms of the Affero GPL v3.0-or-later.

-- This is the program that runs in each mast.
--
-- A mast should have two relays, one pointing to the region it serves, and
-- one that links to the network centre.
--
-- The mast relays all messages between computers inside its served region and
-- all computers outside the region. Multiple masts serving one region will
-- eventually be added to OCNet.
--
-- Refer to the protocol document for more information.

local component = require("component")
local event = require("event")
local serialization = require("serialization")

local modem = component.modem

for i = 1, 65536 do -- open every port
    modem.open(i)

while true:
    local _, _, from, port, _, message = event.pull("modem_message")

    packet = serialization.unseralize(message)

    if packet[1] != '.ocnp.' then
        ack = serialization.serialize(['.ocnp.ack.....',false])
        modem.send(from,port,)