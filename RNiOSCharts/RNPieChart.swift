//
//  RNPieChart.swift
//  PoliRank
//
//  Created by Jose Padilla on 2/8/16.
//  Copyright © 2016 Facebook. All rights reserved.
//

import Charts
import SwiftyJSON

@objc(RNPieChart)
class RNPieChart : PieChartView {
  
  override init(frame: CGRect) {
    super.init(frame: frame);
    self.frame = frame;
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented");
  }
  
  func setConfig(_ config: String!) {
    setPieRadarChartViewBaseProps(config);
    
    var maximumDecimalPlaces: Int = 0;
    var minimumDecimalPlaces: Int = 0;
    var labels: [String] = [];
    
    var json: JSON = nil;
    if let data = config.data(using: String.Encoding.utf8) {
      json = JSON(data: data);
    };

    self.holeColor = UIColor.clear;
//    if json["holeColor"].exists() {
//      self.holeColor = RCTConvert.UIColor(json["holeColor"].intValue);
//    }
    
    if json["drawHoleEnabled"].exists() {
      self.drawHoleEnabled = json["drawHoleEnabled"].boolValue;
    }

    if json["centerText"].exists() {
      let paraStyle = NSMutableParagraphStyle();
      paraStyle.alignment = NSTextAlignment.center;//居中属性
      
      let centerTextSets = json["centerText"].arrayObject;
      let centerText = NSMutableAttributedString.init();
      for set in centerTextSets!{
        let tmp = JSON(set);
        let tempText = tmp["text"].stringValue;
        let color = tmp["color"].stringValue;
        let size = tmp["size"].intValue;
        let isWrap = tmp["isWrap"].boolValue;
        
        
        if(isWrap){//换行
          centerText.append(NSAttributedString.init(string: "\n"));
        }
        
        //文字
        let tempTextWithAttrib  = NSAttributedString.init(string: tempText,
                                                          attributes: [
                                                            NSParagraphStyleAttributeName: paraStyle,
                                                            NSForegroundColorAttributeName: UIColor(color).cgColor,
                                                            NSFontAttributeName: UIFont.systemFont(ofSize: CGFloat(size) / CGFloat(3.1753))
                                                          ]);
        centerText.append(tempTextWithAttrib);
      }
      
      self.centerAttributedText = centerText;
    }
    
    

    if json["drawCenterTextEnabled"].exists() {
      self.drawCenterTextEnabled = json["drawCenterTextEnabled"].boolValue;
    }
    
    if json["holeRadius"].exists() {
      self.holeRadiusPercent = CGFloat(json["holeRadius"].floatValue / 100.0);
      if json["holeRadius"].floatValue == 0 {
        self.transparentCircleRadiusPercent = 0;
      }else{
        self.transparentCircleRadiusPercent = self.holeRadiusPercent + 0.05;
      }
    }
    
    if json["holeRadiusPercent"].exists() {
      self.holeRadiusPercent = CGFloat(json["holeRadiusPercent"].floatValue);
    }
    
    if json["transparentCircleRadiusPercent"].exists() {
      self.transparentCircleRadiusPercent = CGFloat(json["transparentCircleRadiusPercent"].floatValue);
    }
    
    if json["hasHoleFrame"].exists() {
      if !json["hasHoleFrame"].boolValue {
        self.transparentCircleRadiusPercent = self.holeRadiusPercent;
      }
    }
    
    if json["drawSliceTextEnabled"].exists() {
      self.drawSliceTextEnabled = json["drawSliceTextEnabled"].boolValue;
    }
    
    if json["usePercentValuesEnabled"].exists() {
      self.usePercentValuesEnabled = json["usePercentValuesEnabled"].boolValue;
    }
    
    if json["centerTextRadiusPercent"].exists() {
      self.centerTextRadiusPercent = CGFloat(json["centerTextRadiusPercent"].floatValue);
    }
    
    if json["maxAngle"].exists() {
      self.maxAngle = CGFloat(json["maxAngle"].floatValue);
    }
    
    if json["labels"].exists() {
      labels = json["labels"].arrayObject as! [String];
    }
    
    if json["dataSets"].exists() {
      let dataSets = json["dataSets"].arrayObject;
      
      var sets: [PieChartDataSet] = [];
      
      for set in dataSets! {
        let tmp = JSON(set);
        if tmp["values"].exists() {
          let values = tmp["values"].arrayObject as! [Double];
          let label = tmp["label"].exists() ? tmp["label"].stringValue : "";
          var dataEntries: [ChartDataEntry] = [];
          
          for i in 0..<values.count {
            let dataEntry = ChartDataEntry(value: values[i], xIndex: i);
            dataEntries.append(dataEntry);
          }
          
          let dataSet = PieChartDataSet(yVals: dataEntries, label: label);
          
          if tmp["sliceSpace"].exists() {
            dataSet.sliceSpace = CGFloat(tmp["sliceSpace"].floatValue);
          }
          
          if tmp["selectionShift"].exists() {
            dataSet.selectionShift = CGFloat(tmp["selectionShift"].floatValue);
          }
          
          if tmp["selected"].exists(){//高亮选中
              var hightlightedList: [ChartHighlight] = [];
              let selectedArray = tmp["selected"].arrayObject as! [Int];
              for j in 0..<selectedArray.count{
                  hightlightedList.append(ChartHighlight.init(xIndex: selectedArray[j], dataSetIndex: 0));
              }
              self.highlightValues(hightlightedList);
          }
          
          if tmp["colors"].exists() {
            let arrColors = tmp["colors"].arrayObject as! [Int];
            dataSet.colors = arrColors.map({return RCTConvert.uiColor($0)});
          }
          
          if tmp["drawValues"].exists() {
            dataSet.drawValuesEnabled = tmp["drawValues"].boolValue;
          }
          
          if tmp["highlightEnabled"].exists() {
            dataSet.highlightEnabled = tmp["highlightEnabled"].boolValue;
          }
          
          if tmp["valueTextFontName"].exists() {
            dataSet.valueFont = UIFont(
              name: tmp["valueTextFontName"].stringValue,
              size: dataSet.valueFont.pointSize
              )!;
          }
          
          if tmp["valueTextFontSize"].exists() {
            dataSet.valueFont = dataSet.valueFont.withSize(CGFloat(tmp["valueTextFontSize"].floatValue))
          }
          
          if tmp["valueTextColor"].exists() {
            dataSet.valueTextColor = RCTConvert.uiColor(tmp["valueTextColor"].intValue);
          }
          
          if tmp["isShowValuesPercent"].exists() && tmp["isShowValuesPercent"].boolValue{
            //百分比显示数据  数据会在js端处理计算好
            var nf : NumberFormatter;
            nf = HideZeroFormatter();//默认不显示0
            
            if tmp["isShowZero"].exists() && tmp["isShowZero"].boolValue{
              nf = NumberFormatter();
            }
            
            nf.numberStyle = .percent;
            nf.maximumFractionDigits = 1;//保留1位小数
            
            dataSet.valueFormatter = nf;
          }else{
            var nf : NumberFormatter;
            nf = HideZeroFormatter();//默认不显示0
            
            if tmp["isShowZero"].exists() && tmp["isShowZero"].boolValue{
              nf = NumberFormatter();
            }
            
            nf.numberStyle = .decimal;
            nf.maximumFractionDigits = 0;//保留0位小数
            dataSet.valueFormatter = nf;
          }
          
          sets.append(dataSet);
        }
      }
      
      let chartData = PieChartData(xVals: labels, dataSets: sets);
      self.rotationEnabled = false; // 不可以手动旋转
      
      self.data = chartData;
      
      if json["hasAnimate"].exists() {
        if json["hasAnimate"].boolValue {
          self.spin(duration: 1, fromAngle: self.rotationAngle+90, toAngle: self.rotationAngle+360);
          self.animate(yAxisDuration: 1, easing: {
            (elapsed: TimeInterval, duration: TimeInterval) -> CGFloat in
            var position = CGFloat(elapsed / (duration / 2.0))
            if (position < 1.0){
              return 0.5 * position * position
            }
            position = position - 1;
            return -0.5 * (position * (position - 2.0) - 1.0)
            }
          );
        }
      }
      
      if json["touchEnabled"].exists() {
        self.isUserInteractionEnabled = json["touchEnabled"].boolValue;
      }
      
      
    }
  }
  
}

class HideZeroFormatter: NumberFormatter {
  override func string(from number: NSNumber) -> String? {
    var ret : String;
    if(number == 0){
      ret = "";
    }else{
      ret = super.string(from: number)!;
    }
    return ret;
  }
}
