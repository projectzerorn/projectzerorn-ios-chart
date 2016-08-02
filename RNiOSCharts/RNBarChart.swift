//
//  BarChart.swift
//  PoliRank
//
//  Created by Jose Padilla on 2/6/16.
//  Copyright © 2016 Facebook. All rights reserved.
//

import Charts
import SwiftyJSON

@objc(RNBarChart)
class RNBarChart : BarChartView {
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        self.frame = frame;
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented");
    }
    
    func setConfig(config: String!) {
        setBarLineChartViewBaseProps(config);
      
        var labels: [String] = [];
        
        var json: JSON = nil;
        if let data = config.dataUsingEncoding(NSUTF8StringEncoding) {
            json = JSON(data: data);
        };
        
        if json["labels"].isExists() {
            labels = json["labels"].arrayObject as! [String];
        }
      
        if (json["isStacked"].isExists() && json["isStacked"].boolValue){
            self.data = getStackedBarData(labels, json: json);
        }else{
            self.data = getBarData(labels, json: json);
        }
      
      
      
        
        if json["drawValueAboveBar"].isExists() {
            self.drawValueAboveBarEnabled = json["drawValueAboveBar"].boolValue;
        }
        
        if json["drawHighlightArrow"].isExists() {
            self.drawHighlightArrowEnabled = json["drawHighlightArrow"].boolValue;
        }
        
        if json["drawBarShadow"].isExists() {
            self.drawBarShadowEnabled = json["drawBarShadow"].boolValue;
        }
        if json["scaleEnabled"].isExists() {
            self.scaleXEnabled = json["scaleEnabled"].boolValue;
            self.scaleYEnabled = json["scaleEnabled"].boolValue;
        }
      
        if json["touchEnabled"].isExists() {
          self.userInteractionEnabled = json["touchEnabled"].boolValue;
        }
        if json["xAxis"].isExists() && json["xAxis"]["labelsToSkip"]{
          self.xAxis.setLabelsToSkip(json["xAxis"]["labelsToSkip"].intValue);
        }
    }
  
    func getStackedBarData(labels: [String], json: JSON!) -> BarChartData {
      if !json["dataSets"].isExists() {
        return BarChartData();
      }
      
      var sets: [BarChartDataSet] = [];
      
      //转换数据
      var list:[StackedBarData] = [];
      for _ in 0 ..< json["dataSets"][0]["values"].count {
          let temp = StackedBarData();
          list.append(temp);
      }
      
      for i in 0 ..< json["dataSets"][0]["values"].count {
          for j in 0 ..< json["dataSets"].count{
              list[i].stackedBarData.append(json["dataSets"][j]["values"][i].doubleValue);
              list[i].stackedBarColors.append(RCTConvert.UIColor(json["dataSets"][j]["colors"][0].intValue));
              list[i].stackedBarLabels.append(json["dataSets"][j]["label"].stringValue);
          }
          if json["dataSets"][0]["drawValues"].isExists(){
              list[i].drawValues = json["dataSets"][0]["drawValues"].boolValue;
          }
          if json["dataSets"][0]["valueTextColor"].isExists(){
              list[i].valueTextColor = RCTConvert.UIColor(json["dataSets"][0]["valueTextColor"].intValue);
          }
          if json["dataSets"][0]["valueTextFontSize"].isExists(){
              list[i].valueTextFontSize = json["dataSets"][0]["valueTextFontSize"].intValue;
          }
      }
      
      var dataEntries: [BarChartDataEntry] = [];
      for i in 0 ..< list.count{
          let stackedBarData: StackedBarData = list[i];
          let dataEntry = BarChartDataEntry(values: stackedBarData.stackedBarData, xIndex: i);
          dataEntries.append(dataEntry);
      }
      let dataSet = BarChartDataSet(yVals: dataEntries, label: "");
      
      if(list.count > 0){
          let stackedBarData: StackedBarData = list[0];
          dataSet.stackLabels = stackedBarData.stackedBarLabels;
          dataSet.colors = stackedBarData.stackedBarColors;
          dataSet.drawValuesEnabled = stackedBarData.drawValues;
          dataSet.valueTextColor = stackedBarData.valueTextColor;
          dataSet.valueFont = dataSet.valueFont.fontWithSize(CGFloat(stackedBarData.valueTextFontSize))
      }
      sets.append(dataSet);
      
      return BarChartData(xVals: labels, dataSets: sets);
    }
}