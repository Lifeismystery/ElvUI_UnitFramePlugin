local E, L, V, P, G, _  = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UFP = E:NewModule('UnitFramePlugin', 'AceHook-3.0', 'AceEvent-3.0', 'AceTimer-3.0');
local UF = E:GetModule('UnitFrames');
--local NP = E:GetModule("NamePlates");
local EP = LibStub("LibElvUIPlugin-1.0") --We can use this to automatically insert our GUI tables when ElvUI_Config is loaded.
local addon, ns = ...

local format = string.format
local _G = _G
UFP.version = GetAddOnMetadata("ElvUI_UnitFramePlugin", "Version")
UFP.versionMinE = 10.49
UFP.title = '|cff1783d1UnitFramePlugin|r'

--Default options
P['UFP'] = {
	['enable'] = true,
	['unitframes'] = {
		['health'] = {
			['texture'] = {
				['use_texture'] = false,
				['use_Backdrope_texture'] = false,
				['texture'] = "ElvUI Norm",
				['backdrope_texture'] = "ElvUI Norm",
			},
			['colors'] = {
				['transparent_statusbar'] = 1.0,
				['transparent_backdrope'] = 1.0,
				['invert_colors'] = false,
			},
		},
		['power'] = {
			['texture'] = {
				['use_texture'] = false,
				['use_Backdrope_texture'] = false,
				['texture'] = "ElvUI Norm",
				['backdrope_texture'] = "ElvUI Norm",
			},
			['colors'] = {
				['transparent_statusbar'] = 1.0,
				['transparent_backdrope'] = 1.0,
				['invert_colors'] = false,
				["backdropcolor"] = {r = 0.07,g = 0.07,b = 0.07},
			},
		},
	},
}

