//
//  RNPieChart.swift
//  PoliRank
//
//  Created by Jose Padilla on 2/8/16.
//  Copyright © 2016 Facebook. All rights reserved.
//

import Charts
import SwiftyJSON

@objc(RNRadarChart)
class RNRadarChart : RadarChartView {
  
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
    
    if json["labels"].exists() {
      labels = json["labels"].arrayObject as! [String];
    }
    
    //代码固定label长度，为了不修改Charts包中代码，动态修正。start
    let labelMaxShowLength: Int = 5;//定义长度
    
    //文字超长使用...替换
    var sum: Int = 1;//对应Charts包中ChartData.swift中107行
    for i in 0..<labels.count {
      let label = labels[i] as NSString;
      if(label.length >= labelMaxShowLength){
        labels[i] = label.substring(to: labelMaxShowLength-1) + "...";
      }

      let labelnew = labels[i] as NSString;
      sum += labelnew.length;//对应Charts包中ChartData.swift中111行
    }
    let xValAverageLength = Double(sum) / Double(labels.count);//对应Charts包中ChartData.swift中114行
    let spaceBetweenLabels = Double(labelMaxShowLength) - xValAverageLength;//对应Charts包中ChartXAxisRenderer.swift中41行  为了固定max反推出spaceBetweenLabels （labelMaxShowLength 对应 max）
    self.xAxis.spaceBetweenLabels = Int(round(spaceBetweenLabels));//

    //代码固定label长度，为了不修改Charts包中代码，动态修正。end
    
    
    if json["dataSets"].exists() {
      let dataSets = json["dataSets"].arrayObject;
      
      var sets: [RadarChartDataSet] = [];
      
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
          
          let dataSet = RadarChartDataSet(yVals: dataEntries, label: label);
          
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
          
          if tmp["fillColor"].exists() {
            dataSet.fillColor = RCTConvert.uiColor(tmp["fillColor"].intValue);
          }
          
          if tmp["fillAlpha"].exists() {
            dataSet.fillAlpha = CGFloat(tmp["fillAlpha"].floatValue);
          }
          
          if tmp["lineWidth"].exists() {
            dataSet.lineWidth = CGFloat(tmp["lineWidth"].floatValue);
          }
          
          if tmp["drawFilledEnabled"].exists() {
            dataSet.drawFilledEnabled = tmp["drawFilledEnabled"].boolValue;
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
          
          if json["valueFormatter"].exists() {
            if json["valueFormatter"]["minimumDecimalPlaces"].exists() {
              minimumDecimalPlaces = json["valueFormatter"]["minimumDecimalPlaces"].intValue;
            }
            if json["valueFormatter"]["maximumDecimalPlaces"].exists() {
              maximumDecimalPlaces = json["valueFormatter"]["maximumDecimalPlaces"].intValue;
            }
            
            if json["valueFormatter"]["type"].exists() {
              switch(json["valueFormatter"]["type"]) {
              case "regular":
                dataSet.valueFormatter = NumberFormatter();
                break;
              case "abbreviated":
                dataSet.valueFormatter = ABNumberFormatter(minimumDecimalPlaces: minimumDecimalPlaces, maximumDecimalPlaces: maximumDecimalPlaces);
                break;
              default:
                dataSet.valueFormatter = NumberFormatter();
              }
            }
            
            if json["valueFormatter"]["numberStyle"].exists() {
              switch(json["valueFormatter"]["numberStyle"]) {
              case "CurrencyAccountingStyle":
                if #available(iOS 9.0, *) {
                  dataSet.valueFormatter?.numberStyle = .currencyAccounting;
                }
                break;
              case "CurrencyISOCodeStyle":
                if #available(iOS 9.0, *) {
                  dataSet.valueFormatter?.numberStyle = .currencyISOCode;
                }
                break;
              case "CurrencyPluralStyle":
                if #available(iOS 9.0, *) {
                  dataSet.valueFormatter?.numberStyle = .currencyPlural;
                }
                break;
              case "CurrencyStyle":
                dataSet.valueFormatter?.numberStyle = .currency;
                break;
              case "DecimalStyle":
                dataSet.valueFormatter?.numberStyle = .decimal;
                break;
              case "NoStyle":
                dataSet.valueFormatter?.numberStyle = .none;
                break;
              case "OrdinalStyle":
                if #available(iOS 9.0, *) {
                  dataSet.valueFormatter?.numberStyle = .ordinal;
                }
                break;
              case "PercentStyle":
                dataSet.valueFormatter?.numberStyle = .percent;
                break;
              case "ScientificStyle":
                dataSet.valueFormatter?.numberStyle = .scientific;
                break;
              case "SpellOutStyle":
                dataSet.valueFormatter?.numberStyle = .spellOut;
                break;
              default:
                dataSet.valueFormatter?.numberStyle = .none;
              }
            }
            
            dataSet.valueFormatter?.minimumFractionDigits = minimumDecimalPlaces;
            dataSet.valueFormatter?.maximumFractionDigits = maximumDecimalPlaces;
          }
          
          sets.append(dataSet);
        }
      }
      
      let chartData = RadarChartData(xVals: labels, dataSets: sets);
      self.data = chartData;
      
      if json["webLineWidth"].exists() {
        self.webLineWidth = CGFloat(json["webLineWidth"].floatValue);
      }
      
      if json["innerWebLineWidth"].exists() {
        self.innerWebLineWidth = CGFloat(json["innerWebLineWidth"].floatValue);
      }

      if json["webColor"].exists() {
        self.webColor = UIColor(json["webColor"].stringValue);
      }
      
      if json["innerWebColor"].exists() {
        self.innerWebColor = UIColor(json["innerWebColor"].stringValue);
      }
      
      if json["webAlpha"].exists() {
        self.webAlpha = CGFloat(json["webAlpha"].floatValue);
      }
      
      if json["drawWeb"].exists() {
        self.drawWeb = json["drawWeb"].boolValue;
      }
      
      if json["skipWebLineCount"].exists() {
        self.skipWebLineCount = json["skipWebLineCount"].intValue;
      }
      
      self.yAxis.startAtZeroEnabled = true;//蛛网由0开始
      self.yAxis.enabled = false;//去掉刻度数值显示

//      暂时注释  这个属性目前设置了会导致线划到外面  chart的bug?
//      if json["axisMaximum"].exists() {//最大值
//        self.yAxis.axisMaxValue = json["axisMaximum"].doubleValue;
//      }
      
      if json["webCount"].exists() {//蛛网层数
        self.yAxis.labelCount = json["webCount"].intValue - 1;
      }
      
      if json["touchEnabled"].exists() {
        self.isUserInteractionEnabled = json["touchEnabled"].boolValue;
      }
      
      if json["xAxis"].exists(){
        if json["xAxis"]["textColor"].exists(){
          self.xAxis.labelTextColor = RCTConvert.uiColor(json["xAxis"]["textColor"].intValue);
        }
        if json["xAxis"]["textSize"].exists(){
          let textSize = json["xAxis"]["textSize"].floatValue
          self.xAxis.labelFont = NSUIFont.systemFont(ofSize: CGFloat(textSize) / CGFloat(3.1753));
        }
      }
    }
  }
}
