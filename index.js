// main index.js

import React, { Component } from "react";
import { NativeModules } from 'react-native';
import {
  requireNativeComponent,
  UIManager,
  findNodeHandle
} from "react-native";

export const { Test } = NativeModules;


const COMPONENT_NAME = "TestView";
const RNTestView = requireNativeComponent(COMPONENT_NAME);

export default class TestView extends Component {
  constructor(props){
    instaScanRef;
    
    super(props);
  }

  componentDidMount(){
    console.log(this.instaScanRef);
    this.changeColor();
    // this.instaScanRef.changeColor();
  }


  render() {
    return (
      <RNTestView
        ref={ref => this.instaScanRef = ref}
        style={this.props.style}
      />
    );
  }

  changeColor = (...args) => {
    UIManager.dispatchViewManagerCommand(
      findNodeHandle(this.instaScanRef),
      UIManager[COMPONENT_NAME].Commands.changeColor,
      [...args]
    );
  };
}