function adjustLineWidth(objH, evtData, intHandles)

set(objH, 'LineWidth', 4)
set(intHandles(intHandles~=objH), 'LineWidth', 1)
end