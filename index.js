// main index.js

import React, { Component, createRef } from "react";
import { NativeModules } from 'react-native';
import {
  requireNativeComponent,
  UIManager,
  findNodeHandle
} from "react-native";
import PropTypes from 'prop-types';


const myPropTypes = {
  apiKey: PropTypes.string,
  zoomFactor: PropTypes.number,
};



const COMPONENT_NAME = "InstaScanView";
const RNInstaScan = requireNativeComponent(COMPONENT_NAME);

export default class InstaScan extends Component {
  constructor(props){
    super(props);

    this.instaScanRef;
  }

  static Constants = {
    Algorithm: {
      accurate: 0,
      fast: 1
    },
    FocusRestriction: {
      none: 0,
      near: 1,
      far: 2,
    },
    Resolution: {
    
    }
  }
  

  defaultProps =  {
    
  }

  
  componentDidMount(){
    this.startScan();
  }

  componentWillUnmount(){
    this.stopScan();
  }


  render() {
    return (
      <RNInstaScan
        ref={ref => this.instaScanRef = ref}
        {...this.props}
        onPincodeRead={event => {
          if(this.props.onPincodeRead)
            this.props.onPincodeRead(event.nativeEvent);
        }}
      />
    );
  }

  startScan = (...args) => {
    UIManager.dispatchViewManagerCommand(
      findNodeHandle(this.instaScanRef),
      UIManager[COMPONENT_NAME].Commands.startScan,
      [...args]
    );
  };

  stopScan = (...args) => {
    UIManager.dispatchViewManagerCommand(
      findNodeHandle(this.instaScanRef),
      UIManager[COMPONENT_NAME].Commands.stopScan,
      [...args]
    );
  };
}