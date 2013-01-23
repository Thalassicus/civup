notificationOptionsContext = ContextPtr:LoadNewContext("NotificationOptions") 

LuaEvents.DiploCornerAddin({ text="Notification Options", tip="Opens a window that allows you to choose which notifications you would like to receive.", call=function() 
		UIManager:QueuePopup( notificationOptionsContext, PopupPriority.BarbarianCamp ); 
	end})