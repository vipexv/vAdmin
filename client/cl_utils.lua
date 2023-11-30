---@param action string The action you wish to target
---@param data any The data you wish to send along with this action
function UIMessage(action, data)
  SendNUIMessage({
    action = action,
    data = data
  })

  Debug(("(Debug) [vadmin:shared:uimessage] \n Action: %s \n Data: %s"):format(json.encode(action), json.encode(data)))
end

---@param shouldShow boolean
toggleNuiFrame = function(shouldShow)
  SetNuiFocus(shouldShow, shouldShow)
  UIMessage('setVisible', shouldShow)
end
