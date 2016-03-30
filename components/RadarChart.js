import React, {
  Component,
  requireNativeComponent,
  processColor,
  Platform
} from 'react-native';

import {
  globalCommonProps,
  pieRadarCommonProps,
  commonDataSetProps
} from '../utils/commonProps';

import { processColors } from '../utils/commonColorProps';

if(Platform.OS === 'ios') {
  var RNRadarChart = requireNativeComponent('RNRadarChartSwift', RadarChart);
}

class RadarChart extends Component {
  render() {
    let {config, ...otherProps} = this.props;
    config = processColors(config);
    return <RNRadarChart
      config={JSON.stringify(config)}
      {...otherProps}/>;
  }
};

RadarChart.propTypes = {
  config: React.PropTypes.shape({
    ...globalCommonProps,
    ...pieRadarCommonProps,
    dataSets: React.PropTypes.arrayOf(React.PropTypes.shape({
      ...commonDataSetProps,
      fillColor: React.PropTypes.string,
      fillAlpha: React.PropTypes.number,
      lineWidth: React.PropTypes.number,
      drawFilledEnabled: React.PropTypes.bool
    })),
    webLineWidth: React.PropTypes.number,
    innerWebLineWidth: React.PropTypes.number,
    webColor: React.PropTypes.string,
    innerWebColor: React.PropTypes.string,
    webAlpha: React.PropTypes.number,
    drawWeb: React.PropTypes.bool,
    skipWebLineCount: React.PropTypes.number
  })
};

export default RadarChart;
