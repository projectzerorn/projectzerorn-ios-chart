import React, {
  Component,
  StyleSheet
} from 'react-native';

import { ScatterChart } from 'react-native-ios-charts';


const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'stretch'
  }
});

export default class Scatter extends Component {
  static displayName = 'Scatter';

  render() {
    const config = {
      dataSets: [{
        values: [5, 40, 77, 81, 43],
        drawValues: false,
        colors: ['rgb(197, 36, 82)'],
        label: 'Company A',
        scatterShape: 'Square'
      }, {
        values: [40, 5, 50, 23, 79],
        drawValues: false,
        colors: ['rgb(255, 101, 0)'],
        label: 'Company B',
        scatterShape: 'Circle'
      }, {
        values: [10, 55, 35, 90, 82],
        drawValues: false,
        colors: ['rgb(247, 198, 0)'],
        label: 'Company C',
        scatterShape: 'Triangle'
      }],
      backgroundColor: 'transparent',
      labels: ['1990', '1991', '1992', '1993', '1994'],
      legend: {
      },
      xAxis: {
        position: 'bottom'
      },
      leftAxis: {
        spaceBottom: 0.05
      },
      rightAxis: {
        spaceBottom: 0.05
      },
      valueFormatter: {
        type: 'regular',
        maximumDecimalPlaces: 0
      }
    };
    return (
      <ScatterChart config={config} style={styles.container}/>
    );
  }
}
