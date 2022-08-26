/**
 * Sample React Native App
 *
 * adapted from App.js generated by the following command:
 *
 * react-native init example
 *
 * https://github.com/facebook/react-native
 */

import React, { Component, createRef } from 'react';
import { StyleSheet, Text, View } from 'react-native';
import TestView, { Test } from 'react-native-instascan';

export default class App extends Component {
  constructor(props){
    instaScanRef = createRef();
    
    super(props);
  }
  state = {
    status: 'starting',
    message: '--'
  };

  componentDidMount() {
    // console.log(this.instaScanRef);
    // this.instaScanRef.changeColor();
    console.log(Test.hey());
    // InstaScanReactNative.hey();
    // InstaScanReactNative.sampleMethod('Testing', 123, (message) => {
    //   this.setState({
    //     status: 'native callback received',
    //     message
    //   });
    // });

  }
  render() {
    return (
      <View style={styles.container}>
        <TestView
          ref={this.instaScanRef}
          style={{
            width: 100,
            height: 100,
            backgroundColor: "lime"
          }}
        />
        <Text style={styles.welcome}>☆InstaScanReactNative example☆</Text>
        <Text style={styles.instructions}>STATUS: {this.state.status}</Text>
        <Text style={styles.welcome}>☆NATIVE CALLBACK MESSAGE☆</Text>
        <Text style={styles.instructions}>{this.state.message}</Text>
      </View>
    );
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#F5FCFF',
  },
  welcome: {
    fontSize: 20,
    textAlign: 'center',
    margin: 10,
  },
  instructions: {
    textAlign: 'center',
    color: '#333333',
    marginBottom: 5,
  },
});