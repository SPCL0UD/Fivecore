local bodycamProp = nil
local bodycamModel = `prop_bodycam_01` -- Usa un modelo válido o personalizado

CreateThread(function()
  while true do
    Wait(5000)
    local hasBodycam = exports['fivecore']:hasItem('bodycam')
    if hasBodycam and not DoesEntityExist(bodycamProp) then
      attachBodycam()
    elseif not hasBodycam and DoesEntityExist(bodycamProp) then
      detachBodycam()
    end
  end
end)

function attachBodycam()
  local ped = PlayerPedId()
  RequestModel(bodycamModel)
  while not HasModelLoaded(bodycamModel) do Wait(0) end
  bodycamProp = CreateObject(bodycamModel, 0.0, 0.0, 0.0, true, true, false)
  AttachEntityToEntity(bodycamProp, ped, GetPedBoneIndex(ped, 24818), 0.05, 0.02, 0.0, 0.0, 0.0, 0.0, true, true, false, true, 1, true)
end

function detachBodycam()
  DeleteEntity(bodycamProp)
  bodycamProp = nil
end
--- a/file:///g%3A/Fivecore/five-core/server/functions.lua
+++ b/file:///g%3A/Fivecore/five-core/server/functions.lua
@@ -13,6 +13,7 @@ function FiveCore:hasItem(itemName)
   local item = self.items[itemName]
   if not item then return false end
   local count = item.count
+  local hasItem = false
   if count > 0 then
     count = count - 1
     self.items[itemName].count = count
@@ -23,6 +24,10 @@ function FiveCore:hasItem(itemName)
     return true
   end
   return false
+  --return self.items[itemName].count > 0
+  if self.items[itemName] and self.items[itemName].count > 0 then
+    hasItem = true -- El jugador tiene el ítem
+  end
 end
 
 function FiveCore:addItem(itemName, count)
    if count < 1 then return false end
    local item = self.items[itemName]
    if not item then
        self.items[itemName] = { name = itemName, count = count }
    else
        item.count = item.count + count
    end
    self:save()
    return true
end