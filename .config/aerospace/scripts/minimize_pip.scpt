tell application "System Events"
    -- Get the application process for PiP
    set appProcess to first application process whose name is "PiP"

    -- Check if the app is visible (not minimized or hidden)
    set isVisible to visible of appProcess

    -- Toggle visibility
    if isVisible then
        set visible of appProcess to false -- Hides the app
    else
        set visible of appProcess to true -- Shows the app
    end if
end tell
