import React  from 'react';
import { StyleSheet, View } from 'react-native';
import InstaScan from 'react-native-instascan';

export default function Camera() {
  
  return (
    <View style={styles.container}>
      <InstaScan
        
      /> 
    </View>
  )
}



const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
});
