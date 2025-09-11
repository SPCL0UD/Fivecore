local stretcherModel = `prop_ld_binbag_01`
local stretcher = nil
local carrying = false

RegisterCommand('ems_camilla', function()
  if DoesEntityExist(stretcher) then DeleteObject(stretcher) stretcher=nil return end
  RequestModel(stretcherModel)
  while not HasModelLoaded(stretcherModel) do Wait(0) end
  local p = PlayerPedId()
  local pos = GetOffsetFromEntityInWorldCoords(p, 0.0, 1.0, 0.0)
  stretcher = CreateObject(stretcherModel, pos.x, pos.y, pos.z, true, true, false)
  PlaceObjectOnGroundProperly(stretcher)
end)

RegisterCommand('ems_emp', function()
  if not DoesEntityExist(stretcher) then return end
  local p = PlayerPedId()
  AttachEntityToEntity(stretcher, p, GetPedBoneIndex(p, 28422), 0.0, 1.0, -0.5, 0.0, 0.0, 0.0, true, true, false, true, 1, true)
  carrying = true
end)

CreateThread(function()
  while true do
    Wait(0)
    if carrying and IsControlJustPressed(0, 38) then
      carrying = false
      DetachEntity(stretcher, true, true)
      PlaceObjectOnGroundProperly(stretcher)
    end
  end
end)
-- Borrar camilla al morir
RegisterNetEvent('baseevents:onPlayerWasted', function()
  if DoesEntityExist(stretcher) then
    DeleteObject(stretcher)
    stretcher = nil
    carrying = false
  end
end)