---@diagnostic disable-next-line: undefined-global
local modules = LibStub( "RollFor-Modules" )
if modules.MasterLootWarning then return end

local M                    = {}
local red                  = modules.colors.red
local blue                 = modules.colors.blue
local grey                 = modules.colors.grey
local table_contains_value = modules.table_contains_value

---@diagnostic disable-next-line: undefined-global
local UIParent             = UIParent

local zones                = {
  [ "Orgrimmar" ] = {
    "Kaja",
    "Fara Boltbreaker"
  },
  [ "Karazhan" ] = {
    "Master Blacksmith Rolfen",
    "Brood Queen Araxxna",
    "Grizikil",
    "Clawlord Howlfang",
    "Lord Blackwald II",
    "Moroes"
  },
  [ "Zul'Gurub" ] = {
    "High Priestess Jeklik",
    "High Priest Venoxis",
    "High Priestess Mar'li",
    "Broodlord Mandokir",
    "Ohgan",
    "Gri'lek",
    "Hazza'rah",
    "Renataki",
    "Wushoolay",
    "Gahz'ranka",
    "High Priest Thekal",
    "Zealot Zath",
    "Zealot Lor'Khan",
    "High Priestess Arlokk",
    "Jin'do the Hexxer",
    "Hakkar"
  },
  [ "Ruins of Ahn'Qiraj" ] = {
    "Kurinaxx",
    "General Rajaxx",
    "Moam",
    "Buru the Gorger",
    "Ayamiss the Hunter",
    "Ossirian the Unscarred"
  },
  [ "Molten Core" ] = {
    "Lucifron",
    "Magmadar",
    "Gehennas",
    "Garr",
    "Shazzrah",
    "Baron Geddon",
    "Golemagg the Incinerator",
    "Sulfuron Harbinger",
    "Majordomo Executus",
    "Ragnaros"
  },
  [ "Blackwing Lair" ] = {
    "Razorgore the Untamed",
    "Vaelastrasz the Corrupt",
    "Broodlord Lashlayer",
    "Firemaw",
    "Ebonroc",
    "Flamegor",
    "Chromaggus",
    "Nefarian"
  },
  [ "Onyxia's Lair" ] = {
    "Onyxia"
  },
  [ "Temple of Ahn'Qiraj" ] = {
    "The Prophet Skeram",
    "Vem",
    "Lord Kri",
    "Princess Yauj",
    "Battle Guard Sartura",
    "Fankriss the Unyielding",
    "Viscidus",
    "Princess Huhuran",
    "Emperor Vek'lor",
    "Emperor Vek'nilash",
    "Ouro",
    "C'Thun"
  },
  [ "Naxxramas" ] = {
    "Patchwerk",
    "Grobbulus",
    "Gluth",
    "Thaddius",
    "Anub'Rekhan",
    "Grand Widow Faerlina",
    "Maexxna",
    "Noth the Plaguebringer",
    "Heigan the Unclean",
    "Loatheb",
    "Instructor Razuvious",
    "Gothik the Harvester",
    "Thane Korth'azz",
    "Lady Blaumeux",
    "Highlord Mograine",
    "Sir Zeliek",
    "Sapphiron",
    "Kel'Thuzad"
  }
}

local function create_frame( api )
  local frame = api().CreateFrame( "FRAME", "RollForMasterLootWarning", UIParent )
  frame:Hide()

  local label = frame:CreateFontString( nil, "OVERLAY" )
  label:SetFont( "FONTS\\FRIZQT__.TTF", 24, "OUTLINE" )
  label:SetPoint( "CENTER", 0, 0 )
  label:SetText( string.format( "No %s!", red( "Master Loot" ) ) )

  local label2 = frame:CreateFontString( nil, "OVERLAY" )
  label2:SetFont( "FONTS\\FRIZQT__.TTF", 16, "OUTLINE" )
  label2:SetPoint( "CENTER", 0, -20 )
  label2:SetText( string.format( "Enable %s or type %s to disable this message.", grey("Master Loot"), blue( "/rf ml" ) ) )

  frame:SetWidth( label:GetWidth() )
  frame:SetHeight( label:GetHeight() )
  frame:SetPoint( "CENTER", UIParent, "CENTER", 0, 140 )

  return frame
end

function M.new( api, db )
  local frame
  local is_visible = false

  local function show()
    if not frame or is_visible or db.char.disable_ml_warning then return end

    api().UIFrameFadeRemoveFrame( frame )
    frame:SetAlpha( 1 )
    frame:Show()
    is_visible = true
    frame.fading_out = nil
  end

  local function hide()
    if not frame or frame.fading_out or not frame:IsVisible() then return end

    frame.fading_out = true
    is_visible = false
    api().UIFrameFadeOut( frame, 2, 1, 0 )
    frame.fadeInfo.finishedFunc = function()
      frame.fading_out = nil
      frame:Hide()
    end
  end

  local function toggle()
    if not modules.is_player_master_looter() and not modules.is_player_a_leader() then
      if is_visible then hide() end
      return
    end

    local master_loot = modules.is_master_loot()
    local zone_name = api().GetRealZoneText()
    local target_name = api().UnitName( "target" )
    local zone = zones[ zone_name ]
    local dead = api().UnitIsDead("target")

    if not zone or master_loot or not table_contains_value( zone, target_name ) or dead then
      if is_visible then hide() end
      return
    end

    if not frame then frame = create_frame( api ) end
    show()
  end

  return {
    on_player_target_changed = toggle,
    on_party_loot_method_changed = toggle,
    hide = hide
  }
end

modules.MasterLootWarning = M
return M