function UFP:InsertOptions()

    E.Options.args.UFP = {
		order = 100,
		type = 'group',
		name = UFP.title,
		args = {
			header = {
				order = 1,
				type = "header",
				name = format(L["%s version %s by Lifeismystery"], UFP.title, UFP.version),
			},		
			enable = {
				order = 2,
				type = "toggle",
				name = L["Enable"],
				get = function(info) return E.db.UFP.enable end,
				set = function(info, value) E.db.UFP.enable = value; E:StaticPopup_Show("PRIVATE_RL") end
			},
			unitframes = {
				order = 3,
				type = 'group',
				name = L['UnitFrames'],
				guiInline = true,
				disabled = function() return not E.db.UFP.enable end,
				get = function(info) return E.db.UFP.unitframes[ info[#info] ] end,
				set = function(info, value) E.db.UFP.unitframes[ info[#info] ] = value end,
				args = {
					health = {
						order = 4,
						type = 'group',
						guiInline = true,
						name = HEALTH,
						args = {
							texture = {
								order = 5,
								type = 'group',
								guiInline = true,
								name = L["Bars"],
								get = function(info) return E.db.UFP.unitframes.health.texture[ info[#info] ] end,
								set = function(info, value) E.db.UFP.unitframes.health.texture[ info[#info] ] = value; UF:Update_AllFrames() end,
								args = {
									use_texture = {
										order = 6,
										type = 'toggle',
										name = L["Use texture"],
									},
									texture = {
										type = "select", dialogControl = 'LSM30_Statusbar',
										order = 7,
										name = L["StatusBar Texture"],
										values = AceGUIWidgetLSMlists.statusbar,
										disabled = function() return not E.db.UFP.unitframes.health.texture.use_texture end,
										--set = function(info, value) E.db.UFP.unitframes.health.texture[ info[#info] ] = value; UF:Update_StatusBars() end,
									},
									spacer = {
										order = 8,
										type = "description",
										name = "",
									},
									use_Backdrope_texture = {
										order = 9,
										type = 'toggle',
										name = L["Use backprope texture"],
									},
									backdrope_texture = {
										type = "select", dialogControl = 'LSM30_Statusbar',
										order = 10,
										name = L["Backdrope Texture"],
										values = AceGUIWidgetLSMlists.statusbar,
										disabled = function() return not E.db.UFP.unitframes.health.texture.use_Backdrope_texture end,
									},
								},	
							},
							colors = {
								order = 11,
								type = 'group',
								guiInline = true,
								name = L["Colors"],
								get = function(info) return E.db.UFP.unitframes.health.colors[ info[#info] ] end,
								set = function(info, value) E.db.UFP.unitframes.health.colors[ info[#info] ] = value; UF:Update_AllFrames() end,
								args = {
									transparent_statusbar = {
										order = 12,
										type = 'range',
										name = L["Transparent StatusBar"],
										min = 0, max = 1, step = 0.01,
									},
									transparent_backdrope = {
										order = 13,
										type = 'range',
										name = L["Transparent Backdrope"],
										min = 0, max = 1, step = 0.01,
									},
									invert_colors = {
										order = 14,
										type = 'toggle',
										name = L["Invert colors"],
									},
								},	
							},
						},
					},
					power = {
						order = 15,
						type = 'group',
						guiInline = true,
						name = L["Powers"],
						args = {
							texture = {
								order = 16,
								type = 'group',
								guiInline = true,
								name = L["Bars"],
								get = function(info) return E.db.UFP.unitframes.power.texture[ info[#info] ] end,
								set = function(info, value) E.db.UFP.unitframes.power.texture[ info[#info] ] = value; UF:Update_AllFrames() end,
								args = {
									use_texture = {
										order = 17,
										type = 'toggle',
										name = L["Use texture"],
									},
									texture = {
										type = "select", dialogControl = 'LSM30_Statusbar',
										order = 18,
										name = L["StatusBar Texture"],
										values = AceGUIWidgetLSMlists.statusbar,
										disabled = function() return not E.db.UFP.unitframes.power.texture.use_texture end,
									},
									spacer = {
										order = 19,
										type = "description",
										name = "",
									},
									use_Backdrope_texture = {
										order = 20,
										type = 'toggle',
										name = L["Use backprope texture"],
									},
									backdrope_texture = {
										type = "select", dialogControl = 'LSM30_Statusbar',
										order = 21,
										name = L["Backdrope Texture"],
										values = AceGUIWidgetLSMlists.statusbar,
										disabled = function() return not E.db.UFP.unitframes.power.texture.use_Backdrope_texture end,
									},
								},	
							},
							colors = {
								order = 22,
								type = 'group',
								guiInline = true,
								name = L["Colors"],
								get = function(info) return E.db.UFP.unitframes.power.colors[ info[#info] ] end,
								set = function(info, value) E.db.UFP.unitframes.power.colors[ info[#info] ] = value; UF:Update_AllFrames() end,
								args = {
									transparent_statusbar = {
										order = 22,
										type = 'range',
										name = L["Transparent StatusBar"],
										min = 0, max = 1, step = 0.01,
									},
									transparent_backdrope = {
										order = 23,
										type = 'range',
										name = L["Transparent Backdrope"],
										min = 0, max = 1, step = 0.01,
									},
									invert_colors = {
										order = 24,
										type = 'toggle',
										name = L["Invert colors"],
									},
									backdropcolor = {
										order = 25,
										type = 'color',
										name = L["Backdrop color"],
										hasAlpha = false,
										get = function(info)
											local t = E.db.UFP.unitframes.power.colors.backdropcolor
											local d = P.UFP.unitframes.power.colors.backdropcolor
											return t.r, t.g, t.b, t.a, d.r, d.g, d.b
										end,
										set = function(info, r, g, b)
											E.db.UFP.unitframes.power.colors.backdropcolor = {}
											local t = E.db.UFP.unitframes.power.colors.backdropcolor
											t.r, t.g, t.b = r, g, b
										end,
									},
								},	
							},
						},
					},
				},
			},
		}
	}	

	--E.Options.args.unitframe.args.general.args.barGroup.args.statusbar.disabled = function() return E.db.UFP.enable end
	E.Options.args.unitframe.args.general.args.allColorsGroup.args.healthGroup.args.transparentHealth.disabled = function() return E.db.UFP.enable end
	E.Options.args.unitframe.args.general.args.allColorsGroup.args.powerGroup.args.transparentPower.disabled = function() return E.db.UFP.enable end
end

function UFP:Initialize()
	--if not UFP.initialized or not E.private.unitframe.enable then return end
	--Register plugin so options are properly inserted when config is loaded
	EP:RegisterPlugin(addon, UFP.InsertOptions)
end

E:RegisterModule(UFP:GetName()) --Register the module with ElvUI. ElvUI will now call UFP:Initialize() when ElvUI is ready to load our plugin.