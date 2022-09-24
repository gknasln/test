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



const COMPONENT_NAME = "KZNInstaScanView";
const RNInstaScan = requireNativeComponent(COMPONENT_NAME);
const CameraModule = NativeModules.KZNInstaScanView
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
  

  /*defaultProps =  {
    
  }*/

  
  componentDidMount(){
    setTimeout(() => {
      this.startScan();

    }, 0);

    setTimeout(() => {
      this.updateGuideText("Lütfen okutmak istediğiniz kodu çerçeveye hizalayıp aktif oluncuya kadar bekleyiniz.");

    }, 0);

    setTimeout(() => {
      this.setTorch(true)

    }, 1000);

    setTimeout(async () => {

      //console.log(CameraModule)
      try{
        let torchStatus = await CameraModule.getTorchStatus(findNodeHandle(this.instaScanRef))
        console.log("torchStatus",torchStatus)
      }
      catch(error){
        console.log(error)
      }

    }, 2000);

    setTimeout(() => {
      this.toggleTorch()

    }, 5000);

    setTimeout(async () => {

      //console.log(CameraModule)
      try{
        let torchStatus = await CameraModule.getTorchStatus(findNodeHandle(this.instaScanRef))
        console.log("torchStatus",torchStatus)
      }
      catch(error){
        console.log(error)
      }

    }, 6000);

  }

  componentWillUnmount(){
    this.stopScan();
  }


  render() {
    console.log(this.props)
    return (
      <RNInstaScan
        ref={ref => this.instaScanRef = ref}
        style = {{flex:1}}
        apiKey = "fBjYzfbJTHx+5VIcEQLsEBCnNoAZksLw6TtHTUV/LOI="
        
        //{...this.props}
        onPincodeRead={event => {
          if(this.props.onPincodeRead)
            this.updateGuideText(event.nativeEvent.pincode)
            this.props.onPincodeRead(event.nativeEvent);
        }}
        onInstaScanError={event => {
          if(this.props.onError)
            this.props.onError(event.nativeEvent);
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

  restartScan = (...args) => {
    UIManager.dispatchViewManagerCommand(
      findNodeHandle(this.instaScanRef),
      UIManager[COMPONENT_NAME].Commands.restartScan,
      [...args]
    );
  };

  updateGuideText = (...args) => {
    UIManager.dispatchViewManagerCommand(
      findNodeHandle(this.instaScanRef),
      UIManager[COMPONENT_NAME].Commands.updateGuideText,
      [...args]
    );
  };

  toggleTorch = (...args) => {
    UIManager.dispatchViewManagerCommand(
      findNodeHandle(this.instaScanRef),
      UIManager[COMPONENT_NAME].Commands.toggleTorch,
      [...args]
    );
  };

  setTorch = (...args) => {
    UIManager.dispatchViewManagerCommand(
      findNodeHandle(this.instaScanRef),
      UIManager[COMPONENT_NAME].Commands.setTorch,
      [...args]
    );
  };

  getTorchStatus = (...args) => {
    UIManager.dispatchViewManagerCommand(
      findNodeHandle(this.instaScanRef),
      UIManager[COMPONENT_NAME].Commands.getTorchStatus,
      [...args]
    );
  };

}