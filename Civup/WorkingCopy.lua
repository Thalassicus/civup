
	for k, v in ipairs(Deals) do
		for k2, d in ipairs(v.Items) do
			local dealInfo		= DealTypes[d.itemID]
			local priority		= 99
			local iconString	= string.format("[%s]", d.itemID)
			local help			= iconString
			
			if dealInfo and GameInfo.Deals[dealInfo] then
				dealInfo		= GameInfo.Deals[dealInfo]
				priority		= dealInfo.Priority
				iconString		= dealInfo.IconString
				help			= dealInfo.Help
			end
			
			if d.itemID == TradeableItems.TRADE_ITEM_RESOURCES then
				iconString = d.data2 .. GameInfo.Resources[d.data1].IconString
				help = iconString .. " " .. Locale.ConvertTextKey(GameInfo.Resources[d.data1].Description)
			elseif d.itemID == TradeableItems.TRADE_ITEM_CITIES then
				local plot = pPlotMap.GetPlot( d.data1, d.data2 )
				if plot and plot:GetPlotCity() then
					iconString = string.format("City(%s)", plot:GetPlotCity():GetName())
					help = iconString
				end
				d.data1, d.data2 = nil, nil
			end
			
			if d.duration and d.duration > 0 then
				iconString	= string.format("%s(%s)", iconString, d.duration)
				help		= string.format("%s(%s)", iconString, d.duration)
			end
			if d.data1 and d.data1 ~= 0 then
				iconString	= string.format("%s 1[%s]", iconString, d.data1)
				help		= string.format("%s 1[%s]", iconString, d.data1)
			end
			if d.data2 and d.data2 ~= 0  then
				iconString	= string.format("%s 2[%s]", iconString, d.data2)
				help		= string.format("%s 2[%s]", iconString, d.data2)
			end
			
			Deals[k].items[k2].priority		= priority
			Deals[k].items[k2].iconString	= iconString
			Deals[k].items[k2].help			= help
			
			if Deals[k].items[k2].data1 == nil then
				Deals[k].items[k2].data1 = ""
			end
		end
	end