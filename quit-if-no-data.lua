local timeout = 10

-- A timer that will quit mpv if it's not killed first.
local quit_timer = mp.add_timeout(timeout, function()
  print("No data received for " .. timeout .. " seconds, qutting.")
  mp.command("quit")
end)

local function on_property_change(name, value)
  if value and value["reader-pts"] then
    print("Data received, cancelling quit timer.")
    quit_timer:kill()
    mp.unobserve_property(on_property_change)
  end
end

mp.observe_property("demuxer-cache-state", "native", on_property_change)

