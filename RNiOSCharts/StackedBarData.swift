
import Foundation

class StackedBarData{
  
  var stackedBarData:[Double] = [];
  var stackedBarColors:[UIColor] = [];
  var stackedBarLabels:[String] = [];
  var drawValues:Bool;
  var valueTextFontSize:Int = 0;
  var valueTextColor:UIColor;
  
  init(){
    stackedBarData = [];
    stackedBarColors = [];
    stackedBarLabels = [];
    drawValues = false;
    valueTextFontSize = 8;
    valueTextColor = UIColor.blackColor();
  }
}