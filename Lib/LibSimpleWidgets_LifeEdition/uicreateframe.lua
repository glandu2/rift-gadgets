local frameConstructors = {
  SimpleLifeCheckbox    = Library.LibSimpleWidgets.Checkbox, --SimpleLife
  SimpleLifeGrid        = Library.LibSimpleWidgets.Grid,
  SimpleLifeList        = Library.LibSimpleWidgets.List,
  SimpleLifeRadioButton = Library.LibSimpleWidgets.RadioButton,
  SimpleLifeScrollList  = Library.LibSimpleWidgets.ScrollList,
  SimpleLifeScrollView  = Library.LibSimpleWidgets.ScrollView,
  SimpleLifeSelect      = Library.LibSimpleWidgets.Select,
  SimpleLifeSlider      = Library.LibSimpleWidgets.Slider,
  SimpleLifeTabView     = Library.LibSimpleWidgets.TabView,
  SimpleLifeTextArea    = Library.LibSimpleWidgets.TextArea,
  SimpleLifeTooltip     = Library.LibSimpleWidgets.Tooltip,
  SimpleLifeWindow      = Library.LibSimpleWidgets.Window,
  SimpleLifeLifeWindow  = Library.LibSimpleWidgets.LifeWindow,
}

local oldUICreateFrame = UI.CreateFrame
UI.CreateFrame = function(frameType, name, parent)
  assert(type(frameType) == "string", "param 1 must be a string!")
  assert(type(name) == "string", "param 2 must be a string!")
  assert(type(parent) == "table", "param 3 must be a valid frame parent!")

  local constructor = frameConstructors[frameType]
  if constructor then
    return constructor(name, parent)
  else
    return oldUICreateFrame(frameType, name, parent)
  end
end
