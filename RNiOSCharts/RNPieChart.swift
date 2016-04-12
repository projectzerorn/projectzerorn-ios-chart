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
  
  func setConfig(config: String!) {
    setPieRadarChartViewBaseProps(config);
    
    var maximumDecimalPlaces: Int = 0;
    var minimumDecimalPlaces: Int = 0;
    var labels: [String] = [];
    
    var json: JSON = nil;
    if let data = config.dataUsingEncoding(NSUTF8StringEncoding) {
      json = JSON(data: data);
    };

    if json["holeColor"].isExists() {
      self.holeColor = RCTConvert.UIColor(json["holeColor"].intValue);
    }
    
    if json["drawHoleEnabled"].isExists() {
      self.drawHoleEnabled = json["drawHoleEnabled"].boolValue;
    }

    if json["centerText"].isExists() {
      let paraStyle = NSMutableParagraphStyle();
      paraStyle.alignment = NSTextAlignment.Center;//居中属性
      
      let centerTextSets = json["centerText"].arrayObject;
      let centerText = NSMutableAttributedString.init();
      for set in centerTextSets!{
        let tmp = JSON(set);
        let tempText = tmp["text"].stringValue;
        let color = tmp["color"].stringValue;
        let size = tmp["size"].intValue;
        let isWrap = tmp["isWrap"].boolValue;
        
        
        if(isWrap){//换行
          centerText.appendAttributedString(NSAttributedString.init(string: "\n"));
        }
        
        //文字
        let tempTextWithAttrib  = NSAttributedString.init(string: tempText,
                                                          attributes: [
                                                            NSParagraphStyleAttributeName: paraStyle,
                                                            NSForegroundColorAttributeName: UIColor(rgba: color).CGColor,
                                                            NSFontAttributeName: UIFont.systemFontOfSize(CGFloat(size) / CGFloat(3.1753))
                                                          ]);
        centerText.appendAttributedString(tempTextWithAttrib);
      }
      
      self.centerAttributedText = centerText;
    }
    
    

    if json["drawCenterTextEnabled"].isExists() {
      self.drawCenterTextEnabled = json["drawCenterTextEnabled"].boolValue;
    }
    
    if json["holeRadius"].isExists() {
      self.holeRadiusPercent = CGFloat(json["holeRadius"].floatValue / 100.0);
      if json["holeRadius"].floatValue == 0 {
        self.transparentCircleRadiusPercent = 0;
      }else{
        self.transparentCircleRadiusPercent = self.holeRadiusPercent + 0.05;
      }
    }
    
    if json["holeRadiusPercent"].isExists() {
      self.holeRadiusPercent = CGFloat(json["holeRadiusPercent"].floatValue);
    }
    
    if json["transparentCircleRadiusPercent"].isExists() {
      self.transparentCircleRadiusPercent = CGFloat(json["transparentCircleRadiusPercent"].floatValue);
    }
    
    if json["hasHoleFrame"].isExists() {
      if !json["hasHoleFrame"].boolValue {
        self.transparentCircleRadiusPercent = self.holeRadiusPercent;
      }
    }
    
    if json["drawSliceTextEnabled"].isExists() {
      self.drawSliceTextEnabled = json["drawSliceTextEnabled"].boolValue;
    }
    
    if json["usePercentValuesEnabled"].isExists() {
      self.usePercentValuesEnabled = json["usePercentValuesEnabled"].boolValue;
    }
    
    if json["centerTextRadiusPercent"].isExists() {
      self.centerTextRadiusPercent = CGFloat(json["centerTextRadiusPercent"].floatValue);
    }
    
    if json["maxAngle"].isExists() {
      self.maxAngle = CGFloat(json["maxAngle"].floatValue);
    }
    
    if json["labels"].isExists() {
      labels = json["labels"].arrayObject as! [String];
    }
    
    if json["dataSets"].isExists() {
      let dataSets = json["dataSets"].arrayObject;
      
      var sets: [PieChartDataSet] = [];
      
      for set in dataSets! {
        let tmp = JSON(set);
        if tmp["values"].isExists() {
          let values = tmp["values"].arrayObject as! [Double];
          let label = tmp["label"].isExists() ? tmp["label"].stringValue : "";
          var dataEntries: [ChartDataEntry] = [];
          
          for i in 0..<values.count {
            let dataEntry = ChartDataEntry(value: values[i], xIndex: i);
            dataEntries.append(dataEntry);
          }
          
          let dataSet = PieChartDataSet(yVals: dataEntries, label: label);
          
          if tmp["sliceSpace"].isExists() {
            dataSet.sliceSpace = CGFloat(tmp["sliceSpace"].floatValue);
          }
          
          if tmp["selectionShift"].isExists() {
            dataSet.selectionShift = CGFloat(tmp["selectionShift"].floatValue);
          }
          
          if tmp["colors"].isExists() {
            let arrColors = tmp["colors"].arrayObject as! [Int];
            dataSet.colors = arrColors.map({return RCTConvert.UIColor($0)});
          }
          
          if tmp["drawValues"].isExists() {
            dataSet.drawValuesEnabled = tmp["drawValues"].boolValue;
          }
          
          if tmp["highlightEnabled"].isExists() {
            dataSet.highlightEnabled = tmp["highlightEnabled"].boolValue;
          }
          
          if tmp["valueTextFontName"].isExists() {
            dataSet.valueFont = UIFont(
              name: tmp["valueTextFontName"].stringValue,
              size: dataSet.valueFont.pointSize
              )!;
          }
          
          if tmp["valueTextFontSize"].isExists() {
            dataSet.valueFont = dataSet.valueFont.fontWithSize(CGFloat(tmp["valueTextFontSize"].floatValue))
          }
          
          if tmp["valueTextColor"].isExists() {
            dataSet.valueTextColor = RCTConvert.UIColor(tmp["valueTextColor"].intValue);
          }
          
          let nf = NSNumberFormatter();
          nf.numberStyle = NSNumberFormatterStyle.DecimalStyle;
          nf.maximumFractionDigits = 0;//保留0位小数
          dataSet.valueFormatter = nf;
          
          sets.append(dataSet);
        }
      }
      
      let chartData = PieChartData(xVals: labels, dataSets: sets);
      self.rotationEnabled = false; // 不可以手动旋转
      
      self.data = chartData;
      
      if json["hasAnimate"].isExists() {
        if json["hasAnimate"].boolValue {
          self.spin(duration: 1, fromAngle: self.rotationAngle+90, toAngle: self.rotationAngle+360);
          self.animate(yAxisDuration: 1, easing: {
            (elapsed: NSTimeInterval, duration: NSTimeInterval) -> CGFloat in
            var position = CGFloat(elapsed / (duration / 2.0))
            if (position < 1.0){
              return 0.5 * position * position
            }
            return -0.5 * ((--position) * (position - 2.0) - 1.0)
            }
          );
        }
      }
      
      if json["touchEnabled"].isExists() {
        self.userInteractionEnabled = json["touchEnabled"].boolValue;
      }
      
      
    }
  }
  
}