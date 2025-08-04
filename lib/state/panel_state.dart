import '../model/panel_model.dart';

class PanelState {
  PanelState._();

  static List<Panel> leftPanels = Panel.values;
  static Panel leftPanel = Panel.content;
  static bool showLeft = true;
  static bool expandLeft = false;
  static void setLeftPanel(int index) {
    if (showLeft && leftPanels[index] == leftPanel) {
      showLeft = false;
    } else {
      showLeft = true;
      leftPanel = leftPanels[index];
    }
  }

  static bool showRight = true;
  static bool showBottom = true;
}
