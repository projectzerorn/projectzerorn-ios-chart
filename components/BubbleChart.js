import React, {
  Component,
  requireNativeComponent,
  Platform
} from 'react-native';

import {
  globalCommonProps,
  barLineCommonProps,
  commonDataSetProps
} from '../utils/commonProps';

import { processColors } from '../utils/commonColorProps';

if(Platform.OS === 'ios') {
  var RNBubbleChart = requireNativeComponent('RNBubbleChartSwift', BubbleChart);
}

class BubbleChart extends Component {
  render() {
    let {config, ...otherProps} = this.props;
    config = processColors(config);
    return <RNBubbleChart
      config={JSON.stringify(config)}
      {...otherProps}/>;
  }
};

BubbleChart.propTypes = {
  config: React.PropTypes.shape({
    ...globalCommonProps,
    ...barLineCommonProps,
    dataSets: React.PropTypes.arrayOf(React.PropTypes.shape({
      ...commonDataSetProps,
      values: React.PropTypes.arrayOf(React.PropTypes.shape({
        value: React.PropTypes.number,
        size: React.PropTypes.number
      })).isRequired,
      highlightCircleWidth: React.PropTypes.number
    }))
  })
};

export default BubbleChart;
