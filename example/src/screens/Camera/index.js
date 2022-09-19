import React  from 'react';
import { StyleSheet, View } from 'react-native';
import InstaScan from 'react-native-instascan';

export default function Camera() {
  
  return (
    <View style={styles.container}>
      <InstaScan apiKey="abcdefgh"
        onPincodeRead = {data => console.log("pincode read: " + JSON.stringify(data))}
      /> 
    </View>
  )
}



const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
});
